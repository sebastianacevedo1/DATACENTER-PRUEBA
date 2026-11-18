#!/bin/sh
echo "=== Reglas NAT ==="; iptables -t nat -L POSTROUTING -n -v
echo; echo "=== Traducciones activas (conntrack) ==="
conntrack -L 2>/dev/null || cat /proc/net/nf_conntrack 2>/dev/null