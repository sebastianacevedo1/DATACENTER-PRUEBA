#!/bin/sh
set -e
OUT_IF=$(ip -o -4 addr show | awk -v p="$OUT_PREFIX" 'index($4,p)==1{print $2; exit}')
IN_IF=$(ip -o -4 addr show | awk -v p="$IN_PREFIX" 'index($4,p)==1{print $2; exit}')
IN_NET="${IN_PREFIX}0/24"
echo "Nodo NAT tipo=$NAT_TYPE  fuera=$OUT_IF  dentro=$IN_IF"

sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true
ip route replace default via "${OUT_PREFIX}1" dev "$OUT_IF"
iptables -F; iptables -t nat -F
iptables -P FORWARD DROP
iptables -A FORWARD -i "$IN_IF"  -o "$OUT_IF" -j ACCEPT
iptables -A FORWARD -i "$OUT_IF" -o "$IN_IF"  -m state --state ESTABLISHED,RELATED -j ACCEPT

case "$NAT_TYPE" in
  static)   # NAT estatica: 1 IP privada <-> 1 IP publica fija
    ip addr add "${OUT_PREFIX}20/24" dev "$OUT_IF" 2>/dev/null || true
    iptables -t nat -A POSTROUTING -s "$CLIENT_IP" -o "$OUT_IF" -j SNAT --to-source "${OUT_PREFIX}20"
    ;;
  dynamic)  # NAT dinamica: pool de IPs publicas (.10 a .14)
    for i in 10 11 12 13 14; do ip addr add "${OUT_PREFIX}$i/24" dev "$OUT_IF" 2>/dev/null || true; done
    iptables -t nat -A POSTROUTING -s "$IN_NET" -o "$OUT_IF" -j SNAT --to-source "${OUT_PREFIX}10-${OUT_PREFIX}14"
    ;;
  pat)      # PAT / overload: muchas IPs privadas -> 1 IP publica, cambia puertos
    iptables -t nat -A POSTROUTING -s "$IN_NET" -o "$OUT_IF" -j MASQUERADE
    ;;
  *) echo "NAT_TYPE invalido: usa static, dynamic o pat"; exit 1 ;;
esac

iptables -t nat -L -n -v
exec tail -f /dev/null