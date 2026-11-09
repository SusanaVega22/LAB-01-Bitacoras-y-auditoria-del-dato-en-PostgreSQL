# Evidencia 02 — Colector de bitácora y vista dba.bitacora

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 2

## Comandos y resultados

- `SELECT pg_current_logfile();` → `log/postgresql-2026-10-25_143106.log` y, tras la rotación del día, `log/postgresql-2026-10-26_000000.log`.
- `SELECT name, size FROM pg_ls_logdir() ORDER BY name;` → tres archivos: `postgresql-2026-10-25_142630.log` (525 bytes), `postgresql-2026-10-25_143106.log` (2318) y `postgresql-2026-10-26_000000.log` (340).
- `CREATE SCHEMA dba;`, `REVOKE ALL ON SCHEMA dba FROM PUBLIC;` y `CREATE VIEW dba.bitacora` (en `sql/01-colector-y-vista.sql`).

## Adaptaciones al entorno (Windows en español)

1. **El colector ya estaba activado** (`logging_collector = on`), por lo que no hizo falta reiniciar el servicio.
2. **Error de codificación.** La primera versión de la vista falló con `secuencia de bytes no válida para codificación «UTF8»: 0xfa`: el archivo de bitácora está en Windows-1252 y tiene acentos. Se resolvió leyendo el archivo como bytes y convirtiéndolo con `convert_from(pg_read_binary_file(...), 'LATIN1')`. Hubo que borrar y recrear la vista (`DROP VIEW` y `CREATE VIEW`), porque `CREATE OR REPLACE` no permite cambiar el ordenamiento de la columna.
3. **Mensajes en español.** Para que coincidan los filtros de la guía se ejecutó `ALTER SYSTEM SET lc_messages = 'C';` y `SELECT pg_reload_conf();`.

## Respuestas

1. **¿Por qué `logging_collector` requiere reinicio y `log_statement` solo recarga?** El colector es un proceso aparte que el servidor arranca al inicio y que captura la salida de todos los demás procesos, así que no se puede encender o apagar con el servidor funcionando. `log_statement` es solo un valor que cada sesión lee y se actualiza con una recarga.
2. **¿Ventaja y riesgo de leer con SQL?** Funciona igual en cualquier sistema operativo o despliegue, no necesita permisos del sistema y se puede filtrar con SQL. El riesgo es que depende de funciones que leen archivos del servidor (`pg_read_file`, `pg_read_binary_file`), restringidas a superusuarios. Si la vista se abre a otros roles, quedan expuestos datos sensibles que la bitácora pueda contener, como contraseñas.
3. **¿Quién debería consultar `dba.bitacora`?** Solo el DBA o un auditor designado. Por eso el esquema `dba` no tiene acceso para `PUBLIC`.

## Límite de la vista

Solo lee el archivo vigente. Cuando el colector rota el archivo o el servidor se reinicia, comienza uno nuevo (por eso la vista mostraba pocas líneas al inicio). `pg_ls_logdir()` lista todos los archivos.
