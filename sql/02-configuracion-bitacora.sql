-- LAB-01 | Actividad 4: configuración de la bitácora
ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;
ALTER SYSTEM SET log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%h ';
ALTER SYSTEM SET log_statement = 'ddl';
SELECT pg_reload_conf();

-- Verificación (en una consulta posterior y en una sesión nueva)
SELECT name, setting, source, sourcefile
FROM pg_settings
WHERE name IN ('log_connections', 'log_disconnections', 'log_line_prefix', 'log_statement');

SELECT num, linea FROM dba.bitacora ORDER BY num DESC LIMIT 8;

-- Actividad 7: nivel mod
ALTER SYSTEM SET log_statement = 'mod';
SELECT pg_reload_conf();
