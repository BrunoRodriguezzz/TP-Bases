-- ============================================================
-- DROP SCHEMA QUEQUE (sin tocar dbo.TablaMaestra)
-- ============================================================

USE [GD1C2026];
GO

-- Drop BI

IF OBJECT_ID('BI_Ticket_Promedio','V') IS NOT NULL DROP VIEW BI_Ticket_Promedio;
IF OBJECT_ID('BI_Distribucion_Facturacion','V') IS NOT NULL DROP VIEW BI_Distribucion_Facturacion;
IF OBJECT_ID('BI_Ranking_Solicitudes_Temporada','V') IS NOT NULL DROP VIEW BI_Ranking_Solicitudes_Temporada;
IF OBJECT_ID('BI_Anticipacion_Promedio_Solicitudes','V') IS NOT NULL DROP VIEW BI_Anticipacion_Promedio_Solicitudes;
IF OBJECT_ID('BI_Tasa_Aceptacion_Propuestas','V') IS NOT NULL DROP VIEW BI_Tasa_Aceptacion_Propuestas;
IF OBJECT_ID('BI_Cotizacion_Promedio_Temporada','V') IS NOT NULL DROP VIEW BI_Cotizacion_Promedio_Temporada;
IF OBJECT_ID('BI_Tiempo_promedio_de_respuesta','V') IS NOT NULL DROP VIEW BI_Tiempo_promedio_de_respuesta;
IF OBJECT_ID('BI_Desvio_de_presupuesto','V') IS NOT NULL DROP VIEW BI_Desvio_de_presupuesto;
IF OBJECT_ID('BI_Ranking_de_aspectos_mejor_y_peor_valorados','V') IS NOT NULL DROP VIEW BI_Ranking_de_aspectos_mejor_y_peor_valorados;
IF OBJECT_ID('BI_SatisfaccionPromedioPorAgente','V') IS NOT NULL DROP VIEW BI_SatisfaccionPromedioPorAgente;
GO

IF OBJECT_ID('BI_Hecho_Valoracion_Encuesta','U') IS NOT NULL DROP TABLE BI_Hecho_Valoracion_Encuesta;
IF OBJECT_ID('Hecho_Valoracion_Encuesta','U') IS NOT NULL DROP TABLE Hecho_Valoracion_Encuesta;
IF OBJECT_ID('BI_Hecho_Propuesta','U') IS NOT NULL DROP TABLE BI_Hecho_Propuesta;
IF OBJECT_ID('Hecho_Propuesta','U') IS NOT NULL DROP TABLE Hecho_Propuesta;
IF OBJECT_ID('BI_Hecho_Solicitud','U') IS NOT NULL DROP TABLE BI_Hecho_Solicitud;
IF OBJECT_ID('Hecho_Solicitud','U') IS NOT NULL DROP TABLE Hecho_Solicitud;
IF OBJECT_ID('BI_Hecho_Venta','U') IS NOT NULL DROP TABLE BI_Hecho_Venta;
IF OBJECT_ID('Hecho_Venta','U') IS NOT NULL DROP TABLE Hecho_Venta;
GO

IF OBJECT_ID('BI_DIM_RangoEAgente','U') IS NOT NULL DROP TABLE BI_DIM_RangoEAgente;
IF OBJECT_ID('DIM_RangoEAgente','U') IS NOT NULL DROP TABLE DIM_RangoEAgente;
IF OBJECT_ID('BI_DIM_RangoECliente','U') IS NOT NULL DROP TABLE BI_DIM_RangoECliente;
IF OBJECT_ID('DIM_RangoECliente','U') IS NOT NULL DROP TABLE DIM_RangoECliente;
IF OBJECT_ID('BI_DIM_Tiempo','U') IS NOT NULL DROP TABLE BI_DIM_Tiempo;
IF OBJECT_ID('DIM_Tiempo','U') IS NOT NULL DROP TABLE DIM_Tiempo;
IF OBJECT_ID('BI_DIM_Temporada','U') IS NOT NULL DROP TABLE BI_DIM_Temporada;
IF OBJECT_ID('DIM_Temporada','U') IS NOT NULL DROP TABLE DIM_Temporada;
IF OBJECT_ID('BI_DIM_TipoServicio','U') IS NOT NULL DROP TABLE BI_DIM_TipoServicio;
IF OBJECT_ID('DIM_TipoServicio','U') IS NOT NULL DROP TABLE DIM_TipoServicio;
IF OBJECT_ID('BI_DIM_CanalVenta','U') IS NOT NULL DROP TABLE BI_DIM_CanalVenta;
IF OBJECT_ID('DIM_CanalVenta','U') IS NOT NULL DROP TABLE DIM_CanalVenta;
IF OBJECT_ID('BI_DIM_Aspecto','U') IS NOT NULL DROP TABLE BI_DIM_Aspecto;
IF OBJECT_ID('DIM_Aspecto','U') IS NOT NULL DROP TABLE DIM_Aspecto;
IF OBJECT_ID('BI_DIM_EstadoPropuesta','U') IS NOT NULL DROP TABLE BI_DIM_EstadoPropuesta;
IF OBJECT_ID('DIM_EstadoPropuesta','U') IS NOT NULL DROP TABLE DIM_EstadoPropuesta;
GO

-- Procedures
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Paises;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Provincia;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Alianzas;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Canal_Venta;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Medio_Pago;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Ciudades;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Agencias;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Aeropuerto;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Aerolineas;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Agentes;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Clientes;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Hospedajes;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Habitaciones;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Proveedores;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Excursiones;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Vuelos;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Solicitud_Cotizacion;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Solicitud_X_Ciudad;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Propuesta;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Ventas;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Reserva_Vuelo;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Reserva_Habitacion;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Reserva_Excursion;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Estado_Propuesta;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_AspectoValorado;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Encuestas;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_ValoracionEncuesta;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Propuesta_Vuelo;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Propuesta_Habitación;
DROP PROCEDURE IF EXISTS QUEQUE.Migrar_Venta_X_Propuesta;

-- Detalle / tablas hoja
DROP TABLE IF EXISTS QUEQUE.ValoracionEncuesta;
DROP TABLE IF EXISTS QUEQUE.Encuesta;

DROP TABLE IF EXISTS QUEQUE.Reserva_Excursion;
DROP TABLE IF EXISTS QUEQUE.Reserva_Habitacion;
DROP TABLE IF EXISTS QUEQUE.Reserva_Vuelo;
DROP TABLE IF EXISTS QUEQUE.Venta_X_Propuesta;
DROP TABLE IF EXISTS QUEQUE.Venta;

DROP TABLE IF EXISTS QUEQUE.Propuesta_Habitacion;
DROP TABLE IF EXISTS QUEQUE.Propuesta_Vuelo;
DROP TABLE IF EXISTS QUEQUE.Propuesta;
DROP TABLE IF EXISTS QUEQUE.Ciudad_x_Solicitud;
DROP TABLE IF EXISTS QUEQUE.SolicitudCotizacion;

DROP TABLE IF EXISTS QUEQUE.AspectoValorado;

-- Vuelos y hospedajes
DROP TABLE IF EXISTS QUEQUE.Vuelo;
DROP TABLE IF EXISTS QUEQUE.Excursion;
DROP TABLE IF EXISTS QUEQUE.Habitacion;
DROP TABLE IF EXISTS QUEQUE.Hospedaje;
DROP TABLE IF EXISTS QUEQUE.Aeropuerto;
DROP TABLE IF EXISTS QUEQUE.Aerolinea;

-- Personas
DROP TABLE IF EXISTS QUEQUE.Agente;
DROP TABLE IF EXISTS QUEQUE.Cliente;
DROP TABLE IF EXISTS QUEQUE.Agencia;
DROP TABLE IF EXISTS QUEQUE.Proveedor;

-- Lookups
DROP TABLE IF EXISTS QUEQUE.CanalVenta;
DROP TABLE IF EXISTS QUEQUE.MedioPago;
DROP TABLE IF EXISTS QUEQUE.EstadoPropuesta;
DROP TABLE IF EXISTS QUEQUE.Alianza;

-- Geografía
DROP TABLE IF EXISTS QUEQUE.Ciudad;
DROP TABLE IF EXISTS QUEQUE.Provincia;
DROP TABLE IF EXISTS QUEQUE.Pais;

-- Schema
DROP SCHEMA IF EXISTS QUEQUE;
GO
