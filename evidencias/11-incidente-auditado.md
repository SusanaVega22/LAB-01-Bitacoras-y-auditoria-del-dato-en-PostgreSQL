# Evidencia 11 — Función, disparador e incidente auditado

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividades: 11 y 12

## Actividad 11: función y disparador

Código en `sql/05-funcion-disparador.sql`. Verificación: `SELECT tgname, tgenabled, tgrelid::regclass FROM pg_trigger WHERE NOT tgisinternal;` → `trg_auditoria_clientes | O | clientes` (habilitado).

Bitácora: se registraron `CREATE OR REPLACE FUNCTION` (18:37:30), `REVOKE ALL ON FUNCTION` (18:37:43) y `CREATE TRIGGER` (18:38:10). Las sentencias de varias líneas solo muestran su primera línea en el filtro `statement:`.

**Preguntas**

1. **¿Por qué `REVOKE ALL ON FUNCTION ... FROM PUBLIC` si el disparador seguirá funcionando para `app_ventas`?** PostgreSQL da permiso de ejecución a `PUBLIC` por defecto y una función `SECURITY DEFINER` no debería quedar disponible para cualquiera. El permiso para ejecutar la función del disparador se comprueba al crear el disparador, no cada vez que se dispara.
2. **Hipótesis: ¿qué pasaría sin `SECURITY DEFINER`?** La función correría con los privilegios de `app_ventas`, que no tiene acceso al esquema `auditoria`. El `INSERT` de la auditoría fallaría con `permission denied` y, como el error ocurre dentro del disparador, el `UPDATE` completo se cancelaría. Esto es un razonamiento; no se probó.
3. **¿Quedó registrada la creación del esquema, la tabla, la función y el disparador?** Sí. Son sentencias de definición y `log_statement` estaba en `mod`, que incluye `ddl`.

## Actividad 12: el incidente auditado

Como `app_ventas` (contraseña omitida): `UPDATE clientes SET rfc = 'GAMA780912ZZZ' WHERE id = 3;` → `UPDATE 1`. Luego `SELECT * FROM auditoria.cambios_clientes;` → `ERROR: permission denied for schema auditoria`.

Como administrador (`\x`):

| Campo | Valor |
|---|---|
| id_evento | 1 |
| momento | 2026-11-02 18:39:57.476133-06 |
| usuario_sesion | app_ventas |
| usuario_efectivo | postgres |
| aplicacion | app-ventas-web |
| ip_cliente | 127.0.0.1 |
| operacion | UPDATE |
| id_cliente | 3 |

Consulta de comparación (`sql/06-campos-modificados.sql`): campo `rfc`, antes `GAMA780912XYZ`, después `GAMA780912ZZZ`.

`usuario_efectivo` es `postgres` porque dentro de una función `SECURITY DEFINER`, `current_user` es el propietario de la función. Por eso la auditoría usa `session_user` para saber quién provocó el cambio.

**Preguntas**

1. **Hipótesis frente al resultado:** el `UPDATE` de `app_ventas` funcionó aunque esa cuenta no tiene acceso al esquema `auditoria`, y eso se explica porque la función corre con los privilegios de su propietario (`postgres`).
2. **Sentencia que restauraría el valor anterior** (no se ejecutó, para no generar otro evento):
```sql
UPDATE clientes SET rfc = 'GAMA780912XYZ' WHERE id = 3;
```
3. **¿`aplicacion` o `ip_cliente`?** `ip_cliente` conserva más valor porque la registra el servidor a partir de la conexión. `aplicacion` es el `application_name` que declara el propio cliente y cualquiera puede escribir otro nombre; distingue aplicaciones legítimas pero no es evidencia fuerte de identidad.
