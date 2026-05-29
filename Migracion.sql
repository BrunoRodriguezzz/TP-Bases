-- ============================================================
-- SCRIPT DE CREACION DE TABLAS
-- Schema: QUEQUE
-- Motor:   SQL Server
-- ============================================================

USE [GD1C2026];
GO

CREATE SCHEMA QUEQUE;
GO

-- ============================================================
-- MODULO GEOGRAFICO
-- ============================================================

CREATE TABLE QUEQUE.Pais (
    id_pais   BIGINT        IDENTITY(1,1) NOT NULL,
    nombre    NVARCHAR(255) NULL,
    CONSTRAINT PK_Pais PRIMARY KEY (id_pais)
);
GO

CREATE TABLE QUEQUE.Provincia (
    id_provincia BIGINT        IDENTITY(1,1) NOT NULL,
    prov_nombre  NVARCHAR(255) NULL,
    CONSTRAINT PK_Provincia PRIMARY KEY (id_provincia)
);
GO

CREATE TABLE QUEQUE.Ciudad (
    id_ciudad BIGINT        IDENTITY(1,1) NOT NULL,
    nombre    NVARCHAR(255) NULL,
    pais      BIGINT        NOT NULL,
    CONSTRAINT PK_Ciudad    PRIMARY KEY (id_ciudad),
    CONSTRAINT FK_Ciudad_Pais FOREIGN KEY (pais) REFERENCES QUEQUE.Pais(id_pais)
);
GO

-- ============================================================
-- MODULO AGENCIAS Y AGENTES
-- ============================================================

CREATE TABLE QUEQUE.Agencia (
    id_agencia BIGINT        NOT NULL,
    direccion  NVARCHAR(255) NULL,
    mail       NVARCHAR(255) NULL,
    telefono   NVARCHAR(255) NULL,
    localidad  NVARCHAR(255) NULL,
    provincia  BIGINT        NULL,
    CONSTRAINT PK_Agencia          PRIMARY KEY (id_agencia),
    CONSTRAINT FK_Agencia_Provincia FOREIGN KEY (provincia) REFERENCES QUEQUE.Provincia(id_provincia)
);
GO

CREATE TABLE QUEQUE.Agente (
    legajo           BIGINT        IDENTITY(1,1) NOT NULL,
    id_agencia       BIGINT        NOT NULL,
    nombre           NVARCHAR(255) NULL,
    apellido         NVARCHAR(255) NULL,
    dni              NVARCHAR(255) NULL,
    fecha_nacimiento DATE          NULL,
    telefono         NVARCHAR(255) NULL,
    mail             NVARCHAR(255) NULL,
    direccion        NVARCHAR(255) NULL,
    localidad        NVARCHAR(255) NULL,
    provincia        BIGINT        NULL,
    CONSTRAINT PK_Agente           PRIMARY KEY (legajo),
    CONSTRAINT FK_Agente_Agencia   FOREIGN KEY (id_agencia) REFERENCES QUEQUE.Agencia(id_agencia),
    CONSTRAINT FK_Agente_Provincia FOREIGN KEY (provincia)  REFERENCES QUEQUE.Provincia(id_provincia)
);
GO

-- ============================================================
-- MODULO CLIENTES
-- ============================================================

CREATE TABLE QUEQUE.Cliente (
    id_cliente       BIGINT        IDENTITY(1,1) NOT NULL,
    nombre           NVARCHAR(255) NULL,
    apellido         NVARCHAR(255) NULL,
    dni              NVARCHAR(255) NULL,
    telefono         NVARCHAR(255) NULL,
    mail             NVARCHAR(255) NULL,
    direccion        NVARCHAR(255) NULL,
    localidad        NVARCHAR(255) NULL,
    provincia        BIGINT        NULL,
    fecha_nacimiento DATE          NULL,
    CONSTRAINT PK_Cliente           PRIMARY KEY (id_cliente),
    CONSTRAINT FK_Cliente_Provincia FOREIGN KEY (provincia) REFERENCES QUEQUE.Provincia(id_provincia)
);
GO

-- ============================================================
-- TABLAS DE REFERENCIA / LOOKUPS
-- ============================================================

CREATE TABLE QUEQUE.CanalVenta (
    id_canal    BIGINT       IDENTITY(1,1) NOT NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT PK_CanalVenta PRIMARY KEY (id_canal)
);
GO

CREATE TABLE QUEQUE.MedioPago (
    id_medio_pago BIGINT       IDENTITY(1,1) NOT NULL,
    descripcion   VARCHAR(255) NULL,
    CONSTRAINT PK_MedioPago PRIMARY KEY (id_medio_pago)
);
GO

CREATE TABLE QUEQUE.Alianza (
    id_alianza BIGINT        IDENTITY(1,1) NOT NULL,
    alianza    NVARCHAR(255) NULL,
    CONSTRAINT PK_Alianza PRIMARY KEY (id_alianza)
);
GO

CREATE TABLE QUEQUE.EstadoPropuesta (
    id_estado   BIGINT       IDENTITY(1,1) NOT NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT PK_EstadoPropuesta PRIMARY KEY (id_estado)
);
GO

-- ============================================================
-- MODULO AEREO
-- ============================================================

CREATE TABLE QUEQUE.Aerolinea (
    id_aerolinea NVARCHAR(255) NOT NULL,
    nombre       NVARCHAR(255) NULL,
    pais         BIGINT        NULL,
    alianza      BIGINT        NULL,
    CONSTRAINT PK_Aerolinea         PRIMARY KEY (id_aerolinea),
    CONSTRAINT FK_Aerolinea_Pais    FOREIGN KEY (pais)    REFERENCES QUEQUE.Pais(id_pais),
    CONSTRAINT FK_Aerolinea_Alianza FOREIGN KEY (alianza) REFERENCES QUEQUE.Alianza(id_alianza)
);
GO

CREATE TABLE QUEQUE.Aeropuerto (
    id_aeropuerto NVARCHAR(10)  NOT NULL,
    descripcion   NVARCHAR(200) NULL,
    id_ciudad     BIGINT        NULL,
    pais          BIGINT        NULL,
    CONSTRAINT PK_Aeropuerto         PRIMARY KEY (id_aeropuerto),
    CONSTRAINT FK_Aeropuerto_Ciudad  FOREIGN KEY (id_ciudad) REFERENCES QUEQUE.Ciudad(id_ciudad),
    CONSTRAINT FK_Aeropuerto_Pais    FOREIGN KEY (pais)      REFERENCES QUEQUE.Pais(id_pais)
);
GO

CREATE TABLE QUEQUE.Vuelo (
    id_vuelo               BIGINT         IDENTITY(1,1) NOT NULL,
    id_aeropuerto_origen   NVARCHAR(10)   NOT NULL,
    id_aeropuerto_destino  NVARCHAR(10)   NOT NULL,
    id_aerolinea           NVARCHAR(255)  NOT NULL,
    fecha_salida           DATE           NULL,
    horario_salida         NVARCHAR(50)   NULL,
    fecha_llegada          DATE           NULL,
    horario_llegada        NVARCHAR(50)   NULL,
    duracion               INT            NULL,
    precio                 DECIMAL(18,2)  NULL,
    incluye_carry          BIT            NULL,
    incluye_valija         BIT            NULL,
    CONSTRAINT PK_Vuelo              PRIMARY KEY (id_vuelo),
    CONSTRAINT FK_Vuelo_Origen       FOREIGN KEY (id_aeropuerto_origen)  REFERENCES QUEQUE.Aeropuerto(id_aeropuerto),
    CONSTRAINT FK_Vuelo_Destino      FOREIGN KEY (id_aeropuerto_destino) REFERENCES QUEQUE.Aeropuerto(id_aeropuerto),
    CONSTRAINT FK_Vuelo_Aerolinea    FOREIGN KEY (id_aerolinea)          REFERENCES QUEQUE.Aerolinea(id_aerolinea)
);
GO

-- ============================================================
-- MODULO HOSPEDAJES
-- ============================================================

CREATE TABLE QUEQUE.Hospedaje (
    id_hospedaje      BIGINT       IDENTITY(1,1) NOT NULL,
    nombre            VARCHAR(255) NULL,
    direccion         VARCHAR(255) NULL,
    id_ciudad         BIGINT       NULL,
    pais              BIGINT       NULL,
    incluye_desayuno  BIT          NULL,
    hora_checkin      VARCHAR(50)  NULL,
    hora_checkout     VARCHAR(50)  NULL,
    CONSTRAINT PK_Hospedaje        PRIMARY KEY (id_hospedaje),
    CONSTRAINT FK_Hospedaje_Ciudad FOREIGN KEY (id_ciudad) REFERENCES QUEQUE.Ciudad(id_ciudad),
    CONSTRAINT FK_Hospedaje_Pais   FOREIGN KEY (pais)      REFERENCES QUEQUE.Pais(id_pais)
);
GO

CREATE TABLE QUEQUE.Habitacion (
    id_habitacion BIGINT        IDENTITY(1,1) NOT NULL,
    id_hospedaje  BIGINT        NOT NULL,
    nombre        VARCHAR(255)  NULL,
    descripcion   VARCHAR(MAX)  NULL,
    precio        DECIMAL(18,2) NULL,
    CONSTRAINT PK_Habitacion          PRIMARY KEY (id_habitacion),
    CONSTRAINT FK_Habitacion_Hospedaje FOREIGN KEY (id_hospedaje) REFERENCES QUEQUE.Hospedaje(id_hospedaje)
);
GO

-- ============================================================
-- MODULO EXCURSIONES
-- ============================================================

CREATE TABLE QUEQUE.Proveedor (
    id_proveedor BIGINT        IDENTITY(1,1) NOT NULL,
    nombre       NVARCHAR(255) NULL,
    mail         NVARCHAR(255) NULL,
    telefono     NVARCHAR(255) NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (id_proveedor)
);
GO

CREATE TABLE QUEQUE.Excursion (
    id_excursion BIGINT        IDENTITY(1,1) NOT NULL,
    id_proveedor BIGINT        NOT NULL,
    nombre       VARCHAR(255)  NULL,
    descripcion  VARCHAR(MAX)  NULL,
    horario      NVARCHAR(50)  NULL,
    duracion     INT           NULL,
    precio       DECIMAL(18,2) NULL,
    CONSTRAINT PK_Excursion          PRIMARY KEY (id_excursion),
    CONSTRAINT FK_Excursion_Proveedor FOREIGN KEY (id_proveedor) REFERENCES QUEQUE.Proveedor(id_proveedor)
);
GO

-- ============================================================
-- MODULO COTIZACIONES Y PROPUESTAS
-- ============================================================

CREATE TABLE QUEQUE.SolicitudCotizacion (
    nro_solicitud          BIGINT         NOT NULL,
    id_cliente             BIGINT         NOT NULL,
    id_agente              BIGINT         NOT NULL,
    fecha_solicitud        DATE           NULL,
    fecha_inicio_tentativa DATE           NULL,
    fecha_fin_tentativa    DATE           NULL,
    cant_pasajeros         INT            NULL,
    presupuesto_estimado   DECIMAL(18,2)  NULL,
    observaciones          NVARCHAR(MAX)  NULL,
    CONSTRAINT PK_SolicitudCotizacion        PRIMARY KEY (nro_solicitud),
    CONSTRAINT FK_Solicitud_Cliente          FOREIGN KEY (id_cliente) REFERENCES QUEQUE.Cliente(id_cliente),
    CONSTRAINT FK_Solicitud_Agente           FOREIGN KEY (id_agente)  REFERENCES QUEQUE.Agente(legajo)
);
GO

CREATE TABLE QUEQUE.Ciudad_x_Solicitud (
    id_ciudad     BIGINT        NOT NULL,
    nro_solicitud BIGINT        NOT NULL,
    cant_dias     INT           NULL,
    observaciones NVARCHAR(MAX) NULL,
    CONSTRAINT PK_Ciudad_x_Solicitud         PRIMARY KEY (id_ciudad, nro_solicitud),
    CONSTRAINT FK_CxS_Ciudad                 FOREIGN KEY (id_ciudad)     REFERENCES QUEQUE.Ciudad(id_ciudad),
    CONSTRAINT FK_CxS_Solicitud              FOREIGN KEY (nro_solicitud) REFERENCES QUEQUE.SolicitudCotizacion(nro_solicitud)
);
GO

CREATE TABLE QUEQUE.Propuesta (
    id_propuesta         BIGINT        NOT NULL,
    nro_solicitud        BIGINT        NOT NULL,
    id_agente            BIGINT        NOT NULL,
    fecha_emision        DATE          NULL,
    fecha_vigencia_hasta DATE          NULL,
    fecha_desde          DATE          NULL,
    fecha_hasta          DATE          NULL,
    subtotal             DECIMAL(18,2) NULL,
    descuento            DECIMAL(18,2) NULL,
    importe_total        DECIMAL(18,2) NULL,
    id_estado            BIGINT        NOT NULL,
    CONSTRAINT PK_Propuesta              PRIMARY KEY (id_propuesta),
    CONSTRAINT FK_Propuesta_Solicitud    FOREIGN KEY (nro_solicitud) REFERENCES QUEQUE.SolicitudCotizacion(nro_solicitud),
    CONSTRAINT FK_Propuesta_Agente       FOREIGN KEY (id_agente)     REFERENCES QUEQUE.Agente(legajo),
    CONSTRAINT FK_Propuesta_Estado       FOREIGN KEY (id_estado)     REFERENCES QUEQUE.EstadoPropuesta(id_estado)
);
GO

CREATE TABLE QUEQUE.Propuesta_Vuelo (
    id_propuesta    BIGINT        NOT NULL,
    id_vuelo        BIGINT        NOT NULL,
    cantidad        INT           NULL,
    precio_unitario DECIMAL(18,2) NULL,
    subtotal        DECIMAL(18,2) NULL,
    CONSTRAINT PK_Propuesta_Vuelo         PRIMARY KEY (id_propuesta, id_vuelo),
    CONSTRAINT FK_PropVuelo_Propuesta     FOREIGN KEY (id_propuesta) REFERENCES QUEQUE.Propuesta(id_propuesta),
    CONSTRAINT FK_PropVuelo_Vuelo         FOREIGN KEY (id_vuelo)     REFERENCES QUEQUE.Vuelo(id_vuelo)
);
GO

CREATE TABLE QUEQUE.Propuesta_Habitacion (
    id_propuesta  BIGINT        NOT NULL,
    id_habitacion BIGINT        NOT NULL,
    fecha_desde   DATE          NULL,
    fecha_hasta   DATE          NULL,
    cantidad      INT           NULL,
    precio        DECIMAL(18,2) NULL,
    subtotal      DECIMAL(18,2) NULL,
    CONSTRAINT PK_Propuesta_Habitacion      PRIMARY KEY (id_propuesta, id_habitacion),
    CONSTRAINT FK_PropHabitacion_Propuesta  FOREIGN KEY (id_propuesta)  REFERENCES QUEQUE.Propuesta(id_propuesta),
    CONSTRAINT FK_PropHabitacion_Habitacion FOREIGN KEY (id_habitacion) REFERENCES QUEQUE.Habitacion(id_habitacion)
);
GO

-- ============================================================
-- MODULO VENTAS Y RESERVAS
-- ============================================================

CREATE TABLE QUEQUE.Venta (
    nro_venta     BIGINT        NOT NULL,
    id_agencia    BIGINT        NOT NULL,
    id_cliente    BIGINT        NOT NULL,
    id_agente     BIGINT        NOT NULL,
    id_canal      BIGINT        NOT NULL,
    id_medio_pago BIGINT        NOT NULL,
    fecha_venta   DATE          NULL,
    subtotal      DECIMAL(18,2) NULL,
    descuento     DECIMAL(18,2) NULL,
    importe_total DECIMAL(18,2) NULL,
    CONSTRAINT PK_Venta              PRIMARY KEY (nro_venta),
    CONSTRAINT FK_Venta_Agencia      FOREIGN KEY (id_agencia)    REFERENCES QUEQUE.Agencia(id_agencia),
    CONSTRAINT FK_Venta_Cliente      FOREIGN KEY (id_cliente)    REFERENCES QUEQUE.Cliente(id_cliente),
    CONSTRAINT FK_Venta_Agente       FOREIGN KEY (id_agente)     REFERENCES QUEQUE.Agente(legajo),
    CONSTRAINT FK_Venta_Canal        FOREIGN KEY (id_canal)      REFERENCES QUEQUE.CanalVenta(id_canal),
    CONSTRAINT FK_Venta_MedioPago    FOREIGN KEY (id_medio_pago) REFERENCES QUEQUE.MedioPago(id_medio_pago)
);
GO

CREATE TABLE QUEQUE.Venta_X_Propuesta (
    nro_venta    BIGINT NOT NULL,
    id_propuesta BIGINT NOT NULL,
    CONSTRAINT PK_Venta_X_Propuesta       PRIMARY KEY (nro_venta, id_propuesta),
    CONSTRAINT FK_VxP_Venta               FOREIGN KEY (nro_venta)    REFERENCES QUEQUE.Venta(nro_venta),
    CONSTRAINT FK_VxP_Propuesta           FOREIGN KEY (id_propuesta) REFERENCES QUEQUE.Propuesta(id_propuesta)
);
GO

CREATE TABLE QUEQUE.Reserva_Vuelo (
    codigo_reserva    NVARCHAR(255) NOT NULL,
    nro_venta         BIGINT        NOT NULL,
    id_vuelo          BIGINT        NOT NULL,
    cantidad_pasajes  INT           NULL,
    precio            DECIMAL(18,2) NULL,
    subtotal          DECIMAL(18,2) NULL,
    CONSTRAINT PK_Reserva_Vuelo       PRIMARY KEY (codigo_reserva),
    CONSTRAINT FK_ResVuelo_Venta      FOREIGN KEY (nro_venta) REFERENCES QUEQUE.Venta(nro_venta),
    CONSTRAINT FK_ResVuelo_Vuelo      FOREIGN KEY (id_vuelo)  REFERENCES QUEQUE.Vuelo(id_vuelo)
);
GO

CREATE TABLE QUEQUE.Reserva_Habitacion (
    codigo_reserva NVARCHAR(255) NOT NULL,
    nro_venta      BIGINT        NOT NULL,
    id_habitacion  BIGINT        NOT NULL,
    fecha_desde    DATE          NULL,
    fecha_hasta    DATE          NULL,
    cantidad       INT           NULL,
    precio         DECIMAL(18,2) NULL,
    subtotal       DECIMAL(18,2) NULL,
    CONSTRAINT PK_Reserva_Habitacion         PRIMARY KEY (codigo_reserva),
    CONSTRAINT FK_ResHabitacion_Venta        FOREIGN KEY (nro_venta)      REFERENCES QUEQUE.Venta(nro_venta),
    CONSTRAINT FK_ResHabitacion_Habitacion   FOREIGN KEY (id_habitacion)  REFERENCES QUEQUE.Habitacion(id_habitacion)
);
GO

CREATE TABLE QUEQUE.Reserva_Excursion (
    codigo_reserva NVARCHAR(255) NOT NULL,
    nro_venta      BIGINT        NOT NULL,
    id_excursion   BIGINT        NOT NULL,
    fecha_reserva  DATE          NULL,
    cantidad       INT           NULL,
    precio         DECIMAL(18,2) NULL,
    subtotal       DECIMAL(18,2) NULL,
    CONSTRAINT PK_Reserva_Excursion         PRIMARY KEY (codigo_reserva),
    CONSTRAINT FK_ResExcursion_Venta        FOREIGN KEY (nro_venta)    REFERENCES QUEQUE.Venta(nro_venta),
    CONSTRAINT FK_ResExcursion_Excursion    FOREIGN KEY (id_excursion) REFERENCES QUEQUE.Excursion(id_excursion)
);
GO

-- ============================================================
-- MODULO ENCUESTAS
-- ============================================================

CREATE TABLE QUEQUE.Encuesta (
    id_encuesta BIGINT        NOT NULL,
    id_cliente  BIGINT        NOT NULL,
    id_agente   BIGINT        NOT NULL,
    fecha       DATE          NULL,
    comentario  NVARCHAR(MAX) NULL,
    CONSTRAINT PK_Encuesta          PRIMARY KEY (id_encuesta),
    CONSTRAINT FK_Encuesta_Cliente  FOREIGN KEY (id_cliente) REFERENCES QUEQUE.Cliente(id_cliente),
    CONSTRAINT FK_Encuesta_Agente   FOREIGN KEY (id_agente)  REFERENCES QUEQUE.Agente(legajo)
);
GO

CREATE TABLE QUEQUE.AspectoValorado (
    id_aspecto  BIGINT        IDENTITY(1,1) NOT NULL,
    descripcion NVARCHAR(255) NULL,
    CONSTRAINT PK_AspectoValorado PRIMARY KEY (id_aspecto)
);
GO

CREATE TABLE QUEQUE.ValoracionEncuesta (
    id_encuesta BIGINT NOT NULL,
    id_aspecto  BIGINT NOT NULL,
    puntaje     INT    NOT NULL CONSTRAINT CHK_Puntaje CHECK (puntaje BETWEEN 1 AND 5),
    CONSTRAINT PK_ValoracionEncuesta       PRIMARY KEY (id_encuesta, id_aspecto),
    CONSTRAINT FK_Valoracion_Encuesta      FOREIGN KEY (id_encuesta) REFERENCES QUEQUE.Encuesta(id_encuesta),
    CONSTRAINT FK_Valoracion_Aspecto       FOREIGN KEY (id_aspecto)  REFERENCES QUEQUE.AspectoValorado(id_aspecto)
);
GO

-- ============================================================
-- MIGRACIONES
-- ============================================================

-- Migracion Paises Alternativa 2 -> trabajando con la funcion Collate (cambia como se comparan los strings)
-- Esta alternativa deja los paises como estan, guardando una de las varias alternativas
-- Si queremos acceder a esta tabla necesitamos hacer el mismo Collate a ambos lados del join para asegurarnos que se verifiquen con los mismos criterios
-- Ejemplo JOIN [QUEQUE].[Pais] p ON m.[Aerolinea_Pais] COLLATE Latin1_General_CI_AI = p.[nombre] COLLATE Latin1_General_CI_AI
CREATE PROCEDURE [QUEQUE].[Migrar_Paises]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [QUEQUE].[Pais] (nombre)
    SELECT [Aeropuerto_Salida_Pais] COLLATE Latin1_General_CI_AI FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Aeropuerto_Salida_Pais] IS NOT NULL
    UNION
    SELECT [Aeropuerto_Llegada_Pais] COLLATE Latin1_General_CI_AI FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Aeropuerto_Llegada_Pais] IS NOT NULL
    UNION
    SELECT [Aerolinea_Pais] COLLATE Latin1_General_CI_AI FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Aerolinea_Pais] IS NOT NULL
    UNION
    SELECT [Hospedaje_Pais] COLLATE Latin1_General_CI_AI FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Hospedaje_Pais] IS NOT NULL;
END;
GO

-- Migracion Ciudades
CREATE PROCEDURE [QUEQUE].[Migrar_Ciudades]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [QUEQUE].[Ciudad] (nombre, pais)
    SELECT 
        DatosUnificados.NombreCiudad,
        p.id_pais 
    FROM (
        SELECT TRIM([Aeropuerto_Salida_Ciudad]) AS NombreCiudad, TRIM([Aeropuerto_Salida_Pais]) AS NombrePais 
        FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Aeropuerto_Salida_Ciudad] IS NOT NULL
        UNION
        SELECT TRIM([Aeropuerto_Llegada_Ciudad]), TRIM([Aeropuerto_Llegada_Pais]) 
        FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Aeropuerto_Llegada_Ciudad] IS NOT NULL
        UNION
        SELECT TRIM([Hospedaje_Ciudad]), TRIM([Hospedaje_Pais]) 
        FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Hospedaje_Ciudad] IS NOT NULL
    ) AS DatosUnificados
    JOIN [QUEQUE].[Pais] p ON DatosUnificados.NombrePais COLLATE Latin1_General_CI_AI 
                            = p.nombre                   COLLATE Latin1_General_CI_AI;
END;
GO

-- Migracion Alianzas
CREATE PROCEDURE [QUEQUE].[Migrar_Alianzas]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [QUEQUE].[Alianza] (alianza)
    SELECT distinct(Aerolinea_Alianza) FROM gd_esquema.Maestra where Aerolinea_Alianza is not null
END;
GO

-- Migracion Provincias
CREATE PROCEDURE [QUEQUE].[Migrar_Provincia]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [QUEQUE].[Provincia] (prov_nombre)
    SELECT 
        DatosUnificados.provincia 
    FROM (
        SELECT TRIM([Agencia_Provincia]) AS provincia
        FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Agencia_Provincia] IS NOT NULL
        UNION
        SELECT TRIM([Agente_Provincia])
        FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Agente_Provincia] IS NOT NULL
        UNION
        SELECT TRIM([Cliente_Provincia])
        FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Cliente_Provincia] IS NOT NULL
    ) AS DatosUnificados
END;
GO

-- Migracion Canal Venta
CREATE PROCEDURE [QUEQUE].[Migrar_Canal_Venta]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [QUEQUE].[CanalVenta] (descripcion)
    SELECT 
      distinct(Venta_Canal_Venta )
    FROM gd_esquema.Maestra
        where Venta_Canal_Venta is not null
END;
GO

-- Migracion Medio Pago
CREATE PROCEDURE [QUEQUE].[Migrar_Medio_Pago]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [QUEQUE].[MedioPago] (descripcion)
    SELECT 
      distinct(Venta_Medio_Pago )
    FROM gd_esquema.Maestra
        where Venta_Medio_Pago is not null
END;
GO

-- Migracion Agencias
CREATE PROCEDURE [QUEQUE].[Migrar_Agencias]
AS
BEGIN
    INSERT INTO [QUEQUE].[Agencia] (id_agencia, direccion, mail, telefono, localidad, provincia)
    SELECT DISTINCT
        m.Agencia_Nro_Agencia,
        m.Agencia_Direccion,
        m.Agencia_Mail,
        m.Agencia_Telefono,
        m.Agencia_Localidad,
        p.id_provincia
    FROM [gd_esquema].[Maestra] m
    JOIN [QUEQUE].[Provincia] p ON p.prov_nombre = m.Agencia_Provincia
    WHERE m.Agencia_Nro_Agencia IS NOT NULL;
END
GO

-- Migración de Aeropuertos
CREATE PROCEDURE [QUEQUE].[Migrar_Aeropuerto]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [QUEQUE].[Aeropuerto] (id_aeropuerto, descripcion, id_ciudad, pais)
    SELECT 
        DatosUnificados.CodigoAeropuerto,
        DatosUnificados.DescripcionAeropuerto,
        c.id_ciudad,
        p.id_pais 
    FROM (
        SELECT TRIM([Aeropuerto_Salida_Codigo]) AS CodigoAeropuerto, TRIM([Aeropuerto_Salida_Descripcion]) AS DescripcionAeropuerto, TRIM([Aeropuerto_Salida_Ciudad]) AS NombreCiudad, TRIM([Aeropuerto_Salida_Pais]) AS NombrePais 
        FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Aeropuerto_Salida_Codigo] IS NOT NULL
        UNION
        SELECT TRIM([Aeropuerto_Llegada_Codigo]), TRIM([Aeropuerto_Llegada_Descripcion]), TRIM([Aeropuerto_Llegada_Ciudad]), TRIM([Aeropuerto_Llegada_Pais]) 
        FROM [GD1C2026].[gd_esquema].[Maestra] WHERE [Aeropuerto_Llegada_Codigo] IS NOT NULL
    ) AS DatosUnificados
    JOIN [QUEQUE].[Pais] p ON p.nombre COLLATE Latin1_General_CI_AI = DatosUnificados.NombrePais COLLATE Latin1_General_CI_AI
    JOIN [QUEQUE].[Ciudad] c ON c.nombre = DatosUnificados.NombreCiudad AND c.pais = p.id_pais;
END
GO

-- Migración de Aerolíneas
CREATE PROCEDURE [QUEQUE].[Migrar_Aerolineas]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [QUEQUE].[Aerolinea] (id_aerolinea, nombre, pais, alianza)
    SELECT DISTINCT
        TRIM(m.Aerolinea_Codigo), 
        TRIM(m.Aerolinea_Nombre), 
        p.id_pais,
        a.id_alianza
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN [QUEQUE].[Pais] p ON p.nombre COLLATE Latin1_General_CI_AI = TRIM(m.Aerolinea_Pais) COLLATE Latin1_General_CI_AI
    JOIN [QUEQUE].[Alianza] a ON a.alianza = TRIM(m.Aerolinea_Alianza)
    WHERE m.Aerolinea_Codigo IS NOT NULL;
END;
GO

-- Migración de Agentes
CREATE PROCEDURE [QUEQUE].[Migrar_Agentes]
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [QUEQUE].[Agente] (id_agencia, nombre, apellido, dni, fecha_nacimiento, telefono, mail, direccion, localidad, provincia)
    SELECT DISTINCT
        ag.id_agencia,
        TRIM(m.Agente_Nombre), 
        TRIM(m.Agente_Apellido),
        TRIM(m.Agente_DNI),
        m.Agente_Fecha_Nac, 
        TRIM(m.Agente_Telefono),
        TRIM(m.Agente_Mail),
        TRIM(m.Agente_Direccion),
        TRIM(m.Agente_Localidad),
        p.id_provincia
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN [QUEQUE].[Agencia] ag ON ag.id_agencia = m.[Agencia_Nro_Agencia]
    JOIN [QUEQUE].[Provincia] p ON p.prov_nombre = TRIM(m.[Agente_Provincia])
    WHERE m.[Agente_DNI] IS NOT NULL; 
END
GO

-- Migracion Clientes
CREATE PROCEDURE [QUEQUE].[Migrar_Clientes]
AS
BEGIN
    INSERT INTO QUEQUE.Cliente (nombre, apellido, dni, telefono, mail, direccion, localidad, provincia, fecha_nacimiento)
    SELECT DISTINCT
        Cliente_Nombre,
        Cliente_Apellido,
        Cliente_Dni,
        Cliente_Tel,
        Cliente_Mail,
        Cliente_Direccion,
        Cliente_Localidad,
        id_provincia,
        Cliente_Fecha_Nac
    FROM [GD1C2026].[gd_esquema].[Maestra]
    INNER JOIN QUEQUE.Provincia ON prov_nombre = Cliente_Provincia
END
GO

-- Migracion Hospedajes
CREATE PROCEDURE [QUEQUE].[Migrar_Hospedajes]
AS
BEGIN
    INSERT INTO QUEQUE.Hospedaje (nombre, direccion, id_ciudad, pais, incluye_desayuno, hora_checkin, hora_checkout)
    SELECT DISTINCT
        m.Hospedaje_Nombre,
        m.Hospedaje_Direccion,
        c.id_ciudad,
        p.id_pais,
        m.Hospedaje_Incluye_Desayuno,
        m.Hospedaje_Check_In,
        m.Hospedaje_Check_Out
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    INNER JOIN QUEQUE.Pais p    ON p.nombre COLLATE Latin1_General_CI_AI = m.Hospedaje_Pais COLLATE Latin1_General_CI_AI
    INNER JOIN QUEQUE.Ciudad c  ON c.nombre  = m.Hospedaje_Ciudad
                                AND c.pais   = p.id_pais
    WHERE m.Hospedaje_Nombre IS NOT NULL;
END
GO

-- Migracion Habitaciones
CREATE PROCEDURE [QUEQUE].[Migrar_Habitaciones]
AS
BEGIN
    INSERT INTO QUEQUE.Habitacion (id_hospedaje, nombre, descripcion, precio)
    SELECT DISTINCT
        h.id_hospedaje,
        m.Habitacion_Nombre,
        m.Habitacion_Descripcion,
        m.Habitacion_Precio_Noche
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN QUEQUE.Hospedaje h ON h.nombre = m.Hospedaje_Nombre
    WHERE m.Habitacion_Nombre IS NOT NULL;
END
GO

-- Migración Proveedores
CREATE PROCEDURE [QUEQUE].[Migrar_Proveedores]
AS
BEGIN
    INSERT INTO QUEQUE.Proveedor (nombre, mail, telefono)
    SELECT DISTINCT
        Proveedor_Nombre,
        Proveedor_Mail,
        Proveedor_Telefono
    FROM [GD1C2026].[gd_esquema].[Maestra]
    WHERE Proveedor_Nombre IS NOT NULL;
END
GO

-- Migración Excursión
CREATE PROCEDURE [QUEQUE].[Migrar_Excursiones]
AS
BEGIN
    INSERT INTO QUEQUE.Excursion (id_proveedor, nombre, descripcion, horario, duracion, precio)
    SELECT DISTINCT
        p.id_proveedor,
        m.Excursion_Nombre,
        m.Excursion_Descripcion,
        m.Excursion_Horario,
        m.Excursion_Duracion,
        m.Excursion_Precio
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN QUEQUE.Proveedor p ON p.nombre = m.Proveedor_Nombre
    WHERE m.Excursion_Nombre IS NOT NULL;
END
GO

-- Migración Vuelo
CREATE PROCEDURE [QUEQUE].[Migrar_Vuelos]
AS
BEGIN
    INSERT INTO QUEQUE.Vuelo (id_aerolinea, id_aeropuerto_origen, id_aeropuerto_destino, fecha_salida, fecha_llegada, horario_salida, horario_llegada, duracion, precio, incluye_carry, incluye_valija)
    SELECT DISTINCT
        ap.id_aerolinea,
        aps.id_aeropuerto,
        apl.id_aeropuerto,
        m.Vuelo_Fecha_Salida,
        m.Vuelo_Fecha_Llegada,
        m.Vuelo_Horario_Salida,
        m.Vuelo_Horario_Llegada,
        m.Vuelo_Duracion,
        m.Vuelo_Precio,
        m.Vuelo_Incluye_Carry,
        m.Vuelo_Incluye_Valija
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN QUEQUE.Aerolinea  ap  ON ap.id_aerolinea   = m.Aerolinea_Codigo
    JOIN QUEQUE.Aeropuerto aps ON aps.id_aeropuerto = m.Aeropuerto_Salida_Codigo
    JOIN QUEQUE.Aeropuerto apl ON apl.id_aeropuerto = m.Aeropuerto_Llegada_Codigo
    WHERE m.Vuelo_Fecha_Salida IS NOT NULL;
END
GO

-- Migración Solicitud Cotización
CREATE PROCEDURE [QUEQUE].[Migrar_Solicitud_Cotizacion]
AS
BEGIN
    INSERT INTO QUEQUE.SolicitudCotizacion (nro_solicitud, id_cliente, id_agente, fecha_solicitud, fecha_inicio_tentativa, fecha_fin_tentativa, cant_pasajeros, presupuesto_estimado, observaciones)
    SELECT DISTINCT
        m.Solicitud_Nro_Solicitud,
        c.id_cliente,
        a.legajo,
        m.Solicitud_Fecha_Solicitud,
        m.Solicitud_Fecha_Inicio_Tentativa,
        m.Solicitud_Fecha_Fin_Tentativa,
        m.Solicitud_Cant_Pax,
        m.Solicitud_Presupuesto_Estimado,
        m.Solicitud_Observaciones
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN QUEQUE.Cliente c ON c.nombre = m.Cliente_Nombre and c.apellido = m.Cliente_Apellido and c.dni = m.Cliente_Dni
    JOIN QUEQUE.Agente a ON a.nombre = m.Agente_Nombre AND a.apellido = m.Agente_Apellido
    WHERE m.Solicitud_Nro_Solicitud IS NOT NULL;
END
GO

-- Migración Solicitud_X_Ciudad
CREATE PROCEDURE [QUEQUE].[Migrar_Solicitud_X_Ciudad]
AS
BEGIN
    INSERT INTO QUEQUE.Ciudad_x_Solicitud (nro_solicitud, id_ciudad, cant_dias, observaciones)
    SELECT DISTINCT
        m.Solicitud_Nro_Solicitud,
        c.id_ciudad,
        m.Detalle_Solicitud_Cant_Dias_Aprox,
        m.Detalle_Solicitud_Observaciones
    from [GD1C2026].[gd_esquema].[Maestra] m
    join QUEQUE.Ciudad c on c.nombre = m.Detalle_Solicitud_Ciudad
    where m.Solicitud_Nro_Solicitud is not null and m.Detalle_Solicitud_Ciudad is not null
END
GO

-- Migración Estado Propuesta
CREATE PROCEDURE [QUEQUE].[Migrar_Estado_Propuesta]
AS
BEGIN
    INSERT INTO [QUEQUE].[EstadoPropuesta] (descripcion)
    SELECT DISTINCT 
        TRIM(Propuesta_Estado)
    FROM [GD1C2026].[gd_esquema].[Maestra]
    WHERE Propuesta_Estado IS NOT NULL;
END
GO

-- Migración Propuesta
CREATE PROCEDURE [QUEQUE].[Migrar_Propuesta]
AS
BEGIN
    INSERT INTO QUEQUE.Propuesta (id_propuesta, nro_solicitud, id_agente, fecha_emision, fecha_vigencia_hasta, fecha_desde, fecha_hasta, subtotal, descuento, importe_total, id_estado)
    SELECT DISTINCT
        m.Propuesta_Nro_Propuesta,
        m.Solicitud_Nro_Solicitud,
        a.legajo,
        m.Propuesta_Fecha_Emision,
        m.Propuesta_Vigencia_Hasta,
        m.Propuesta_Fecha_Desde,
        m.Propuesta_Fecha_Hasta,
        m.Propuesta_Subtotal,
        m.Propuesta_Descuento,
        m.Propuesta_Importe_Total,
        ep.id_estado
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN QUEQUE.Agente a ON a.nombre = m.Agente_Nombre AND a.apellido = m.Agente_Apellido
    JOIN QUEQUE.EstadoPropuesta ep ON ep.descripcion = TRIM(m.Propuesta_Estado)
    WHERE m.Propuesta_Nro_Propuesta IS NOT NULL;
END
GO

-- Migracion Ventas
CREATE PROCEDURE [QUEQUE].[Migrar_Ventas]
AS
BEGIN
    INSERT INTO QUEQUE.Venta (
        nro_venta,
        id_agencia,
        id_cliente,
        id_agente,
        id_canal,
        id_medio_pago,
        fecha_venta,
        subtotal,
        descuento,
        importe_total
    )
    SELECT DISTINCT
        M.[Venta_Nro_Venta],
        AG.[id_agencia],
        C.[id_cliente],
        A.legajo,
        CV.[id_canal],
        MP.[id_medio_pago],
        M.[Venta_Fecha_Venta],
        M.[Venta_Subtotal],
        M.[Venta_Descuento],
        M.[Venta_Importe_Total]
    FROM [GD1C2026].[gd_esquema].[Maestra] M
    INNER JOIN QUEQUE.Agencia AG ON AG.direccion = M.[Agencia_Direccion]
    INNER JOIN QUEQUE.Cliente C ON C.dni = M.[Cliente_Dni] 
                                AND C.nombre = M.[Cliente_Nombre] 
                                AND C.apellido = M.[Cliente_Apellido]
    INNER JOIN QUEQUE.Agente A ON A.dni = M.[Agente_Dni]
    INNER JOIN QUEQUE.CanalVenta CV ON M.[Venta_Canal_Venta] = CV.descripcion
    INNER JOIN QUEQUE.MedioPago MP ON M.[Venta_Medio_Pago] = MP.descripcion
    WHERE M.[Venta_Nro_Venta] IS NOT NULL;
END
GO

-- Migracion Reserva_Vuelo
CREATE PROCEDURE [QUEQUE].[Migrar_Reserva_Vuelo]
AS
BEGIN
    INSERT INTO QUEQUE.Reserva_Vuelo (
        codigo_reserva,
        nro_venta,
        id_vuelo,
        cantidad_pasajes,
        precio,
        subtotal
    )
    SELECT DISTINCT
        M.[Detalle_Venta_Vuelo_Cod_Reserva],
        M.[Venta_Nro_Venta],
        V.[id_vuelo],
        M.[Detalle_Venta_Vuelo_Cantidad_Pasajes],
        M.[Detalle_Venta_Vuelo_Precio_Unitario],
        M.[Detalle_Venta_Vuelo_Subtotal]
    FROM [GD1C2026].[gd_esquema].[Maestra] M
    INNER JOIN QUEQUE.Vuelo V ON V.id_aerolinea = M.[Aerolinea_Codigo]
                             AND V.id_aeropuerto_origen = M.[Aeropuerto_Salida_Codigo]
                             AND V.id_aeropuerto_destino = M.[Aeropuerto_Llegada_Codigo]
                             AND V.fecha_salida = M.[Vuelo_Fecha_Salida]
                             AND V.horario_salida = M.[Vuelo_Horario_Salida]
    WHERE M.[Venta_Nro_Venta] IS NOT NULL 
      AND M.[Detalle_Venta_Vuelo_Cod_Reserva] IS NOT NULL;
END
GO

-- Migracion Reserva_Habitacion
CREATE PROCEDURE [QUEQUE].[Migrar_Reserva_Habitacion]
AS
BEGIN
    INSERT INTO QUEQUE.Reserva_Habitacion (
        codigo_reserva,
        nro_venta,
        id_habitacion,
        fecha_desde,
        fecha_hasta,
        cantidad,
        precio,
        subtotal
    )
    SELECT DISTINCT
        M.[Detalle_Venta_Hospedaje_Cod_Reserva],
        M.[Venta_Nro_Venta],
        HAB.[id_habitacion],
        M.[Detalle_Venta_Hospedaje_Fecha_Desde],
        M.[Detalle_Venta_Hospedaje_Fecha_Hasta],
        M.[Detalle_Venta_Hospedaje_Cantidad],
        M.[Detalle_Venta_Hospedaje_Precio_Unitario],
        M.[Detalle_Venta_Hospedaje_Subtotal]
    FROM [GD1C2026].[gd_esquema].[Maestra] M
    INNER JOIN QUEQUE.Hospedaje HOS ON HOS.nombre = M.[Hospedaje_Nombre]
                                   AND HOS.direccion = M.[Hospedaje_Direccion]
    INNER JOIN QUEQUE.Habitacion HAB ON HAB.id_hospedaje = HOS.id_hospedaje
                                  AND HAB.nombre = M.[Habitacion_Nombre]
    WHERE M.[Venta_Nro_Venta] IS NOT NULL 
      AND M.[Detalle_Venta_Hospedaje_Cod_Reserva] IS NOT NULL;
END
GO

-- Migracion Reserva_Excursion
CREATE PROCEDURE [QUEQUE].[Migrar_Reserva_Excursion]
AS
BEGIN
    INSERT INTO QUEQUE.Reserva_Excursion (
        codigo_reserva,
        nro_venta,
        id_excursion,
        fecha_reserva,
        cantidad,
        precio,
        subtotal
    )
    SELECT DISTINCT
        M.[Detalle_Venta_Excursion_Cod_Reserva],
        M.[Venta_Nro_Venta],
        E.[id_excursion],
        M.[Detalle_Venta_Excursion_Fecha_Reserva],
        M.[Detalle_Venta_Excursion_Cant],
        M.[Detalle_Venta_Excursion_Precio_Unitario],
        M.[Detalle_Venta_Excursion_Subtotal]
    FROM [GD1C2026].[gd_esquema].[Maestra] M
    INNER JOIN QUEQUE.Proveedor P ON P.nombre = M.[Proveedor_Nombre]
    INNER JOIN QUEQUE.Excursion E ON E.id_proveedor = P.id_proveedor 
                                AND E.nombre = M.[Excursion_Nombre]      
    WHERE M.[Venta_Nro_Venta] IS NOT NULL 
      AND M.[Detalle_Venta_Excursion_Cod_Reserva] IS NOT NULL;
END
GO

-- Migración Aspecto Valorado
CREATE PROCEDURE [QUEQUE].[Migrar_AspectoValorado]
AS
BEGIN
    INSERT INTO QUEQUE.AspectoValorado (descripcion)
    SELECT DISTINCT
        TRIM(m.Aspecto_Aspecto) 
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    WHERE m.Aspecto_Aspecto IS NOT NULL;
END
GO

-- Migración Encuesta
CREATE PROCEDURE [QUEQUE].[Migrar_Encuestas]
AS
BEGIN
    INSERT INTO QUEQUE.Encuesta (id_encuesta, id_cliente, id_agente, fecha, comentario)
    SELECT DISTINCT
        m.Encuesta_Codigo_Encuesta,
        c.id_cliente,
        a.legajo,
        m.Encuesta_Fecha_Encuesta,
        m.Encuesta_Comentarios
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN QUEQUE.Cliente c ON c.dni = m.Cliente_Dni 
                         AND c.nombre = m.Cliente_Nombre 
                         AND c.apellido = m.Cliente_Apellido
    JOIN QUEQUE.Agente a ON a.dni = m.Agente_Dni
    WHERE m.Encuesta_Codigo_Encuesta IS NOT NULL;
END
GO

-- Migración ValoracionEncuesta
CREATE PROCEDURE [QUEQUE].[Migrar_ValoracionEncuesta]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO QUEQUE.ValoracionEncuesta (id_encuesta, id_aspecto, puntaje)
    SELECT DISTINCT
        m.Encuesta_Codigo_Encuesta,
        av.id_aspecto,
        m.Detalle_Encuesta_Puntaje 
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN QUEQUE.AspectoValorado av ON av.descripcion = TRIM(m.Aspecto_Aspecto)
    WHERE m.Encuesta_Codigo_Encuesta IS NOT NULL  
    AND m.Aspecto_Aspecto IS NOT NULL;
END
GO

-- Migración Propuesta Vuelo
CREATE PROCEDURE [QUEQUE].[Migrar_Propuesta_Vuelo]
AS
BEGIN
    INSERT INTO QUEQUE.Propuesta_Vuelo (id_propuesta, id_vuelo, cantidad, precio_unitario, subtotal)
    SELECT DISTINCT
        m.Propuesta_Nro_Propuesta,
        v.id_vuelo,
        m.Detalle_Propuesta_Vuelo_Cant_Pasajes,
        m.Detalle_Propuesta_Vuelo_Precio,
        m.Detalle_Propuesta_Vuelo_Subtotal
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    JOIN QUEQUE.Vuelo v ON v.id_aerolinea = m.[Aerolinea_Codigo]
                       AND v.id_aeropuerto_origen = m.[Aeropuerto_Salida_Codigo]
                       AND v.id_aeropuerto_destino = m.[Aeropuerto_Llegada_Codigo]
                       AND v.fecha_salida = m.[Vuelo_Fecha_Salida]
                       AND v.horario_salida = m.[Vuelo_Horario_Salida]
    WHERE m.Propuesta_Nro_Propuesta IS NOT NULL 
      AND m.Detalle_Propuesta_Vuelo_Cant_Pasajes IS NOT NULL;
END
GO

-- Migración Propuesta Habitación
CREATE PROCEDURE [QUEQUE].[Migrar_Propuesta_Habitación]
AS
BEGIN
    INSERT INTO QUEQUE.Propuesta_Habitacion (id_propuesta, id_habitacion, fecha_desde, fecha_hasta, cantidad, subtotal, precio)
    SELECT DISTINCT
        m.Propuesta_Nro_Propuesta,
        HAB.id_habitacion,
        m.Detalle_Propuesta_Hospedaje_Fecha_Desde,
        m.Detalle_Propuesta_Hospedaje_Fecha_Hasta,
        m.Detalle_Propuesta_Hospedaje_Cant,
        m.Detalle_Propuesta_Vuelo_Subtotal,
        m.Detalle_Propuesta_Vuelo_Precio
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    INNER JOIN QUEQUE.Hospedaje HOS ON HOS.nombre = m.[Hospedaje_Nombre]
                                   AND HOS.direccion = m.[Hospedaje_Direccion]
    INNER JOIN QUEQUE.Habitacion HAB ON HAB.id_hospedaje = HOS.id_hospedaje
                                  AND HAB.nombre = m.[Habitacion_Nombre]
    WHERE m.Propuesta_Nro_Propuesta IS NOT NULL
        AND m.Detalle_Propuesta_Hospedaje_Cant IS NOT NULL
END
GO

-- Migración Venta x Propuesta
CREATE PROCEDURE [QUEQUE].[Migrar_Venta_X_Propuesta]
AS
BEGIN
    INSERT INTO QUEQUE.Venta_X_Propuesta (id_propuesta, nro_venta)
    SELECT DISTINCT
        m.Propuesta_Nro_Propuesta,
        m.Venta_Nro_Venta
    FROM [GD1C2026].[gd_esquema].[Maestra] m
    WHERE m.Propuesta_Nro_Propuesta IS NOT NULL
        AND m.Venta_Nro_Venta IS NOT NULL
END
GO

-- ============================================================
-- EJECUTAR PROCEDIMIENTOS DE MIGRACION
-- ============================================================

EXEC [QUEQUE].[Migrar_Paises];
GO

EXEC [QUEQUE].[Migrar_Ciudades];
GO

EXEC [QUEQUE].[Migrar_Alianzas];
GO

EXEC [QUEQUE].[Migrar_Provincia];
GO

EXEC [QUEQUE].[Migrar_Canal_Venta];
GO

EXEC [QUEQUE].[Migrar_Medio_Pago];
GO

EXEC [QUEQUE].[Migrar_Agencias];
GO

EXEC [QUEQUE].[Migrar_Aeropuerto];
GO

EXEC [QUEQUE].[Migrar_Aerolineas];
GO

EXEC [QUEQUE].[Migrar_Agentes];
GO

EXEC [QUEQUE].[Migrar_Clientes];
GO

EXEC [QUEQUE].[Migrar_Hospedajes];
GO

EXEC [QUEQUE].[Migrar_Habitaciones];
GO

EXEC [QUEQUE].[Migrar_Proveedores];
GO

EXEC [QUEQUE].[Migrar_Excursiones];
GO

EXEC [QUEQUE].[Migrar_Vuelos];
GO

EXEC [QUEQUE].[Migrar_Solicitud_Cotizacion];
GO

EXEC [QUEQUE].[Migrar_Solicitud_X_Ciudad];
GO

EXEC [QUEQUE].[Migrar_Estado_Propuesta];
GO

EXEC [QUEQUE].[Migrar_Propuesta];
GO

EXEC [QUEQUE].[Migrar_Ventas];
GO

EXEC [QUEQUE].[Migrar_Reserva_Vuelo];
GO

EXEC [QUEQUE].[Migrar_Reserva_Habitacion];
GO

EXEC [QUEQUE].[Migrar_Reserva_Excursion];
GO

EXEC [QUEQUE].[Migrar_AspectoValorado]
GO

EXEC [QUEQUE].[Migrar_Encuestas]
GO

EXEC [QUEQUE].[Migrar_ValoracionEncuesta]
GO

EXEC [QUEQUE].[Migrar_Propuesta_Vuelo]
GO

EXEC [QUEQUE].[Migrar_Propuesta_Habitación]
GO

EXEC [QUEQUE].[Migrar_Venta_X_Propuesta]
GO

-- -- ============================================================
-- -- Queries de prueba
-- -- ============================================================
