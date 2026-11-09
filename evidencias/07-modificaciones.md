# Evidencia 07 — Modificaciones de datos: ddl frente a mod

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 7

## Con `log_statement = 'ddl'`

Como `app_ventas` (`application_name=app-ventas-web`): `UPDATE clientes SET rfc = 'GAMA780912XYZ' WHERE id = 3;`

En la bitácora aparecen la conexión (18:10:29) y la desconexión (18:11:00, duración 0:00:31.760) de `app_ventas`, pero **no el `UPDATE`**.

## Con `log_statement = 'mod'`

`ALTER SYSTEM SET log_statement = 'mod';` y `SELECT pg_reload_conf();`. Luego, como `app_ventas`: `UPDATE clientes SET telefono = '6679990000' WHERE id = 3;` y `SELECT nombre, rfc FROM clientes WHERE id = 3;`

| Hora | PID | Usuario | Aplicación | Cliente | Mensaje |
|---|---|---|---|---|---|
| 18:11:55 | 732 | postgres | psql | ::1 | statement: ALTER SYSTEM SET log_statement = 'mod' |
| 18:13:26 | 20768 | app_ventas | app-ventas-web | 127.0.0.1 | statement: UPDATE clientes SET telefono = '6679990000' WHERE id = 3 |

El `SELECT` no aparece.

## Análisis

- Ahora sí aparece quién, cuándo, desde dónde, con qué aplicación y qué sentencia.
- El `SELECT` que leyó el RFC no aparece: con `mod` las lecturas no se registran.
- La bitácora muestra lo que se escribió, pero no el valor anterior del teléfono.
- El `ALTER SYSTEM` sí aparece porque `log_statement` ya valía `ddl` cuando se ejecutó.

## Respuestas

1. **¿Qué nivel habría registrado la lectura del RFC? ¿Qué costo tendría?** `all`. Con miles de consultas por minuto la bitácora crece muy rápido: más disco, más escritura y búsquedas más lentas. Además guardaría datos sensibles (como el RFC) dentro del texto de las consultas.
2. **¿Qué le falta a esta bitácora para revertir el cambio con certeza?** El valor anterior. Solo tiene el valor nuevo (`6679990000`), así que no se sabe qué teléfono había antes. Eso se resuelve en la Parte B con la tabla de auditoría y el disparador.
