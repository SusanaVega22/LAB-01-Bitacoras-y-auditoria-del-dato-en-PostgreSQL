# Evidencia 04 — Configuración de la bitácora

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 4

## Comandos

Ver `sql/02-configuracion-bitacora.sql`: `log_connections = on`, `log_disconnections = on`, `log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%h '`, `log_statement = 'ddl'` y `SELECT pg_reload_conf();`.

## Resultado

| Parámetro | Valor | Origen |
|---|---|---|
| log_connections | on | configuration file |
| log_disconnections | on | configuration file |
| log_line_prefix | %m [%p] user=%u db=%d app=%a client=%h | configuration file |
| log_statement | ddl | configuration file (postgresql.auto.conf) |

Observación: `log_connections` y `log_disconnections` seguían en `off` en la sesión que ya estaba abierta, porque estos parámetros solo aplican a **sesiones nuevas**. Tras reconectar con `\c comercial` ya aparecieron en `on`.

Líneas nuevas en la bitácora (sesión del administrador, 18:02:13, `client=::1`): `connection received`, `connection authenticated: identity="postgres" method=scram-sha-256 (pg_hba.conf:117)` y `connection authorized: user=postgres database=comercial application_name=psql`.

## Análisis

- Las sentencias `ALTER SYSTEM` no aparecen, porque cuando se ejecutaron `log_statement` todavía valía `none`.
- Tu propia sesión de administrador sí aparece: consultar la bitácora también queda registrado.
- `client=::1` es SQL Shell conectándose por `localhost`, que Windows resuelve por IPv6.
- **Diferencia con la guía:** en esta instalación de Windows no aparecieron líneas `parameter "..." changed to ...`. Se dejó documentado así y no se inventó. Como evidencia del evento de tipo configuración se usa la línea `statement: ALTER SYSTEM SET log_statement = 'mod'` (ver evidencia 07).

## Respuestas

1. **¿Por qué el cambio lo registra el proceso principal y no tu sesión?** Porque la sesión solo envía la señal de recarga con `pg_reload_conf()`. Quien lee los archivos de configuración y aplica los valores es el proceso principal del servidor.
2. **¿Qué pasa si alguien ejecuta `ALTER SYSTEM SET log_statement = 'none'`?** Sí queda rastro: con `ddl` activo esa sentencia se registra (usuario, hora y origen) antes de ejecutarse. Después de la recarga dejan de registrarse las sentencias siguientes, pero la evidencia del cambio ya quedó en la bitácora.
3. **¿Por qué no editar `postgresql.auto.conf` a mano?** Porque ese archivo lo administra el servidor. `ALTER SYSTEM` valida el parámetro y el formato, y su sentencia queda registrada. Una edición manual puede dejar el archivo con errores (el servidor podría no arrancar) y no deja rastro de quién la hizo.
