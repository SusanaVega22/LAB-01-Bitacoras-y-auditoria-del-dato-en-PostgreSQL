# Evidencia 09 — Sesiones activas con pg_stat_activity

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 9

## Comandos

1. Sesión de reporte (PowerShell, contraseña omitida): `psql "postgresql://soporte_ana:<REDACTED>@127.0.0.1/comercial?application_name=reporte-mensual"` y `SELECT pg_sleep(90);`
2. Mientras corría, como administrador: `SELECT pid, usename, application_name, client_addr, backend_start, state, left(query, 30) AS query FROM pg_stat_activity WHERE backend_type = 'client backend';`
3. `SELECT linea FROM dba.bitacora WHERE linea LIKE '%[20072]%' ORDER BY num;`

## Resultado durante el reporte

| pid | usename | application_name | client_addr | state | query |
|---|---|---|---|---|---|
| 732 | postgres | psql | ::1 | active | SELECT pid, usename, applicati... |
| 20072 | soporte_ana | reporte-mensual | 127.0.0.1 | active | SELECT pg_sleep(90); |

## Líneas de la bitácora del PID 20072

| Hora | Mensaje |
|---|---|
| 18:19:49.705 | connection received: host=127.0.0.1 port=51026 |
| 18:19:49.730 | connection authenticated: identity="soporte_ana" method=scram-sha-256 (pg_hba.conf:115) |
| 18:19:49.730 | connection authorized: ... application_name=reporte-mensual |
| 18:21:57.624 | disconnection: session time: 0:02:07.925 |

Después de cerrar la sesión, `pg_stat_activity` solo lista la sesión de `postgres` (PID 732). La duración de 2:07 es la de la sesión completa y no la del `pg_sleep(90)`: la sesión siguió abierta hasta escribir `\q`.

`pg_sleep` no aparece en la bitácora porque `log_statement = mod` no registra los `SELECT`.

## Respuestas

1. **¿Qué columna relaciona una sesión con sus líneas de bitácora?** `pid`. Es el mismo número que aparece entre corchetes (`%p`) en cada línea.
2. **Después de que termina el reporte, ¿qué fuente conserva evidencia de que existió?** La bitácora (conexión, desconexión y duración). `pg_stat_activity` solo muestra el estado actual y ya no lista esa sesión.
3. **¿Por qué `client_addr` aparece vacío en la sesión del administrador?** En la guía el administrador entra por socket local, que no tiene IP. En este servidor de Windows SQL Shell se conecta por TCP a `localhost` (IPv6), por eso aparece `::1`. El campo refleja el tipo de conexión de la sesión.
