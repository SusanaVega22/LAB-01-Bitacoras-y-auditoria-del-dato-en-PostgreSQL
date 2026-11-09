# Evidencia 14 — Límites: lecturas y volumen

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 15

## Comandos y resultados

- Como `soporte_ana`: `SELECT nombre, rfc, telefono FROM clientes WHERE id = 3;` → devuelve María García, `GAMA780912GHI`, `6679990000`.
- Como administrador: `UPDATE clientes SET segmento = 'regular';` → `UPDATE 5`.

| Consulta | Resultado |
|---|---|
| Líneas de bitácora del `UPDATE` masivo | 1 |
| Auditoría por operación | DELETE 1, INSERT 1, UPDATE 6 |
| Lecturas de `soporte_ana` en la bitácora | 0 |

- El `UPDATE` masivo produjo **una línea** en la bitácora y **cinco filas nuevas** en la auditoría.
- La lectura del RFC **no dejó rastro**: no existe disparador para `SELECT` y `mod` no registra consultas.

| Alternativa para registrar lecturas | Ventaja | Desventaja |
|---|---|---|
| `log_statement = 'all'` | No requiere instalar nada | Registra todas las consultas de todas las tablas |
| Entregar el dato solo mediante una función que registre su uso | Control preciso | Requiere cambiar la aplicación |
| `pgaudit` con auditoría de objeto (Parte C) | Registra lecturas por tabla y columna | Requiere instalar una extensión |

## Respuestas

1. **¿Qué pasaría tras un `UPDATE` sin `WHERE` con un millón de registros?** La bitácora seguiría teniendo 1 línea, pero la auditoría recibiría un millón de filas, una por registro (el disparador es `FOR EACH ROW`). Eso hace más lento el `UPDATE`, consume mucho disco (cada fila guarda dos copias en JSONB) y deja una tabla enorme y difícil de revisar.
2. **¿Quién podría autorizar la depuración de `auditoria.cambios_clientes`?** Quien define la política de retención de la organización (responsable de datos personales, cumplimiento o seguridad de la información), con la participación de un auditor. El DBA ejecuta la depuración pero no debe decidirla solo, porque la auditoría también lo vigila a él.
3. **¿Por qué `log_statement = 'all'` puede volver la bitácora un nuevo depósito de datos sensibles?** Porque registra el texto de todas las consultas de todas las tablas con los valores literales (RFC, teléfonos, filtros con datos personales y hasta contraseñas), duplicando datos sensibles en un archivo de texto con controles más débiles que la base.
