-- LAB-01 | Actividad 2: colector de bitácora y vista dba.bitacora
-- Adaptación a Windows (en español): mensajes en inglés y lectura del archivo como LATIN1.
ALTER SYSTEM SET lc_messages = 'C';
SELECT pg_reload_conf();

SELECT pg_current_logfile();
SELECT name, size FROM pg_ls_logdir() ORDER BY name;

CREATE SCHEMA dba;
REVOKE ALL ON SCHEMA dba FROM PUBLIC;

CREATE VIEW dba.bitacora AS
SELECT t.n AS num, t.linea
FROM regexp_split_to_table(convert_from(pg_read_binary_file(pg_current_logfile()), 'LATIN1'), E'\n')
     WITH ORDINALITY AS t(linea, n)
WHERE t.linea <> '';

-- Consultas de uso
SELECT num, linea FROM dba.bitacora ORDER BY num DESC LIMIT 10;
SELECT linea FROM dba.bitacora WHERE linea ILIKE '%update%';
SELECT linea FROM dba.bitacora WHERE linea ~ '(FATAL|ERROR)';
