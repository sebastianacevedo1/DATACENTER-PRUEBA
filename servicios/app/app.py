import os
from flask import Flask, jsonify, request
from psycopg2.pool import ThreadedConnectionPool

app = Flask(__name__)
_pools = {}

def get_pool(role):
    host = os.environ["DB_PRIMARY"] if role == "primary" else os.environ["DB_REPLICA"]
    if role not in _pools:
        _pools[role] = ThreadedConnectionPool(
            1, 20, host=host, dbname=os.environ["DB_NAME"],
            user=os.environ["DB_USER"], password=os.environ["DB_PASS"],
            connect_timeout=3)
    return _pools[role]

def query(role, sql, args=None, write=False):
    pool = get_pool(role)
    conn = pool.getconn()
    bad = False
    try:
        with conn.cursor() as cur:
            cur.execute(sql, args)
            rows = cur.fetchall() if cur.description else None
        conn.commit() if write else conn.rollback()
        return rows
    except Exception:
        bad = True
        conn.rollback()
        raise
    finally:
        pool.putconn(conn, close=bad)

@app.get("/api/health")
def health():
    return jsonify(estado="ok")

@app.get("/api/items")
def listar():
    sql = "SELECT id, nombre, creado FROM items ORDER BY id DESC LIMIT 50"
    try:
        rows, origen = query("replica", sql), "replica"
    except Exception:
        try:
            rows, origen = query("primary", sql), "primario"
        except Exception as e:
            return jsonify(error=str(e)), 503
    return jsonify(origen=origen, items=[
        {"id": r[0], "nombre": r[1], "creado": r[2].isoformat()} for r in rows])

@app.post("/api/items")
def crear():
    nombre = (request.get_json(silent=True) or {}).get("nombre", "sin nombre")[:100]
    try:
        query("primary", "INSERT INTO items (nombre) VALUES (%s)", (nombre,), write=True)
    except Exception as e:
        return jsonify(error=str(e)), 503
    return jsonify(ok=True), 201

@app.get("/api/stats")
def stats():
    out = {}
    for role in ("primary", "replica"):
        try:
            r = query(role, "SELECT pg_is_in_recovery(), (SELECT count(*) FROM items)")
            out[role] = {"es_replica": r[0][0], "filas": r[0][1]}
        except Exception as e:
            out[role] = {"error": str(e)}
    return jsonify(out)