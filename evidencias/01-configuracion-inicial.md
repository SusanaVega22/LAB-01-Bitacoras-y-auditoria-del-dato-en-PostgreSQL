# Evidencia 01 — Configuración inicial de registro

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 1 (más identificación de la instalación, secciones 6.3 y 6.4)

## Identificación de la instalación (6.3)

Comandos: `SELECT version();`, `SHOW data_directory;`, `SHOW config_file;`, `SHOW hba_file;`

| Dato | Resultado |
|---|---|
| Versión | PostgreSQL 16.15, compiled by Visual C++ build 1944, 64-bit |
| data_directory | C:/Program Files/PostgreSQL/16/data |
| config_file | C:/Program Files/PostgreSQL/16/data/postgresql.conf |
| hba_file | C:/Program Files/PostgreSQL/16/data/pg_hba.conf |

## Reglas de autenticación (6.4)

Comando: `SELECT line_number, type, database, user_name, address, auth_method FROM pg_hba_file_rules WHERE database = '{all}';`

| line_number | type | address | auth_method |
|---|---|---|---|
| 113 | local | | scram-sha-256 |
| 115 | host | 127.0.0.1 | scram-sha-256 |
| 117 | host | ::1 | scram-sha-256 |

Ninguna regla usa `trust`, así que no fue necesario modificar `pg_hba.conf`.

**Pregunta: ¿Por qué una regla `trust` afecta lo que la bitácora puede demostrar sobre la identidad del usuario?**
Con `trust`, PostgreSQL deja entrar sin pedir contraseña, así que cualquiera podría conectarse diciendo que es `app_ventas`. La bitácora registraría ese nombre, pero no demostraría quién estaba detrás, y tampoco habría accesos fallidos que registrar. Por eso el endurecimiento de la Unidad II (autenticación fuerte y reglas específicas en `pg_hba.conf`) es la base de la auditoría: sin autenticación confiable, la evidencia de identidad no vale.

## Configuración de registro por defecto (Actividad 1)

Comando: `SELECT name, setting, source FROM pg_settings WHERE name IN (...);`

| Parámetro | Valor | Origen |
|---|---|---|
| logging_collector | on | configuration file |
| log_destination | stderr | configuration file |
| log_directory | log | default |
| log_filename | postgresql-%Y-%m-%d_%H%M%S.log | default |
| log_connections | off | default |
| log_disconnections | off | default |
| log_line_prefix | %t | configuration file |
| log_statement | none | default |
| log_min_error_statement | error | default |
| log_timezone | America/Chihuahua | configuration file |

Diferencias con la guía: en este servidor de Windows el colector ya viene activado y el prefijo es `%t` (solo fecha y hora).

## Respuestas

1. **¿Se registra quién se conecta?** No. `log_connections` y `log_disconnections` están en `off`.
2. **¿Se registran las sentencias UPDATE?** No. `log_statement` es `none`.
3. **¿La línea incluye usuario o IP del cliente?** No. El prefijo `%t` solo pone fecha y hora; no incluye PID, usuario, base, aplicación ni cliente. Una línea diría qué pasó, pero no quién ni desde dónde.
4. **¿Zona horaria y por qué importa?** `America/Chihuahua`. Al reconstruir una cronología todos los eventos deben compararse contra una sola referencia de tiempo. La bitácora marcaba `17:54 CST` cuando el reloj del equipo decía `4:54 p. m.`: una hora de diferencia que puede desordenar los hechos si no se tiene en cuenta.
5. **Con `logging_collector`, ¿quién decide dónde termina la bitácora?** En este servidor lo decide PostgreSQL, porque el colector está en `on` y escribe en la carpeta `log` del directorio de datos. Con el colector apagado lo decidiría el mecanismo de despliegue.
