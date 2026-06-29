USE [GD1C2026];
GO

-- ==========================================
-- DIMENSIONES
-- ==========================================

CREATE TABLE QUEQUE.BI_DIM_RangoEAgente (
    ID int IDENTITY(1,1) PRIMARY KEY,
    desde int NOT NULL,
    hasta int NOT NULL
);

CREATE TABLE QUEQUE.BI_DIM_RangoECliente (
    ID int IDENTITY(1,1) PRIMARY KEY,
    desde int NOT NULL,
    hasta int NOT NULL
);

CREATE TABLE QUEQUE.BI_DIM_Tiempo (
    ID int PRIMARY KEY, 
    Año int NOT NULL,
    Cuatrimestre int NOT NULL,
    Mes int NOT NULL
);

CREATE TABLE QUEQUE.BI_DIM_Temporada (
    ID int IDENTITY(1,1) PRIMARY KEY,
    descripcion varchar(255) NOT NULL,
    desde_mes int NOT NULL,
    hasta_mes int NOT NULL
);

CREATE TABLE QUEQUE.BI_DIM_TipoServicio (
    ID int IDENTITY(1,1) PRIMARY KEY,
    descripcion nvarchar(50) NOT NULL
);

-- Estas dimensiones provienen de tu DER transaccional
CREATE TABLE QUEQUE.BI_DIM_CanalVenta (
    id_canal bigint PRIMARY KEY,
    Descripcion varchar(255) NOT NULL
);

CREATE TABLE QUEQUE.BI_DIM_Aspecto (
    id_aspecto bigint PRIMARY KEY,
    Descripcion varchar(255) NOT NULL
);

CREATE TABLE QUEQUE.BI_DIM_EstadoPropuesta (
    id_estado bigint PRIMARY KEY,
    Descripcion varchar(255) NOT NULL
);

-- ==========================================
-- HECHOS
-- ==========================================

CREATE TABLE QUEQUE.BI_Hecho_Valoracion_Encuesta (
    id_encuesta       bigint,
    Tiempo            int,
    Aspecto           bigint,
    RangoEtarioAgente int,
    Puntaje           int,
    CONSTRAINT PK_Hecho_Valoracion_Encuesta PRIMARY KEY (id_encuesta, Aspecto),
    FOREIGN KEY (Tiempo)            REFERENCES QUEQUE.BI_DIM_Tiempo(ID),
    FOREIGN KEY (Aspecto)           REFERENCES QUEQUE.BI_DIM_Aspecto(id_aspecto),
    FOREIGN KEY (RangoEtarioAgente) REFERENCES QUEQUE.BI_DIM_RangoEAgente(ID)
);
GO

CREATE TABLE QUEQUE.BI_Hecho_Propuesta (
    id_propuesta bigint PRIMARY KEY,
    Tiempo int,
    RangoEtarioAgente int,
    Temporada int,
    TiempoInicioViaje int,
    TemporadaInicio int,
    EstadoPropuesta bigint,
    importe_total decimal(18,2),
    tiempo_respuesta_dias int, 
    desvio_presupuesto decimal(18,2),
    FOREIGN KEY (Tiempo) REFERENCES QUEQUE.BI_DIM_Tiempo(ID),
    FOREIGN KEY (RangoEtarioAgente) REFERENCES QUEQUE.BI_DIM_RangoEAgente(ID),
    FOREIGN KEY (Temporada) REFERENCES QUEQUE.BI_DIM_Temporada(ID),
    FOREIGN KEY (EstadoPropuesta) REFERENCES QUEQUE.BI_DIM_EstadoPropuesta(id_estado)
);

CREATE TABLE QUEQUE.BI_Hecho_Solicitud (
    id_solicitud bigint PRIMARY KEY,
    Tiempo int,
    RangoEtarioAgente int,
    RangoEtarioCliente int,
    Temporada int,
    fecha_solicitud date,
    fecha_inicio_tentativa date,
    FOREIGN KEY (Tiempo) REFERENCES QUEQUE.BI_DIM_Tiempo(ID),
    FOREIGN KEY (RangoEtarioAgente) REFERENCES QUEQUE.BI_DIM_RangoEAgente(ID),
    FOREIGN KEY (RangoEtarioCliente) REFERENCES QUEQUE.BI_DIM_RangoECliente(ID),
    FOREIGN KEY (Temporada) REFERENCES QUEQUE.BI_DIM_Temporada(ID)
);

CREATE TABLE QUEQUE.BI_Hecho_Venta (
    id_venta bigint PRIMARY KEY,
    Tiempo int,
    RangoEtarioAgente int,
    RangoEtarioCliente int,
    Temporada int,
    CanalVenta bigint,
    TipoServicio int,
    importe_total decimal(18,2),
    FOREIGN KEY (Tiempo) REFERENCES QUEQUE.BI_DIM_Tiempo(ID),
    FOREIGN KEY (RangoEtarioAgente) REFERENCES QUEQUE.BI_DIM_RangoEAgente(ID),
    FOREIGN KEY (RangoEtarioCliente) REFERENCES QUEQUE.BI_DIM_RangoECliente(ID),
    FOREIGN KEY (Temporada) REFERENCES QUEQUE.BI_DIM_Temporada(ID),
    FOREIGN KEY (CanalVenta) REFERENCES QUEQUE.BI_DIM_CanalVenta(id_canal),
    FOREIGN KEY (TipoServicio) REFERENCES QUEQUE.BI_DIM_TipoServicio(ID)
);
GO
-- ============================================================
-- 1) FUNCIONES AUXILIARES
-- ============================================================

CREATE FUNCTION QUEQUE.fn_CalcularEdad(@FechaNacimiento DATE, @FechaReferencia DATE)
RETURNS INT
AS
BEGIN
    IF @FechaNacimiento IS NULL OR @FechaReferencia IS NULL
        RETURN NULL;

    RETURN DATEDIFF(YEAR, @FechaNacimiento, @FechaReferencia)
         - CASE WHEN (MONTH(@FechaNacimiento) * 100 + DAY(@FechaNacimiento))
                   > (MONTH(@FechaReferencia)  * 100 + DAY(@FechaReferencia))
                THEN 1 ELSE 0 END;
END
GO


CREATE FUNCTION QUEQUE.fn_RangoEtarioCliente(@Edad INT)
RETURNS INT
AS
BEGIN
    DECLARE @ID INT;
    IF @Edad IS NULL RETURN NULL;

    SELECT @ID = CASE
        WHEN @Edad <= 25 THEN (SELECT ID FROM BI_DIM_RangoECliente WHERE desde = 0  AND hasta = 25)
        WHEN @Edad <= 35 THEN (SELECT ID FROM BI_DIM_RangoECliente WHERE desde = 25 AND hasta = 35)
        WHEN @Edad <= 50 THEN (SELECT ID FROM BI_DIM_RangoECliente WHERE desde = 35 AND hasta = 50)
        ELSE                  (SELECT ID FROM BI_DIM_RangoECliente WHERE desde = 50)
    END;
    RETURN @ID;
END
GO

CREATE FUNCTION QUEQUE.fn_RangoEtarioAgente(@Edad INT)
RETURNS INT
AS
BEGIN
    DECLARE @ID INT;
    IF @Edad IS NULL RETURN NULL;

    SELECT @ID = CASE
        WHEN @Edad <= 35 THEN (SELECT ID FROM BI_DIM_RangoEAgente WHERE desde = 25 AND hasta = 35)
        WHEN @Edad <= 50 THEN (SELECT ID FROM BI_DIM_RangoEAgente WHERE desde = 35 AND hasta = 50)
        ELSE                  (SELECT ID FROM BI_DIM_RangoEAgente WHERE desde = 50)
    END;
    RETURN @ID;
END
GO

CREATE FUNCTION QUEQUE.fn_Temporada(@Mes INT)
RETURNS INT
AS
BEGIN
    IF @Mes IS NULL RETURN NULL;
    RETURN (SELECT ID FROM BI_DIM_Temporada WHERE @Mes BETWEEN desde_mes AND hasta_mes);
END
GO

-- ============================================================
-- 2) CARGA DE DIMENSIONES
-- ============================================================

INSERT INTO QUEQUE.BI_DIM_RangoEAgente (desde, hasta) VALUES
    (25, 35),
    (35, 50),
    (50, 150);   -- 150 = sentinela de "sin tope superior"

INSERT INTO QUEQUE.BI_DIM_RangoECliente (desde, hasta) VALUES
    (0, 25),
    (25, 35),
    (35, 50),
    (50, 150);

INSERT INTO QUEQUE.BI_DIM_Temporada (descripcion, desde_mes, hasta_mes) VALUES
    ('Verano',    1, 3),
    ('Otoño',     4, 6),
    ('Invierno',  7, 9),
    ('Primavera', 10, 12);

INSERT INTO QUEQUE.BI_DIM_TipoServicio (descripcion) VALUES
    ('Venta Directa'),
    ('Propuesta a Medida');

INSERT INTO QUEQUE.BI_DIM_CanalVenta (id_canal, Descripcion)
SELECT id_canal, descripcion
FROM QUEQUE.CanalVenta;

INSERT INTO QUEQUE.BI_DIM_Aspecto (id_aspecto, Descripcion)
SELECT id_aspecto, descripcion
FROM QUEQUE.AspectoValorado;

INSERT INTO QUEQUE.BI_DIM_EstadoPropuesta (id_estado, Descripcion)
SELECT id_estado, descripcion
FROM QUEQUE.EstadoPropuesta;

-- DIM_Tiempo: una fila por cada fecha distinta que aparece en las
-- fuentes usadas por los hechos (solicitud, propuesta, venta, encuesta)
INSERT INTO QUEQUE.BI_DIM_Tiempo (ID, Año, Cuatrimestre, Mes)
SELECT DISTINCT
    YEAR(Fecha) * 10000 + MONTH(Fecha) * 100 + DATEPART(QUARTER, Fecha) AS ID,
    YEAR(Fecha)                                                         AS Año,
    DATEPART(QUARTER, Fecha)                                            AS Cuatrimestre,
    MONTH(Fecha)                                                        AS Mes
FROM (
    SELECT fecha_solicitud AS Fecha FROM QUEQUE.SolicitudCotizacion WHERE fecha_solicitud IS NOT NULL
    UNION
    SELECT fecha_emision   AS Fecha FROM QUEQUE.Propuesta           WHERE fecha_emision   IS NOT NULL
    UNION
    SELECT fecha_desde     AS Fecha FROM QUEQUE.Propuesta           WHERE fecha_desde     IS NOT NULL
    UNION
    SELECT fecha_venta     AS Fecha FROM QUEQUE.Venta               WHERE fecha_venta     IS NOT NULL
    UNION
    SELECT fecha           AS Fecha FROM QUEQUE.Encuesta            WHERE fecha           IS NOT NULL
) AS Fechas;
GO

-- ============================================================
-- 3) CARGA DE HECHOS
-- ============================================================

-- 3.1) Hecho_Valoracion_Encuesta
INSERT INTO QUEQUE.BI_Hecho_Valoracion_Encuesta (id_encuesta, Tiempo, Aspecto, RangoEtarioAgente, Puntaje)
SELECT
    ve.id_encuesta,
    YEAR(e.fecha) * 10000 + MONTH(e.fecha) * 100 + DATEPART(QUARTER, Fecha)     AS Tiempo,
    ve.id_aspecto                                                               AS Aspecto,
    QUEQUE.fn_RangoEtarioAgente(QUEQUE.fn_CalcularEdad(ag.fecha_nacimiento, e.fecha)) AS RangoEtarioAgente,
    ve.puntaje                                                                  AS Puntaje
FROM QUEQUE.ValoracionEncuesta ve
JOIN QUEQUE.Encuesta e  ON e.id_encuesta = ve.id_encuesta
JOIN QUEQUE.Agente   ag ON ag.legajo     = e.id_agente
WHERE e.fecha IS NOT NULL;

-- 3.2) Hecho_Propuesta
-- Temporada según fecha_desde (inicio del viaje propuesto, no la emisión)
INSERT INTO QUEQUE.BI_Hecho_Propuesta (
    id_propuesta, Tiempo, TiempoInicioViaje, RangoEtarioAgente, Temporada, EstadoPropuesta,
    importe_total, tiempo_respuesta_dias, desvio_presupuesto, TemporadaInicio
)
SELECT
    p.id_propuesta,
    YEAR(p.fecha_emision) * 10000 + MONTH(p.fecha_emision) * 100 + DATEPART(QUARTER, p.fecha_emision) AS Tiempo,
    YEAR(p.fecha_desde)   * 10000 + MONTH(p.fecha_desde)   * 100 + DATEPART(QUARTER, p.fecha_desde)   AS TiempoInicioViaje,
    QUEQUE.fn_RangoEtarioAgente(QUEQUE.fn_CalcularEdad(ag.fecha_nacimiento, p.fecha_emision))               AS RangoEtarioAgente,
    QUEQUE.fn_Temporada(MONTH(p.fecha_emision))                                                          AS Temporada,
    p.id_estado                                                                                       AS EstadoPropuesta,
    p.importe_total,
    DATEDIFF(DAY, s.fecha_solicitud, p.fecha_emision)                                                 AS tiempo_respuesta_dias,
    p.importe_total - s.presupuesto_estimado                                                          AS desvio_presupuesto,
    QUEQUE.fn_Temporada(MONTH(p.fecha_desde))                                                            AS TemporadaInicio
FROM QUEQUE.Propuesta p
JOIN QUEQUE.Agente ag             ON ag.legajo       = p.id_agente
JOIN QUEQUE.SolicitudCotizacion s ON s.nro_solicitud = p.nro_solicitud
WHERE p.fecha_emision IS NOT NULL AND p.fecha_desde IS NOT NULL;

-- 3.3) Hecho_Solicitud
-- Temporada según fecha_inicio_tentativa (cuándo quiere viajar el cliente)
INSERT INTO QUEQUE.BI_Hecho_Solicitud (
    id_solicitud, Tiempo, RangoEtarioAgente, RangoEtarioCliente, Temporada,
    fecha_solicitud, fecha_inicio_tentativa
)
SELECT
    s.nro_solicitud,
    YEAR(s.fecha_solicitud) * 10000 + MONTH(s.fecha_solicitud) * 100 + DATEPART(QUARTER,s.fecha_solicitud) AS Tiempo,
    QUEQUE.fn_RangoEtarioAgente(QUEQUE.fn_CalcularEdad(ag.fecha_nacimiento, s.fecha_solicitud))      AS RangoEtarioAgente,
    QUEQUE.fn_RangoEtarioCliente(QUEQUE.fn_CalcularEdad(c.fecha_nacimiento, s.fecha_solicitud))      AS RangoEtarioCliente,
    QUEQUE.fn_Temporada(MONTH(s.fecha_inicio_tentativa))                                          AS Temporada,
    s.fecha_solicitud,
    s.fecha_inicio_tentativa
FROM QUEQUE.SolicitudCotizacion s
JOIN QUEQUE.Agente ag  ON ag.legajo    = s.id_agente
JOIN QUEQUE.Cliente c  ON c.id_cliente = s.id_cliente
WHERE s.fecha_solicitud IS NOT NULL AND s.fecha_inicio_tentativa IS NOT NULL;

-- 3.4) Hecho_Venta
-- TipoServicio: "Propuesta a Medida" si la venta viene de una Propuesta
-- (existe en Venta_X_Propuesta), si no "Venta Directa"
INSERT INTO QUEQUE.BI_Hecho_Venta (
    id_venta, Tiempo, RangoEtarioAgente, RangoEtarioCliente, Temporada,
    CanalVenta, TipoServicio, importe_total
)
SELECT
    v.nro_venta,
    YEAR(v.fecha_venta) * 10000 + MONTH(v.fecha_venta) * 100 + DATEPART(QUARTER,v.fecha_venta)       AS Tiempo,
    QUEQUE.fn_RangoEtarioAgente(QUEQUE.fn_CalcularEdad(ag.fecha_nacimiento, v.fecha_venta))    AS RangoEtarioAgente,
    QUEQUE.fn_RangoEtarioCliente(QUEQUE.fn_CalcularEdad(c.fecha_nacimiento, v.fecha_venta))    AS RangoEtarioCliente,
    QUEQUE.fn_Temporada(MONTH(v.fecha_venta))                                               AS Temporada,
    v.id_canal                                                                           AS CanalVenta,
    (
        SELECT ID FROM QUEQUE.BI_DIM_TipoServicio
        WHERE descripcion = CASE
            WHEN EXISTS (
                SELECT 1 FROM QUEQUE.Venta_X_Propuesta vxp WHERE vxp.nro_venta = v.nro_venta
            ) THEN 'Propuesta a Medida'
            ELSE 'Venta Directa'
        END
    )                                                                                   AS TipoServicio,
    v.importe_total
FROM QUEQUE.Venta v
JOIN QUEQUE.Agente ag  ON ag.legajo    = v.id_agente
JOIN QUEQUE.Cliente c  ON c.id_cliente = v.id_cliente
WHERE v.fecha_venta IS NOT NULL;
GO

-- ============================================================
-- 4) Creacion Vistas
-- ============================================================

-- Vista 1

CREATE VIEW QUEQUE.BI_Ticket_Promedio AS
SELECT 
    t.Año, t.Mes, v.RangoEtarioCliente, cv.Descripcion AS Canal_Venta,
    str(AVG(v.importe_total),15,2) AS Ticket_Promedio
FROM QUEQUE.BI_Hecho_Venta v
JOIN QUEQUE.BI_DIM_Tiempo t ON v.Tiempo = t.ID
JOIN QUEQUE.BI_DIM_CanalVenta cv ON v.CanalVenta = cv.id_canal
GROUP BY t.Año, t.Mes, cv.Descripcion, v.RangoEtarioCliente;
GO

-- Vista 2

CREATE VIEW QUEQUE.BI_Distribucion_Facturacion AS
SELECT 
    t.Año, t.Cuatrimestre, ts.descripcion AS Tipo_Servicio,
    SUM(v.importe_total) AS Facturacion_Absoluta,
    str(SUM(v.importe_total) * 100 /
        (SELECT SUM(v2.importe_total) FROM QUEQUE.BI_Hecho_Venta v2 
            JOIN QUEQUE.BI_DIM_Tiempo t2 ON v2.Tiempo = t2.ID WHERE t2.Año = t.Año AND t2.Cuatrimestre = t.Cuatrimestre),15,2) AS Porcentaje_Facturacion
FROM QUEQUE.BI_Hecho_Venta v
JOIN QUEQUE.BI_DIM_Tiempo t ON v.Tiempo = t.ID
JOIN QUEQUE.BI_DIM_TipoServicio ts ON v.TipoServicio = ts.ID
GROUP BY t.Año, t.Cuatrimestre, ts.descripcion;
GO

-- Vista 3

CREATE VIEW QUEQUE.BI_Ranking_Solicitudes_Temporada AS
SELECT 
    t.Año, temp.descripcion AS Temporada, s.RangoEtarioCliente,
    COUNT(s.id_solicitud) AS Cantidad_Solicitudes
FROM QUEQUE.BI_Hecho_Solicitud s
JOIN QUEQUE.BI_DIM_Tiempo t ON s.Tiempo = t.ID
JOIN QUEQUE.BI_DIM_Temporada temp ON s.Temporada = temp.ID
GROUP BY t.Año, temp.descripcion, s.RangoEtarioCliente
GO

-- Vista 4

CREATE VIEW QUEQUE.BI_Anticipacion_Promedio_Solicitudes AS
SELECT 
    t.Año, t.Cuatrimestre, s.RangoEtarioCliente,
    AVG(DATEDIFF(DAY, s.fecha_solicitud, s.fecha_inicio_tentativa)) AS Anticipacion_Promedio_Dias
FROM QUEQUE.BI_Hecho_Solicitud s
JOIN QUEQUE.BI_DIM_Tiempo t ON s.Tiempo = t.ID
GROUP BY t.Año, t.Cuatrimestre, s.RangoEtarioCliente
GO

-- Vista 5

CREATE VIEW QUEQUE.BI_Tasa_Aceptacion_Propuestas AS
SELECT 
    t.Año, t.Cuatrimestre, ep.Descripcion AS Estado_Propuesta,
    COUNT(p.id_propuesta) AS Cantidad_Absoluta,
    str((COUNT(p.id_propuesta) * 100.0 / 
        (SELECT COUNT(p2.id_propuesta) FROM QUEQUE.BI_Hecho_Propuesta p2 
            JOIN QUEQUE.BI_DIM_Tiempo t2 ON p2.Tiempo = t2.ID WHERE t2.Año = t.Año AND t2.Cuatrimestre = t.Cuatrimestre)),5,2) AS Tasa_Porcentaje
FROM QUEQUE.BI_Hecho_Propuesta p
JOIN QUEQUE.BI_DIM_Tiempo t ON p.Tiempo = t.ID
JOIN QUEQUE.BI_DIM_EstadoPropuesta ep ON p.EstadoPropuesta = ep.id_estado
GROUP BY t.Año, t.Cuatrimestre, ep.Descripcion;
GO

-- Vista 6

CREATE VIEW QUEQUE.BI_Cotizacion_Promedio_Temporada AS
SELECT 
    t.Año,
    temp.descripcion AS Temporada,
    str(AVG(p.importe_total),18,2) AS Cotizacion_Promedio
FROM QUEQUE.BI_Hecho_Propuesta p
JOIN QUEQUE.BI_DIM_Tiempo t ON p.TiempoInicioViaje = t.ID
JOIN QUEQUE.BI_DIM_Temporada temp ON p.TemporadaInicio = temp.ID
GROUP BY t.Año, temp.descripcion;
GO

-- Vista 7

CREATE VIEW QUEQUE.BI_Tiempo_promedio_de_respuesta AS
SELECT
    h.RangoEtarioAgente, t.Año, t.Mes,
    AVG(h.tiempo_respuesta_dias) AS promedio_tiempo_respuesta
FROM QUEQUE.BI_Hecho_Propuesta h
JOIN QUEQUE.BI_DIM_Tiempo t ON h.Tiempo = t.ID
GROUP BY h.RangoEtarioAgente, t.Año, t.Mes
GO

-- Vista 8

CREATE VIEW QUEQUE.BI_Desvio_de_presupuesto AS
SELECT
    AVG(h.desvio_presupuesto) AS promedio_desvio_presupuesto
FROM QUEQUE.BI_Hecho_Propuesta h
GO

-- Vista 9

CREATE VIEW QUEQUE.BI_Ranking_de_aspectos_mejor_y_peor_valorados AS
SELECT
    h.Aspecto, t.Año, t.Cuatrimestre,
    AVG(h.Puntaje) AS promedio_puntaje
FROM QUEQUE.BI_Hecho_Valoracion_Encuesta h
JOIN QUEQUE.BI_DIM_Tiempo t on t.ID = h.Tiempo
GROUP BY h.Aspecto, t.Año, t.Cuatrimestre
GO

--Vista 10

CREATE VIEW QUEQUE.BI_SatisfaccionPromedioPorAgente AS
SELECT 
    h.RangoEtarioAgente, t.Año, t.Mes,
    AVG(h.Puntaje) promedio_puntaje
FROM QUEQUE.BI_Hecho_Valoracion_Encuesta h
JOIN QUEQUE.BI_DIM_Tiempo t on h.Tiempo = t.ID
GROUP BY h.RangoEtarioAgente, t.Año, t.Mes
GO