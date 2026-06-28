-- VISTAS

-- Vista 7 - Tiempo promedio de respuesta

CREATE VIEW BI_Tiempo_promedio_de_respuesta AS
SELECT
    h.RangoEtarioAgente,
    t.Mes,
    AVG(h.tiempo_respuesta_dias)
FROM Hecho_Propuesta h
JOIN DIM_Tiempo t on h.Tiempo = t.ID
GROUP BY h.RangoEtarioAgente, t.Mes
GO

-- Vista 8 - Desvío de presupuesto

CREATE VIEW BI_Desvio_de_presupuesto AS
SELECT
    AVG(h.desvio_presupuesto)
FROM Hecho_Propuesta h
GO

-- Vista 9 - Ranking de aspectos mejor y peor valorados

CREATE VIEW BI_Ranking_de_aspectos_mejor_y_peor_valorados AS
SELECT
    h.Aspecto,
    t.Cuatrimestre,
    AVG(h.Puntaje)
FROM Hecho_Valoracion_Encuesta h
JOIN DIM_Tiempo t on t.ID = h.Tiempo
GROUP BY h.RangoEtarioAgente, t.Mes
GO

-- Vista 10 - Satisfacción promedio por agente

CREATE VIEW BI_SatisfaccionPromedioPorAgente AS
SELECT 
    h.RangoEtarioAgente,
    t.Mes,
    AVG(h.Puntaje)
FROM Hecho_Valoracion_Encuesta h
JOIN DIM_Tiempo t on h.Tiempo = t.ID
GROUP BY h.RangoEtarioAgente, t.Mes
GO