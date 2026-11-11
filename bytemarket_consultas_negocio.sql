/* ============================================================================
   ENTREGABLE MÓDULO 4: ANÁLISIS Y CONSULTAS DE NEGOCIO
   PROYECTO: ByteMarket_DW (Sistema de Gestión Comercial Tecnológica)
   MOTOR: SQL Server (T-SQL)
   ARCHIVO: bytemarket_consultas_negocio.sql
   ============================================================================ */

USE ByteMarket_DW;
GO

-- ----------------------------------------------------------------------------
-- REPORTE 1: MÉTRICAS CONSOLIDADAS POR MES
-- Propósito: Evaluar ingresos totales, número de operaciones y ticket medio.
-- ----------------------------------------------------------------------------
-- Agrupa las operaciones por mes de emisión para obtener el volumen comercial,
-- el total recaudado (unidades * importe_unitario) y el valor promedio por orden.

SELECT 
    MONTH(fecha_operacion) AS mes_operacion,
    SUM(unidades * importe_unitario) AS ingresos_totales,
    COUNT(operacion_id) AS total_operaciones,
    AVG(unidades * importe_unitario) AS ticket_medio
FROM detalle_ventas
GROUP BY MONTH(fecha_operacion);
GO


-- ----------------------------------------------------------------------------
-- REPORTE 2: TOP 5 ARTÍCULOS CON MAYOR RECAUDACIÓN
-- Propósito: Detectar los productos estrella según los ingresos generados.
-- ----------------------------------------------------------------------------
-- Ordena el catálogo vendido de mayor a menor facturación mostrando las unidades
-- despachadas y el monto acumulado de los 5 primeros artículos.

SELECT TOP 5
    producto_id,
    SUM(unidades) AS total_unidades,
    SUM(unidades * importe_unitario) AS recaudacion_total
FROM detalle_ventas
GROUP BY producto_id
ORDER BY recaudacion_total DESC;
GO


-- ----------------------------------------------------------------------------
-- REPORTE 3: ANÁLISIS DE RECURRENCIA DE COMPRADORES
-- Propósito: Identificar clientes con más de una operación registrada.
-- ----------------------------------------------------------------------------
-- Filtra mediante HAVING los compradores que superan 1 pedido, calculando su
-- frecuencia de compra y el gasto acumulado en el periodo.

SELECT 
    cliente_id,
    COUNT(operacion_id) AS frecuencia_compras,
    SUM(unidades * importe_unitario) AS inversion_total
FROM detalle_ventas
GROUP BY cliente_id
HAVING COUNT(operacion_id) > 1
ORDER BY inversion_total DESC;
GO


-- ----------------------------------------------------------------------------
-- REPORTE 4: EVALUACIÓN DE RENDIMIENTO POR ARTÍCULO VS. PROMEDIO
-- Propósito: Segmentar el catálogo respecto a la media de ingresos por SKU.
-- ----------------------------------------------------------------------------
-- Emplea una expresión de tabla común (CTE) para totalizar las ventas por artículo
-- y comparar cada resultado contra el promedio general del portafolio.

WITH IngresosPorArticulo AS (
    SELECT 
        producto_id,
        SUM(unidades * importe_unitario) AS monto_articulo
    FROM detalle_ventas
    GROUP BY producto_id
)
SELECT 
    producto_id,
    monto_articulo,
    CASE 
        WHEN monto_articulo >= (SELECT AVG(monto_articulo) FROM IngresosPorArticulo) THEN 'Superior al promedio'
        ELSE 'Inferior al promedio'
    END AS clasificacion_desempeno
FROM IngresosPorArticulo
ORDER BY monto_articulo DESC;
GO


-- ----------------------------------------------------------------------------
-- CONCLUSIONES EJECUTIVAS: 3 HALLAZGOS CLAVE DEL ANÁLISIS
-- ----------------------------------------------------------------------------
/*
1. CONCENTRACIÓN DE INGRESOS EN EQUIPOS DE CÓMPUTO (PRODUCTO 501):
El artículo 501 (Ultrabook Zenith 14") encabeza la recaudación con $2,700.00
(2 unidades vendidas a $1,350.00 c/u), aportando el 49.2% de los $5,487.00
facturados en marzo de 2025. Sumado al producto 503 (Monitor Curvo QHD 32",
$1,440.00), la línea de cómputo concentra el 75.5% de las ventas totales.

2. ALTA RETENCIÓN EN LA CARTERA DE COMPRADORES:
El 100% de los clientes activos (los 5 registrados: IDs 101 al 105) presentaron
recurrencia con exactamente 2 operaciones cada uno durante el mes. La compradora
105 (Camila Ortiz) lidera el gasto acumulado con $1,830.00, seguida por la
cliente 101 (Sofía Mendoza) con $1,495.00.

3. BRECHA DE RENDIMIENTO FRENTE AL PROMEDIO DEL CATÁLOGO:
El ingreso promedio por artículo se ubicó en $914.50. Únicamente 2 referencias
(producto 501 con $2,700.00 y producto 503 con $1,440.00) lograron situarse
como 'Superior al promedio', mientras que los otros 4 artículos quedaron en el
segmento 'Inferior al promedio' (oscilando entre $267.00 y $435.00).
*/
