#!/bin/bash
set -e
PGDATA=/var/lib/postgresql/data
if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "Esperando al primario..."
  until pg_isready -h db_primary -U postgres; do sleep 2; done
  pg_basebackup -d "host=db_primary user=replicator password=${REPL_PASS}" -D "$PGDATA" -Fp -Xs -R -P
  chown -R postgres:postgres "$PGDATA"
  chmod 700 "$PGDATA"
fi
exec gosu postgres postgres -c hot_standby=on -c max_connections=300
