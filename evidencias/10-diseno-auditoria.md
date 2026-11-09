# Evidencia 10 — Diseño del registro de auditoría

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 10

## Diseño de campos

| Campo | Tipo | ¿Qué pregunta responde? | ¿Puede ser nulo? ¿Por qué? |
|---|---|---|---|
| id_evento | BIGSERIAL | Identifica y ordena cada evento | No, es la clave primaria |
| momento | TIMESTAMPTZ | ¿Cuándo? | No |
| usuario_sesion | TEXT | ¿Quién lo hizo? | No, siempre existe |
| usuario_efectivo | TEXT | ¿Con qué privilegios se ejecutó? | No |
| aplicacion | TEXT | ¿Desde qué aplicación? | Sí: el cliente puede no declararla |
| ip_cliente | INET | ¿Desde qué equipo? | Sí: no hay IP en conexiones por socket local |
| operacion | TEXT | ¿Qué ocurrió? (INSERT, UPDATE, DELETE) | No |
| id_cliente | BIGINT | ¿Sobre qué registro? | Sí en general; aquí siempre se llena |
| valores_antes | JSONB | ¿Qué valor tenía antes? | Sí: vacío en INSERT |
| valores_despues | JSONB | ¿Qué valor tiene ahora? | Sí: vacío en DELETE |

Creación: `sql/04-esquema-auditoria.sql`. Resultado: `\dt auditoria.*` lista la tabla `cambios_clientes` (dueño `postgres`) y la bitácora registra `CREATE SCHEMA` (18:36:04), `REVOKE ALL ON SCHEMA` (18:36:12) y `CREATE TABLE` (18:36:21).

## Respuestas

1. **¿Por qué `TIMESTAMPTZ` y no `TIMESTAMP`?** Guarda un instante absoluto con zona horaria, así los eventos se pueden comparar aunque cambie la zona del servidor o del cliente. En esta práctica se vio la diferencia entre la hora de la bitácora y la del reloj del equipo.
2. **¿Por qué el registro completo en JSONB y no solo la columna que cambió?** Conserva el estado completo aunque `clientes` cambie de estructura (como cuando se agregó `segmento`) y permite revisar cualquier campo, no solo el que se pensó auditar.
3. **¿Qué implica que la tabla contenga RFC?** Es un dato personal. La tabla debe clasificarse al menos igual de sensible que `clientes`, con acceso restringido (esquema sin acceso para `PUBLIC`) y una retención definida, porque duplica datos, incluidos valores antiguos.
