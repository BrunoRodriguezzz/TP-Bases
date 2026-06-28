-- Vista 1
CREATE VIEW BI_Ticket_Promedio AS
SELECT 
    t.Año,
    t.Mes,
    rc.desde AS Cliente_Edad_Desde,
    rc.hasta AS Cliente_Edad_Hasta,
    cv.Descripcion AS Canal_Venta,
    str(AVG(v.importe_total),15,2) AS Ticket_Promedio
FROM Hecho_Venta v
JOIN DIM_Tiempo t ON v.Tiempo = t.ID
JOIN DIM_RangoECliente rc ON v.RangoEtarioCliente = rc.ID
JOIN DIM_CanalVenta cv ON v.CanalVenta = cv.id_canal
GROUP BY 
    t.Año, 
    t.Mes, 
    rc.desde, 
    rc.hasta, 
    cv.Descripcion;
GO 

-- Vista 2
CREATE VIEW BI_Distribucion_Facturacion AS
SELECT 
    t.Año,
    t.Cuatrimestre,
    ts.descripcion AS Tipo_Servicio,
    SUM(v.importe_total) AS Facturacion_Absoluta,
    -- Calculamos el % dividiendo el total del servicio por el gran total del cuatrimestre
    str(SUM(v.importe_total) * 100 /(SELECT SUM(v2.importe_total)FROM Hecho_Venta v2 JOIN DIM_Tiempo t2 ON v2.Tiempo = t2.ID WHERE t2.Año = t.Año AND t2.Cuatrimestre = t.Cuatrimestre),15,2) AS Porcentaje_Facturacion
FROM Hecho_Venta v
JOIN DIM_Tiempo t ON v.Tiempo = t.ID
JOIN DIM_TipoServicio ts ON v.TipoServicio = ts.ID
GROUP BY 
    t.Año, 
    t.Cuatrimestre, 
    ts.descripcion;
GO 

-- Vista 3

CREATE VIEW BI_Ranking_Solicitudes_Temporada AS
SELECT 
    t.Año,
    temp.descripcion AS Temporada,
    rc.desde AS Cliente_Edad_Desde,
    rc.hasta AS Cliente_Edad_Hasta,
    COUNT(s.id_solicitud) AS Cantidad_Solicitudes
FROM Hecho_Solicitud s
JOIN DIM_Tiempo t ON s.Tiempo = t.ID
JOIN DIM_Temporada temp ON s.Temporada = temp.ID
JOIN DIM_RangoECliente rc ON s.RangoEtarioCliente = rc.ID
GROUP BY 
    t.Año,
    temp.descripcion,
    rc.desde,
    rc.hasta;
GO

-- Vista 4

CREATE VIEW BI_Anticipacion_Promedio_Solicitudes AS
SELECT 
    t.Año,
    t.Cuatrimestre,
    rc.desde AS Cliente_Edad_Desde,
    rc.hasta AS Cliente_Edad_Hasta,
    AVG(DATEDIFF(DAY, s.fecha_solicitud, s.fecha_inicio_tentativa)) AS Anticipacion_Promedio_Dias
FROM Hecho_Solicitud s
JOIN DIM_Tiempo t ON s.Tiempo = t.ID
JOIN DIM_RangoECliente rc ON s.RangoEtarioCliente = rc.ID
GROUP BY 
    t.Año,
    t.Cuatrimestre,
    rc.desde,
    rc.hasta;
GO

-- Vista 5

CREATE VIEW BI_Tasa_Aceptacion_Propuestas AS
SELECT 
    t.Año,
    t.Cuatrimestre,
    ep.Descripcion AS Estado_Propuesta,
    COUNT(p.id_propuesta) AS Cantidad_Absoluta,
    str((COUNT(p.id_propuesta) * 100.0 / (SELECT COUNT(p2.id_propuesta) FROM Hecho_Propuesta p2 JOIN DIM_Tiempo t2 ON p2.Tiempo = t2.ID WHERE t2.Año = t.Año AND t2.Cuatrimestre = t.Cuatrimestre)),5,2) AS Tasa_Porcentaje

FROM Hecho_Propuesta p
JOIN DIM_Tiempo t ON p.Tiempo = t.ID
JOIN DIM_EstadoPropuesta ep ON p.EstadoPropuesta = ep.id_estado
GROUP BY 
    t.Año,
    t.Cuatrimestre,
    ep.Descripcion;
GO

-- Vista 6

CREATE VIEW BI_Cotizacion_Promedio_Temporada AS
SELECT 
    t.Año,
    temp.descripcion AS Temporada,
    str(AVG(p.importe_total),18,2) AS Cotizacion_Promedio
FROM Hecho_Propuesta p
JOIN DIM_Tiempo t ON p.Tiempo = t.ID
JOIN DIM_Temporada temp ON p.Temporada = temp.ID
GROUP BY 
    t.Año,
    temp.descripcion;
GO
