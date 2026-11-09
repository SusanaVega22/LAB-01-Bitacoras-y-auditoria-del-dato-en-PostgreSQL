# LAB-01 — Bitácoras y auditoría del dato en PostgreSQL

**Estudiante:** Susana Valentina Vega García · Grupo 4-4 · Universidad Autónoma de Sinaloa, Facultad de Informática Culiacán
**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos · Unidad III

## Despliegue y versión

- Servidor propio con instalación **nativa en Windows** (instalador de PostgreSQL), **PostgreSQL 16.15** (Visual C++ build 1944, 64-bit).
- Directorio de datos: `C:/Program Files/PostgreSQL/16/data`.
- Sesión de administrador: SQL Shell (psql) como `postgres`. Sesión por red: `psql.exe` desde PowerShell con una cadena de conexión a `127.0.0.1`.
- Base de datos `comercial`, roles `app_ventas` y `soporte_ana`.

## Adaptaciones por Windows en español

1. El colector (`logging_collector`) ya venía activado, por lo que no se reinició el servicio.
2. La bitácora está en Windows-1252: la vista `dba.bitacora` lee el archivo con `convert_from(pg_read_binary_file(...), 'LATIN1')`.
3. Se fijó `lc_messages = 'C'` para que los mensajes salgan en inglés y coincidan los filtros de la guía.
4. El administrador se conecta por `::1` (TCP) y no por socket local, por eso `client=::1` y no `[local]`.
5. No aparecieron líneas `parameter "..." changed to ...` en la bitácora; se documentó así.
6. La bitácora se exportó con `\o` desde SQL Shell y no con la redirección `>`.

## Contenido

| Carpeta o archivo | Contenido |
|---|---|
| `sql/` | Seis scripts con los comandos ejecutados |
| `evidencias/01` a `15` | Una evidencia `.md` por actividad, con comando, resultado e interpretación |
| `evidencias/exportacion-bitacora.md` | Actividad 16 (exportar y conservar la bitácora) |
| `evidencias/bitacora-lab01.log` y `.sha256` | Bitácora exportada con la contraseña sustituida por `<REDACTED>` y su hash SHA-256 |
| `informe.md` | Informe final |

La Parte C (pgaudit) es opcional y no se realizó.

## Resultado resumido

- La configuración por defecto no permitía responder a Dirección: no registraba conexiones, usuarios ni sentencias.
- Con `log_connections`, `log_disconnections`, el prefijo `%m [%p] user=%u db=%d app=%a client=%h ` y `log_statement = 'mod'` se pueden demostrar accesos, cambios de privilegios y estructura, modificaciones y errores.
- La tabla `auditoria.cambios_clientes` con disparador conserva el valor anterior y el nuevo de cada cambio.
- Un administrador con control total puede desactivar el disparador; queda rastro en la bitácora pero no en la auditoría.
- Las contraseñas escritas en sentencias SQL quedan en texto claro en la bitácora.
