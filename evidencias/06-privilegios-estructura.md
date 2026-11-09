# Evidencia 06 — Cambios de privilegios y de estructura

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 6

## Comandos (ver `sql/03-privilegios-estructura.sql`)

`REVOKE UPDATE ON clientes FROM soporte_ana;`, `GRANT UPDATE ON clientes TO app_ventas;`, `ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20);`, `CREATE ROLE rol_temporal LOGIN PASSWORD '...';` y `DROP ROLE rol_temporal;`

## Resultado en la bitácora (`log_statement = 'ddl'`)

| Hora | Usuario | Cliente | Sentencia |
|---|---|---|---|
| 18:07:07 | postgres | ::1 | REVOKE UPDATE ON clientes FROM soporte_ana |
| 18:07:16 | postgres | ::1 | GRANT UPDATE ON clientes TO app_ventas |
| 18:07:29 | postgres | ::1 | ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20) |
| 18:07:41 | postgres | ::1 | CREATE ROLE rol_temporal LOGIN PASSWORD '(contraseña en texto claro)' |
| 18:07:52 | postgres | ::1 | DROP ROLE rol_temporal |

**La contraseña del rol temporal quedó en texto claro en la bitácora y eliminar el rol no la borra.** En esta evidencia se omitió.

Nota: a las 18:09:42 se repitió el script con `<REDACTED>` para guardar el archivo SQL sin la contraseña (el `ALTER TABLE` dio `column "segmento" already exists`). Esas líneas son una repetición y no son eventos nuevos.

## Respuestas

1. **Tipo de evento:** `REVOKE` y `GRANT` son eventos de **privilegio**; `ALTER TABLE ... ADD COLUMN` es de **estructura**.
2. **¿Por qué GRANT y REVOKE se registran con `log_statement = 'ddl'`?** Porque ese nivel incluye las sentencias de definición (`CREATE`, `ALTER`, `DROP`) y también `GRANT`, `REVOKE` y `COMMENT`.
3. **Si la bitácora contiene contraseñas, ¿quién debería leerla?** Solo el DBA o un auditor designado, con permisos restringidos en el archivo y en la vista `dba.bitacora`. Se relaciona con la gestión de secretos de la Unidad II: las contraseñas no deben escribirse dentro de sentencias SQL; se asignan con `\password`, que envía solo el resumen SCRAM. Una contraseña que quedó en la bitácora debe considerarse comprometida aunque el rol se haya eliminado.
