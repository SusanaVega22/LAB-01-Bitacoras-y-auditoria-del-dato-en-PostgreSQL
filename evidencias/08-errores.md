# Evidencia 08 — Errores y operaciones rechazadas

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 8

## Comandos

1. Como `soporte_ana`: `DELETE FROM clientes WHERE id = 5;` → `ERROR: permission denied for table clientes`
2. Como administrador: `DROP ROLE soporte_ana;` → `ERROR: role "soporte_ana" cannot be dropped because some objects depend on it` / `DETAIL: privileges for table clientes`

## Líneas de la bitácora

| Hora | PID | Usuario | Cliente | Mensaje |
|---|---|---|---|---|
| 18:17:14 | 24800 | soporte_ana | 127.0.0.1 | ERROR: permission denied for table clientes |
| 18:17:14 | 24800 | soporte_ana | 127.0.0.1 | STATEMENT: DELETE FROM clientes WHERE id = 5; |
| 18:17:39 | 732 | postgres | ::1 | ERROR: role "soporte_ana" cannot be dropped because some objects depend on it |
| 18:17:39 | 732 | postgres | ::1 | DETAIL: privileges for table clientes |
| 18:17:39 | 732 | postgres | ::1 | STATEMENT: DROP ROLE soporte_ana; |

Las sentencias que provocan errores se registran gracias a `log_min_error_statement = error`, independientemente de `log_statement`.

## Respuestas

1. **¿El intento de `soporte_ana` causó daño? ¿Por qué auditarlo?** No, PostgreSQL lo rechazó y el cliente 5 sigue en la tabla. Se audita porque muestra que una cuenta intentó una operación que no le corresponde (abuso, cuenta comprometida o error). La bitácora dice quién, cuándo y desde dónde.
2. **Error de autorización frente a autenticación:** en el de autorización (`permission denied`) la identidad ya fue verificada y la sesión se abrió, pero el usuario no tiene permiso para esa operación. En el de autenticación (Actividad 5) la sesión nunca se estableció porque la identidad no se pudo comprobar.
3. **¿Qué indica el error de `DROP ROLE` sobre dar de baja a un usuario?** Que primero hay que retirar sus privilegios y reasignar o eliminar los objetos que le pertenecen (por ejemplo con `REVOKE`, `REASSIGN OWNED` y `DROP OWNED`) y solo después ejecutar `DROP ROLE`.
