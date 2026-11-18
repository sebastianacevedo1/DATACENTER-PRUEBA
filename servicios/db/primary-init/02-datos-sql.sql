CREATE TABLE IF NOT EXISTS items (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  creado TIMESTAMPTZ DEFAULT now()
);
INSERT INTO items (nombre) VALUES ('Servidor WEB 1'), ('Servidor APP 1'), ('Base de datos primaria');