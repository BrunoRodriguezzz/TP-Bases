# Entidades migradadas

# Orden sugerido y dependencias

1. Pais
2. Provincia, Alianza, CanalVenta, MedioPago
3. Ciudad (depende de Pais)
4. Agencia (depende de Provincia)
5. Aerolinea (depende de Pais, Alianza)
6. Aeropuerto (depende de Ciudad, Pais)
7. Agente (depende de Agencia, Provincia)
8. Cliente (depende de Provincia)
9. Hospedaje (depende de Ciudad, Pais)
10. Habitacion (depende de Hospedaje)
11. Proveedor
12. Excursion (depende de Proveedor)
13. Vuelo (depende de Aeropuerto, Aerolinea)
14. SolicitudCotizacion → Propuesta → Venta → Reservas...

# Checklist de entidades

- [x] Pais
- [x] Provincia
- [x] Alianza
- [x] CanalVenta
- [x] MedioPago
- [x] Ciudad
- [x] Agencia
- [x] Aerolinea
- [x] Aeropuerto
- [x] Agente
- [x] Cliente
- [x] Hospedaje
- [x] Habitacion
- [x] Proveedor
- [x] Excursion
- [x] Vuelo
- [x] SolicitudCotizacion
- [x] Ciudad_x_Solicitud
- [x] Propuesta
- [x] EstadoPropuesta
- [ ] Propuesta_Vuelo
- [ ] Propuesta_Habitacion
- [ ] Venta
- [ ] Venta_X_Propuesta
- [ ] Reserva_Vuelo
- [ ] Reserva_Habitacion
- [ ] Reserva_Excursion
- [ ] Encuesta
- [ ] AspectoValorado
- [ ] ValoracionEncuesta

# Triggers hechos

- [ ] Fecha de llegada no sea anterior a la de salida
  - [ ] Vuelo
  - [ ] Reserva habitacion
  - [ ] Propuesta habitacion
  - [ ] Propuesta
- [ ] Actualizar el importe de una venta si se actualiza el descuento
  - [ ] Venta
  - [ ] Propuesta
- [ ] Que una propuesta no se pueda aceptar si ya venció la fecha de vigencia
