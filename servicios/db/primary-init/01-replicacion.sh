#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 -U postgres -d postgres -c "CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '${REPL_PASS}';"
echo "host replication replicator all md5" >> "$PGDATA/pg_hba.conf"