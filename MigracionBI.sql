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
    id_encuesta bigint PRIMARY KEY,
    Tiempo int,
    Aspecto bigint,
    RangoEtarioAgente int,
    Puntaje int, 
    FOREIGN KEY (Tiempo) REFERENCES DIM_Tiempo(ID),
    FOREIGN KEY (Aspecto) REFERENCES DIM_Aspecto(id_aspecto),
    FOREIGN KEY (RangoEtarioAgente) REFERENCES DIM_RangoEAgente(ID)
);

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