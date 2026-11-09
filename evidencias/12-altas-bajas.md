# Evidencia 12 — Altas y bajas

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 13

## Comandos

Como administrador: `INSERT INTO clientes (...) VALUES ('Pedro Ruiz', 'pedro.ruiz@example.test', 'RUPE950101AAA', 30, 'Guasave', '81000');` y `DELETE FROM clientes WHERE nombre = 'Pedro Ruiz';`

## Resultado en la auditoría

| id_evento | usuario_sesion | aplicacion | ip_cliente | operacion | id_cliente | rfc_antes | rfc_despues |
|---|---|---|---|---|---|---|---|
| 1 | app_ventas | app-ventas-web | 127.0.0.1 | UPDATE | 3 | GAMA780912XYZ | GAMA780912ZZZ |
| 2 | postgres | psql | ::1 | INSERT | 6 | | RUPE950101AAA |
| 3 | postgres | psql | ::1 | DELETE | 6 | RUPE950101AAA | |

## Respuestas

1. **¿Dónde queda evidencia de que Pedro Ruiz existió?** En `auditoria.cambios_clientes`. El evento 2 guarda el alta y el evento 3 guarda el registro completo en `valores_antes` (JSONB) al momento de borrarlo. Aunque ya no esté en `clientes`, la auditoría conserva lo que tenía.
2. **¿Por qué `ip_cliente` está vacía en la guía y aquí aparece `::1`?** En la guía el administrador entra por socket local (sin IP). En este servidor de Windows SQL Shell se conecta por TCP a `localhost` (IPv6), por eso aparece `::1`.
3. **¿Qué conflicto aparece con la política de retención?** La política de la Unidad II pedía eliminar los datos cuando ya no fueran necesarios, pero la auditoría conserva una copia del registro borrado, incluido su RFC. Hay que decidir cuánto tiempo se guarda esa copia y quién la depura. Lo resuelve quien define la política de datos de la organización (responsable de datos personales o cumplimiento, junto con seguridad y el DBA), no el DBA solo.
