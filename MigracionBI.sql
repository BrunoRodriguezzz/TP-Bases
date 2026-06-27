USE [GD1C2026];
GO

-- ==========================================
-- DIMENSIONES
-- ==========================================

CREATE TABLE DIM_RangoEAgente (
    ID int IDENTITY(1,1) PRIMARY KEY,
    desde int NOT NULL,
    hasta int NOT NULL
);

CREATE TABLE DIM_RangoECliente (
    ID int IDENTITY(1,1) PRIMARY KEY,
    desde int NOT NULL,
    hasta int NOT NULL
);

CREATE TABLE DIM_Tiempo (
    ID int PRIMARY KEY, -- Generalmente se usa formato YYYYMMDD
    Año int NOT NULL,
    Cuatrimestre int NOT NULL,
    Mes int NOT NULL
);

CREATE TABLE DIM_Temporada (
    ID int IDENTITY(1,1) PRIMARY KEY,
    descripcion varchar(255) NOT NULL,
    desde_mes int NOT NULL,
    hasta_mes int NOT NULL
);

CREATE TABLE DIM_TipoServicio (
    ID int IDENTITY(1,1) PRIMARY KEY,
    descripcion nvarchar(50) NOT NULL
);

-- Estas dimensiones provienen de tu DER transaccional
CREATE TABLE DIM_CanalVenta (
    id_canal bigint PRIMARY KEY,
    Descripcion varchar(255) NOT NULL
);

CREATE TABLE DIM_Aspecto (
    id_aspecto bigint PRIMARY KEY,
    Descripcion varchar(255) NOT NULL
);

CREATE TABLE DIM_EstadoPropuesta (
    id_estado bigint PRIMARY KEY,
    Descripcion varchar(255) NOT NULL
);

-- ==========================================
-- HECHOS
-- ==========================================

CREATE TABLE Hecho_Valoracion_Encuesta (
    id_encuesta       bigint,
    Tiempo            int,
    Aspecto           bigint,
    RangoEtarioAgente int,
    Puntaje           int,
    CONSTRAINT PK_Hecho_Valoracion_Encuesta PRIMARY KEY (id_encuesta, Aspecto),
    FOREIGN KEY (Tiempo)            REFERENCES DIM_Tiempo(ID),
    FOREIGN KEY (Aspecto)           REFERENCES DIM_Aspecto(id_aspecto),
    FOREIGN KEY (RangoEtarioAgente) REFERENCES DIM_RangoEAgente(ID)
);
GO

CREATE TABLE Hecho_Propuesta (
    id_propuesta bigint PRIMARY KEY,
    Tiempo int,
    RangoEtarioAgente int,
    Temporada int,
    EstadoPropuesta bigint,
    importe_total decimal(18,2),
    tiempo_respuesta_dias int, 
    desvio_presupuesto decimal(18,2),
    FOREIGN KEY (Tiempo) REFERENCES DIM_Tiempo(ID),
    FOREIGN KEY (RangoEtarioAgente) REFERENCES DIM_RangoEAgente(ID),
    FOREIGN KEY (Temporada) REFERENCES DIM_Temporada(ID),
    FOREIGN KEY (EstadoPropuesta) REFERENCES DIM_EstadoPropuesta(id_estado)
);

CREATE TABLE Hecho_Solicitud (
    id_solicitud bigint PRIMARY KEY,
    Tiempo int,
    RangoEtarioAgente int,
    RangoEtarioCliente int,
    Temporada int,
    fecha_solicitud date,
    fecha_inicio_tentativa date,
    FOREIGN KEY (Tiempo) REFERENCES DIM_Tiempo(ID),
    FOREIGN KEY (RangoEtarioAgente) REFERENCES DIM_RangoEAgente(ID),
    FOREIGN KEY (RangoEtarioCliente) REFERENCES DIM_RangoECliente(ID),
    FOREIGN KEY (Temporada) REFERENCES DIM_Temporada(ID)
);

CREATE TABLE Hecho_Venta (
    id_venta bigint PRIMARY KEY,
    Tiempo int,
    RangoEtarioAgente int,
    RangoEtarioCliente int,
    Temporada int,
    CanalVenta bigint,
    TipoServicio int,
    importe_total decimal(18,2),
    FOREIGN KEY (Tiempo) REFERENCES DIM_Tiempo(ID),
    FOREIGN KEY (RangoEtarioAgente) REFERENCES DIM_RangoEAgente(ID),
    FOREIGN KEY (RangoEtarioCliente) REFERENCES DIM_RangoECliente(ID),
    FOREIGN KEY (Temporada) REFERENCES DIM_Temporada(ID),
    FOREIGN KEY (CanalVenta) REFERENCES DIM_CanalVenta(id_canal),
    FOREIGN KEY (TipoServicio) REFERENCES DIM_TipoServicio(ID)
);

-- ============================================================
-- 1) FUNCIONES AUXILIARES
-- ============================================================

IF OBJECT_ID('dbo.fn_CalcularEdad') IS NOT NULL DROP FUNCTION dbo.fn_CalcularEdad;
GO
CREATE FUNCTION dbo.fn_CalcularEdad(@FechaNacimiento DATE, @FechaReferencia DATE)
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

-- Bordes inclusivos del lado "menor": 25 -> primer rango, 35 -> segundo, 50 -> tercero
IF OBJECT_ID('dbo.fn_RangoEtarioCliente') IS NOT NULL DROP FUNCTION dbo.fn_RangoEtarioCliente;
GO
CREATE FUNCTION dbo.fn_RangoEtarioCliente(@Edad INT)
RETURNS INT
AS
BEGIN
    DECLARE @ID INT;
    IF @Edad IS NULL RETURN NULL;

    SELECT @ID = CASE
        WHEN @Edad <= 25 THEN (SELECT ID FROM DIM_RangoECliente WHERE desde = 0  AND hasta = 25)
        WHEN @Edad <= 35 THEN (SELECT ID FROM DIM_RangoECliente WHERE desde = 25 AND hasta = 35)
        WHEN @Edad <= 50 THEN (SELECT ID FROM DIM_RangoECliente WHERE desde = 35 AND hasta = 50)
        ELSE                  (SELECT ID FROM DIM_RangoECliente WHERE desde = 50)
    END;
    RETURN @ID;
END
GO

IF OBJECT_ID('dbo.fn_RangoEtarioAgente') IS NOT NULL DROP FUNCTION dbo.fn_RangoEtarioAgente;
GO
CREATE FUNCTION dbo.fn_RangoEtarioAgente(@Edad INT)
RETURNS INT
AS
BEGIN
    DECLARE @ID INT;
    IF @Edad IS NULL RETURN NULL;

    -- Nota: el enunciado no define rango para agentes menores de 25.
    -- Por defecto, caen en el primer rango definido (25-35).
    SELECT @ID = CASE
        WHEN @Edad <= 35 THEN (SELECT ID FROM DIM_RangoEAgente WHERE desde = 25 AND hasta = 35)
        WHEN @Edad <= 50 THEN (SELECT ID FROM DIM_RangoEAgente WHERE desde = 35 AND hasta = 50)
        ELSE                  (SELECT ID FROM DIM_RangoEAgente WHERE desde = 50)
    END;
    RETURN @ID;
END
GO

IF OBJECT_ID('dbo.fn_Temporada') IS NOT NULL DROP FUNCTION dbo.fn_Temporada;
GO
CREATE FUNCTION dbo.fn_Temporada(@Mes INT)
RETURNS INT
AS
BEGIN
    IF @Mes IS NULL RETURN NULL;
    RETURN (SELECT ID FROM DIM_Temporada WHERE @Mes BETWEEN desde_mes AND hasta_mes);
END
GO

-- ============================================================
-- 2) CARGA DE DIMENSIONES
-- ============================================================

INSERT INTO DIM_RangoEAgente (desde, hasta) VALUES
    (25, 35),
    (35, 50),
    (50, 150);   -- 150 = sentinela de "sin tope superior"

INSERT INTO DIM_RangoECliente (desde, hasta) VALUES
    (0, 25),
    (25, 35),
    (35, 50),
    (50, 150);

INSERT INTO DIM_Temporada (descripcion, desde_mes, hasta_mes) VALUES
    ('Verano',    1, 3),
    ('Otoño',     4, 6),
    ('Invierno',  7, 9),
    ('Primavera', 10, 12);

INSERT INTO DIM_TipoServicio (descripcion) VALUES
    ('Venta Directa'),
    ('Propuesta a Medida');

INSERT INTO DIM_CanalVenta (id_canal, Descripcion)
SELECT id_canal, descripcion
FROM QUEQUE.CanalVenta;

INSERT INTO DIM_Aspecto (id_aspecto, Descripcion)
SELECT id_aspecto, descripcion
FROM QUEQUE.AspectoValorado;

INSERT INTO DIM_EstadoPropuesta (id_estado, Descripcion)
SELECT id_estado, descripcion
FROM QUEQUE.EstadoPropuesta;

-- DIM_Tiempo: una fila por cada fecha distinta que aparece en las
-- fuentes usadas por los hechos (solicitud, propuesta, venta, encuesta)
INSERT INTO DIM_Tiempo (ID, Año, Cuatrimestre, Mes)
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
    SELECT fecha_venta     AS Fecha FROM QUEQUE.Venta               WHERE fecha_venta     IS NOT NULL
    UNION
    SELECT fecha           AS Fecha FROM QUEQUE.Encuesta            WHERE fecha           IS NOT NULL
) AS Fechas;
GO

-- ============================================================
-- 3) CARGA DE HECHOS
-- ============================================================

-- 3.1) Hecho_Valoracion_Encuesta
INSERT INTO Hecho_Valoracion_Encuesta (id_encuesta, Tiempo, Aspecto, RangoEtarioAgente, Puntaje)
SELECT
    ve.id_encuesta,
    YEAR(e.fecha) * 10000 + MONTH(e.fecha) * 100 + DATEPART(QUARTER, Fecha)     AS Tiempo,
    ve.id_aspecto                                                               AS Aspecto,
    dbo.fn_RangoEtarioAgente(dbo.fn_CalcularEdad(ag.fecha_nacimiento, e.fecha)) AS RangoEtarioAgente,
    ve.puntaje                                                                  AS Puntaje
FROM QUEQUE.ValoracionEncuesta ve
JOIN QUEQUE.Encuesta e  ON e.id_encuesta = ve.id_encuesta
JOIN QUEQUE.Agente   ag ON ag.legajo     = e.id_agente
WHERE e.fecha IS NOT NULL;

-- 3.2) Hecho_Propuesta
-- Temporada según fecha_desde (inicio del viaje propuesto, no la emisión)
INSERT INTO Hecho_Propuesta (
    id_propuesta, Tiempo, RangoEtarioAgente, Temporada, EstadoPropuesta,
    importe_total, tiempo_respuesta_dias, desvio_presupuesto
)
SELECT
    p.id_propuesta,
    YEAR(p.fecha_emision) * 10000 + MONTH(p.fecha_emision) * 100 + DAY(p.fecha_emision) AS Tiempo,
    dbo.fn_RangoEtarioAgente(dbo.fn_CalcularEdad(ag.fecha_nacimiento, p.fecha_emision))  AS RangoEtarioAgente,
    dbo.fn_Temporada(MONTH(p.fecha_desde))                                               AS Temporada,
    p.id_estado                                                                          AS EstadoPropuesta,
    p.importe_total,
    DATEDIFF(DAY, s.fecha_solicitud, p.fecha_emision)                                    AS tiempo_respuesta_dias,
    p.importe_total - s.presupuesto_estimado                                             AS desvio_presupuesto
FROM QUEQUE.Propuesta p
JOIN QUEQUE.Agente ag               ON ag.legajo     = p.id_agente
JOIN QUEQUE.SolicitudCotizacion s   ON s.nro_solicitud = p.nro_solicitud
WHERE p.fecha_emision IS NOT NULL AND p.fecha_desde IS NOT NULL;

-- 3.3) Hecho_Solicitud
-- Temporada según fecha_inicio_tentativa (cuándo quiere viajar el cliente)
INSERT INTO Hecho_Solicitud (
    id_solicitud, Tiempo, RangoEtarioAgente, RangoEtarioCliente, Temporada,
    fecha_solicitud, fecha_inicio_tentativa
)
SELECT
    s.nro_solicitud,
    YEAR(s.fecha_solicitud) * 10000 + MONTH(s.fecha_solicitud) * 100 + DAY(s.fecha_solicitud) AS Tiempo,
    dbo.fn_RangoEtarioAgente(dbo.fn_CalcularEdad(ag.fecha_nacimiento, s.fecha_solicitud))      AS RangoEtarioAgente,
    dbo.fn_RangoEtarioCliente(dbo.fn_CalcularEdad(c.fecha_nacimiento, s.fecha_solicitud))      AS RangoEtarioCliente,
    dbo.fn_Temporada(MONTH(s.fecha_inicio_tentativa))                                          AS Temporada,
    s.fecha_solicitud,
    s.fecha_inicio_tentativa
FROM QUEQUE.SolicitudCotizacion s
JOIN QUEQUE.Agente ag  ON ag.legajo    = s.id_agente
JOIN QUEQUE.Cliente c  ON c.id_cliente = s.id_cliente
WHERE s.fecha_solicitud IS NOT NULL AND s.fecha_inicio_tentativa IS NOT NULL;

-- 3.4) Hecho_Venta
-- TipoServicio: "Propuesta a Medida" si la venta viene de una Propuesta
-- (existe en Venta_X_Propuesta), si no "Venta Directa"
INSERT INTO Hecho_Venta (
    id_venta, Tiempo, RangoEtarioAgente, RangoEtarioCliente, Temporada,
    CanalVenta, TipoServicio, importe_total
)
SELECT
    v.nro_venta,
    YEAR(v.fecha_venta) * 10000 + MONTH(v.fecha_venta) * 100 + DAY(v.fecha_venta)       AS Tiempo,
    dbo.fn_RangoEtarioAgente(dbo.fn_CalcularEdad(ag.fecha_nacimiento, v.fecha_venta))    AS RangoEtarioAgente,
    dbo.fn_RangoEtarioCliente(dbo.fn_CalcularEdad(c.fecha_nacimiento, v.fecha_venta))    AS RangoEtarioCliente,
    dbo.fn_Temporada(MONTH(v.fecha_venta))                                               AS Temporada,
    v.id_canal                                                                          AS CanalVenta,
    (
        SELECT ID FROM DIM_TipoServicio
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
-- 4) CONTROL RAPIDO (opcional, para verificar que no haya quedado nada afuera)
-- ============================================================
SELECT 'SolicitudCotizacion' AS Tabla, COUNT(*) AS Origen,
       (SELECT COUNT(*) FROM Hecho_Solicitud) AS Migrado
FROM QUEQUE.SolicitudCotizacion
UNION ALL
SELECT 'Propuesta', COUNT(*), (SELECT COUNT(*) FROM Hecho_Propuesta) FROM QUEQUE.Propuesta
UNION ALL
SELECT 'Venta', COUNT(*), (SELECT COUNT(*) FROM Hecho_Venta) FROM QUEQUE.Venta
UNION ALL
SELECT 'ValoracionEncuesta', COUNT(*), (SELECT COUNT(*) FROM Hecho_Valoracion_Encuesta) FROM QUEQUE.ValoracionEncuesta;