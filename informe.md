# Informe — LAB-01 Bitácoras y auditoría del dato en PostgreSQL

Estudiante: Susana Valentina Vega García · Grupo 4-4 · UAS, Facultad de Informática Culiacán

## 1. Despliegue y situación inicial

Se desplegó un servidor PostgreSQL 16.15 con instalación nativa en Windows, con la base `comercial` y los roles `app_ventas` (SELECT, UPDATE) y `soporte_ana` (SELECT). Las reglas de `pg_hba.conf` ya exigían `scram-sha-256`, así que no se modificaron.

La configuración inicial tenía `logging_collector = on`, pero `log_connections` y `log_disconnections` en `off`, `log_statement = none` y el prefijo `%t` (solo fecha y hora). Con eso la bitácora no registraba quién se conectaba, no registraba sentencias y sus líneas no incluían usuario ni IP.

Por eso el servidor no podía responder a Dirección. En la Actividad 3 se cambió el RFC de María García con `app_ventas` y la bitácora no tenía rastro de la conexión ni del `UPDATE`.

## 2. Configuración aplicada

| Parámetro | Valor | Aplicación | Justificación |
|---|---|---|---|
| `logging_collector` | `on` (ya activo) | Reinicio | El servidor administra su propia bitácora y se lee con SQL |
| `lc_messages` | `C` | Recarga | Mensajes en inglés para que coincidan los filtros (adaptación a Windows) |
| `log_connections` | `on` | Recarga (solo sesiones nuevas) | Registrar accesos exitosos y fallidos |
| `log_disconnections` | `on` | Recarga (solo sesiones nuevas) | Registrar el fin y la duración de cada sesión |
| `log_line_prefix` | `%m [%p] user=%u db=%d app=%a client=%h ` | Recarga | Sin usuario, base y cliente una línea no dice quién ni desde dónde |
| `log_statement` | `ddl` y después `mod` | Recarga | `ddl` registra privilegios y estructura; `mod` agrega `INSERT`, `UPDATE` y `DELETE` |

Se eligió `mod` y no `all` por equilibrio: `all` registraría también las lecturas, pero con mucho más volumen y riesgo de guardar datos sensibles.

## 3. Eventos observados

| Tipo | Ejemplo interpretado |
|---|---|
| Acceso | 18:03:51, `app_ventas` desde 127.0.0.1: `password authentication failed`, regla `pg_hba.conf` línea 115. Prueba el origen y el momento, no quién escribió la contraseña |
| Privilegio | 18:07:07, `postgres`: `REVOKE UPDATE ON clientes FROM soporte_ana` |
| Estructura | 18:07:29, `postgres`: `ALTER TABLE clientes ADD COLUMN segmento` |
| Datos | 18:13:26, `app_ventas` desde `app-ventas-web`: `UPDATE` del teléfono del cliente 3 |
| Error | 18:17:14, `soporte_ana`: `DELETE` rechazado con `permission denied for table clientes`, con la sentencia que lo causó |
| Configuración | 18:11:55, `postgres`: `ALTER SYSTEM SET log_statement = 'mod'`. En esta instalación no aparecieron las líneas `parameter ... changed to ...` |

## 4. Auditoría del dato

Se creó el esquema `auditoria` (sin acceso para `PUBLIC`) y la tabla `cambios_clientes` con momento, usuario de sesión, usuario efectivo, aplicación, IP, operación, id del cliente y los valores antes y después en JSONB. Un disparador `AFTER INSERT OR UPDATE OR DELETE ... FOR EACH ROW` la llena mediante una función `SECURITY DEFINER` con `search_path` fijo.

`SECURITY DEFINER` permite que `app_ventas` provoque la escritura en la auditoría sin tener privilegios sobre ella. Dentro de esa función, `current_user` es el propietario (`postgres`), por eso la auditoría usa `session_user` para saber quién provocó el cambio.

En el incidente auditado, `app_ventas` cambió el RFC del cliente 3 de `GAMA780912XYZ` a `GAMA780912ZZZ` a las 18:39:57 desde 127.0.0.1 con `app-ventas-web`, y la propia aplicación no pudo leer ni borrar la auditoría.

## 5. Limitaciones

- **Lecturas:** nada registra los `SELECT`. `soporte_ana` leyó el RFC y no quedó rastro.
- **Volumen:** un `UPDATE` masivo genera una línea en la bitácora pero una fila por registro en la auditoría (5 filas en la práctica).
- **Administrador con control total:** `postgres` desactivó el disparador, cambió el RFC y lo reactivó. La auditoría tiene 3 eventos y no incluye ese cambio; solo la bitácora conserva las sentencias.
- **Valores anteriores:** la bitácora solo guarda la sentencia, no el valor previo.

## 6. Riesgos de la bitácora

- **Secretos expuestos:** `CREATE ROLE ... PASSWORD '...'` dejó la contraseña en texto claro y borrar el rol no la elimina. Las contraseñas deben asignarse con `\password`.
- **Pérdida:** la bitácora rota por día y se reinicia con el servidor; la vista solo lee el archivo vigente. Conservarla solo en el servidor que la produce la expone a fallas y a alteración.
- **Acceso de terceros:** quien pueda leer la bitácora o la vista accede a datos sensibles. `dba.bitacora` se restringió y la bitácora se exportó con la contraseña sustituida por `<REDACTED>`.
- **Integridad:** se calculó el hash SHA-256 del archivo exportado (`fb59e16a170a691ef91b4ac2a486e41e749d6bad098557d3be1b5dd47a4c62df`). Detecta cambios, no los impide; debe guardarse fuera del servidor.

## 7. Cronología y conclusión

La cronología completa está en `evidencias/15-cronologia.md`.

**¿Con esta configuración puede demostrarse quién cambió un dato sensible y qué valor tenía antes?** Sí, pero solo desde que existen la bitácora configurada y el disparador. Los cambios del RFC de las Actividades 3 y 7 no pueden atribuirse y su valor anterior no consta (hueco). El cambio de la Actividad 12 sí: `app_ventas`, `app-ventas-web`, 127.0.0.1, 18:39:57, de `XYZ` a `ZZZ`. El de la Actividad 14 quedó con la sentencia en la bitácora pero sin valor anterior, porque el disparador estaba desactivado. Ningún mecanismo dentro del propio servidor protege contra un administrador con control total, por lo que hacen falta bitácoras externas y separación entre quien opera y quien custodia la evidencia.

## Preguntas de reflexión

1. **¿Por qué la auditoría no puede configurarse después de un incidente para investigarlo?** Porque la bitácora solo contiene lo que se registró cuando ocurrió; lo que no se registró no tiene hora ni usuario y no se puede reconstruir (Actividad 3).
2. **¿Por qué conviene que la bitácora la administre el propio servidor?** Porque con el colector las funciones del motor indican y leen el archivo vigente en cualquier plataforma, sin depender del mecanismo de despliegue.
3. **¿Por qué el prefijo de línea es tan importante como el nivel de `log_statement`?** Porque sin usuario, base, aplicación y cliente una línea dice qué ocurrió pero no quién ni desde dónde.
4. **¿Qué diferencia hay entre registrar la sentencia y registrar el cambio en el dato?** La sentencia dice qué se ejecutó; el cambio guarda el valor anterior y el nuevo por cada registro. Un `UPDATE` masivo deja una línea de bitácora pero cinco filas de auditoría.
5. **¿Qué ofrece `pg_stat_activity` que no ofrece la bitácora, y viceversa?** `pg_stat_activity` muestra lo que ocurre ahora (la sesión `reporte-mensual` mientras corría); la bitácora conserva la historia cuando la sesión ya terminó.
6. **Si el administrador puede cambiar `log_statement` a `none` y desactivar el disparador, ¿quién audita al administrador?** Nadie dentro del servidor. Se necesita enviar la bitácora a un sistema externo administrado por otra área y guardar los hashes fuera del servidor.
