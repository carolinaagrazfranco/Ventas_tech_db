/* ============================================================================
   PROYECTO: ByteMarket_DW (Sistema de Gestión Comercial Tecnológica)
   MOTOR: SQL Server (T-SQL)
   ARCHIVO: bytemarket_schema_data.sql
   DESCRIPCIÓN: Creación de modelo relacional en 3FN y carga inicial de datos.
   ============================================================================ */

-- Descomentar el siguiente bloque si la base de datos aún no existe en el servidor:
/*
IF DB_ID('ByteMarket_DW') IS NULL
BEGIN
    CREATE DATABASE ByteMarket_DW;
END;
GO
USE ByteMarket_DW;
GO
*/

-- ----------------------------------------------------------------------------
-- PASO 1: LIMPIEZA DE OBJETOS PREVIOS
-- Se borran primero las entidades transaccionales y luego los catálogos base
-- para evitar conflictos con las llaves foráneas.
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS detalle_ventas;
DROP TABLE IF EXISTS catalogo_productos;
DROP TABLE IF EXISTS registro_clientes;
DROP TABLE IF EXISTS lineas_producto;
GO

-- ----------------------------------------------------------------------------
-- PASO 2: DEFINICIÓN DE ESTRUCTURA (DDL)
-- Construcción de tablas dimensionales y tabla de hechos con integridad referencial.
-- ----------------------------------------------------------------------------

-- Catálogo de familias o líneas tecnológicas
CREATE TABLE lineas_producto (
    linea_id INT NOT NULL,
    titulo_linea VARCHAR(60) NOT NULL,
    detalle VARCHAR(250) NULL,
    CONSTRAINT PK_lineas_producto PRIMARY KEY (linea_id)
);
GO

-- Padrón de compradores registrados
CREATE TABLE registro_clientes (
    cliente_id INT NOT NULL,
    nombre_completo VARCHAR(120) NOT NULL,
    correo_electronico VARCHAR(120) NULL,
    localidad VARCHAR(60) NULL,
    alta_fecha DATE NOT NULL,
    CONSTRAINT PK_registro_clientes PRIMARY KEY (cliente_id),
    CONSTRAINT UQ_registro_clientes_correo UNIQUE (correo_electronico)
);
GO

-- Inventario de artículos disponibles para la venta
CREATE TABLE catalogo_productos (
    producto_id INT NOT NULL,
    descripcion_articulo VARCHAR(120) NOT NULL,
    linea_id INT NOT NULL,
    precio_lista DECIMAL(10,2) NOT NULL,
    existencias INT NOT NULL CONSTRAINT DF_catalogo_existencias DEFAULT 0,
    habilitado BIT NOT NULL CONSTRAINT DF_catalogo_habilitado DEFAULT 1,
    CONSTRAINT PK_catalogo_productos PRIMARY KEY (producto_id),
    CONSTRAINT FK_catalogo_lineas FOREIGN KEY (linea_id) 
        REFERENCES lineas_producto(linea_id)
);
GO

-- Registro histórico de operaciones comerciales (Tabla de Hechos)
CREATE TABLE detalle_ventas (
    operacion_id INT NOT NULL,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    unidades INT NOT NULL,
    importe_unitario DECIMAL(10,2) NOT NULL,
    fecha_operacion DATE NOT NULL,
    CONSTRAINT PK_detalle_ventas PRIMARY KEY (operacion_id),
    CONSTRAINT FK_detalle_clientes FOREIGN KEY (cliente_id) 
        REFERENCES registro_clientes(cliente_id),
    CONSTRAINT FK_detalle_productos FOREIGN KEY (producto_id) 
        REFERENCES catalogo_productos(producto_id)
);
GO

-- ----------------------------------------------------------------------------
-- PASO 3: INSERCIÓN DE REGISTROS (DML - 25 filas en total)
-- Poblado de tablas respetando la jerarquía de dependencias.
-- ----------------------------------------------------------------------------

-- 3.1. Poblado de líneas de producto (4 registros)
INSERT INTO lineas_producto (linea_id, titulo_linea, detalle) VALUES
    (10, 'Equipos de Cómputo', 'Portátiles, estaciones de trabajo y pantallas'),
    (20, 'Periféricos',        'Dispositivos de entrada y accesorios de escritorio'),
    (30, 'Sonido y Audio',     'Audífonos, barras de sonido y micrófonos'),
    (40, 'Memoria y Discos',   'Unidades de estado sólido y almacenamiento portátil');
GO

-- 3.2. Poblado de clientes (5 registros)
INSERT INTO registro_clientes (cliente_id, nombre_completo, correo_electronico, localidad, alta_fecha) VALUES
    (101, 'Sofía Mendoza',    'sofia.mendoza@correo.com',   'Ciudad de México', '2025-01-12'),
    (102, 'Diego Herrera',    'dherrera@correo.com',        'Guadalajara',      '2025-01-18'),
    (103, 'Valeria Castro',   'vcastro@correo.com',         'Monterrey',        '2025-02-04'),
    (104, 'Andrés Morales',   'amorales@correo.com',        'Puebla',           '2025-02-19'),
    (105, 'Camila Ortiz',     'camila.ortiz@correo.com',    'Querétaro',        '2025-03-03');
GO

-- 3.3. Poblado de catálogo de productos (6 registros)
INSERT INTO catalogo_productos (producto_id, descripcion_articulo, linea_id, precio_lista, existencias, habilitado) VALUES
    (501, 'Ultrabook Zenith 14"',     10, 1350.00, 14, 1),
    (502, 'Ratón Óptico Ergonómico',  20,   32.50, 75, 1),
    (503, 'Monitor Curvo QHD 32"',    10,  480.00, 10, 1),
    (504, 'Diadema Noise Cancelling', 30,  145.00, 28, 1),
    (505, 'Unidad NVMe Externa 2TB',  40,  160.00, 22, 1),
    (506, 'Teclado Compacto RGB',     20,   89.00, 36, 1);
GO

-- 3.4. Poblado de operaciones de venta (10 registros)
INSERT INTO detalle_ventas (operacion_id, cliente_id, producto_id, unidades, importe_unitario, fecha_operacion) VALUES
    (1001, 101, 501, 1, 1350.00, '2025-03-05'),
    (1002, 102, 502, 4,   32.50, '2025-03-06'),
    (1003, 103, 503, 2,  480.00, '2025-03-08'),
    (1004, 101, 504, 1,  145.00, '2025-03-09'),
    (1005, 104, 505, 2,  160.00, '2025-03-11'),
    (1006, 102, 506, 3,   89.00, '2025-03-12'),
    (1007, 105, 501, 1, 1350.00, '2025-03-14'),
    (1008, 103, 502, 6,   32.50, '2025-03-15'),
    (1009, 104, 504, 2,  145.00, '2025-03-17'),
    (1010, 105, 503, 1,  480.00, '2025-03-18');
GO

-- ----------------------------------------------------------------------------
-- PASO 4: COMPROBACIÓN DE CARGA
-- Auditoría rápida del conteo de filas insertadas por tabla.
-- ----------------------------------------------------------------------------

SELECT COUNT(*) AS total_lineas    FROM lineas_producto;    -- Esperado: 4
SELECT COUNT(*) AS total_clientes  FROM registro_clientes;  -- Esperado: 5
SELECT COUNT(*) AS total_productos FROM catalogo_productos; -- Esperado: 6
SELECT COUNT(*) AS total_ventas    FROM detalle_ventas;     -- Esperado: 10
GO
