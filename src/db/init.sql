-- Base de datos de EnvíoYa: Domicilios con seguimiento en tiempo real.
-- Se ejecuta solo la primera vez que PostgreSQL arranca con el volumen vacio.

-- Domiciliarios
CREATE TABLE IF NOT EXISTS items (
  id        SERIAL PRIMARY KEY,
  nombre    TEXT NOT NULL,          -- Domiciliario
  detalle   TEXT NOT NULL,          -- Vehículo y zona
  categoria TEXT NOT NULL,          -- Tipo
  cantidad  NUMERIC(14,2) NOT NULL CHECK (cantidad >= 0)  -- Pedidos que puede tomar
);

-- Envíos
CREATE TABLE IF NOT EXISTS registros (
  id      SERIAL PRIMARY KEY,
  item_id INTEGER REFERENCES items(id),
  persona TEXT NOT NULL,            -- Cliente
  monto   NUMERIC(14,2),
  fecha   TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO items (nombre, detalle, categoria, cantidad) VALUES
  ('Carlos Muñoz', 'Moto ABC12D · Zona Sur', 'Moto', 3),
  ('Diana Cárdenas', 'Bicicleta · Zona Centro', 'Bicicleta', 2),
  ('Jorge Arango', 'Moto XYZ98E · Zona Norte', 'Moto', 3),
  ('Valentina Ruiz', 'Carro · Zona Oeste', 'Carro', 4);
