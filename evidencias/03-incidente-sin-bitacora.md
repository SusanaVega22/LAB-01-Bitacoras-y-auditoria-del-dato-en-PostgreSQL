# Evidencia 03 — El incidente sin bitácora

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 3

## Comandos y resultados

Conexión por red como la aplicación (sesión interactiva de `psql`, contraseña omitida):

```
psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web"
comercial=> UPDATE clientes SET rfc = 'GAMA780912XXX' WHERE id = 3;
UPDATE 1
```

Búsqueda en la bitácora desde la sesión de administrador:

```sql
SELECT linea FROM dba.bitacora WHERE linea ILIKE '%update%' OR linea LIKE '%app_ventas%';
```

Resultado: `(0 filas)`. No aparece el `UPDATE` ni la conexión de `app_ventas`.

## Respuestas

1. **¿Puedes demostrar quién modificó el RFC?** No. La bitácora no tiene la conexión de `app_ventas` ni el `UPDATE`; solo hay líneas internas del servidor (checkpoints). Sin eso no hay usuario, hora ni origen.
2. **¿Puedes demostrar que no lo hizo `soporte_ana`?** No. Por permisos, `soporte_ana` solo tiene `SELECT`, pero eso es un argumento de configuración, no evidencia de lo ocurrido, porque no hay registro de ninguna sesión.
3. **¿Los privilegios impidieron el cambio? ¿Debían impedirlo?** No lo impidieron, y tampoco debían: `app_ventas` tiene permiso legítimo de actualizar `clientes`. El control de acceso decide quién puede hacer algo, pero no deja constancia de lo que ocurrió.
4. **¿Qué debía estar configurado antes del incidente?** El registro de conexiones y desconexiones, un prefijo de línea con usuario, base, aplicación y cliente, y `log_statement` en `mod` como mínimo. Para conservar el valor anterior del dato hace falta además la auditoría con disparador (Parte B).

**Idea central:** la auditoría no puede configurarse después para eventos que ya ocurrieron. Lo que no se registró en su momento no se puede reconstruir.
