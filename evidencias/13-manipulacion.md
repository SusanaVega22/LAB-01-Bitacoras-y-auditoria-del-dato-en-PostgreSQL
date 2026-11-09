# Evidencia 13 — Intentar manipular la auditoría

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 14

## Como la aplicación (`app_ventas`, contraseña omitida)

- `DELETE FROM auditoria.cambios_clientes;` → `ERROR: permission denied for schema auditoria`
- `ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes;` → `ERROR: must be owner of table clientes`

## Como administrador

`ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes;` / `UPDATE clientes SET rfc = 'GAMA780912GHI' WHERE id = 3;` (`UPDATE 1`) / `ALTER TABLE clientes ENABLE TRIGGER trg_auditoria_clientes;`

`SELECT count(*) FROM auditoria.cambios_clientes;` → **3**. El cambio de RFC no quedó en la tabla de auditoría.

## Bitácora

| Hora | Usuario | Cliente | Sentencia |
|---|---|---|---|
| 18:44:43 | app_ventas | 127.0.0.1 | ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes (falló) |
| 18:45:22 | postgres | ::1 | ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes |
| 18:45:29 | postgres | ::1 | UPDATE clientes SET rfc = 'GAMA780912GHI' WHERE id = 3 |
| 18:45:36 | postgres | ::1 | ALTER TABLE clientes ENABLE TRIGGER trg_auditoria_clientes |

La primera línea es el intento de `app_ventas`: con `ddl` la sentencia se registra antes de ejecutarse, aunque después falle.

| Mecanismo | Qué registra | Quién lo puede desactivar |
|---|---|---|
| Tabla de auditoría | Detalle del dato (antes y después) | El propietario de la tabla |
| Bitácora del servidor | Que el mecanismo se desactivó | Quien controle el servidor |

## Respuestas

1. **¿Qué evidencia permite detectar un cambio sin auditar?** La bitácora: registra que se desactivó el disparador y que se hizo un `UPDATE` mientras estaba apagado. Además, el conteo de la auditoría no creció aunque el `UPDATE` afectó una fila.
2. **¿Qué control administrativo reduciría este riesgo?** Enviar la bitácora a un sistema externo administrado por otra área, exigir autorización documentada para cambiar o desactivar un disparador y que alguien distinto del DBA revise periódicamente la bitácora.
3. **Relación con la separación de funciones de la Unidad II:** un administrador con control total puede desactivar el control y operar sin dejar detalle en la auditoría. Por eso quien opera la base no debe ser quien custodia la evidencia.
