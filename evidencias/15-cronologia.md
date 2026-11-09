# Evidencia 15 — Cronología y respuestas a Dirección

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 17

Fecha de los eventos: 2026-11-02. Hora de la bitácora (CST). Consulta usada: filtro de la bitácora por `FATAL:`, `connection authorized`, `statement:` y `ERROR:`.

## Cronología

| # | Hora | Usuario | Cliente | Tipo | Qué ocurrió | ¿Exitoso? | Fuente |
|---|---|---|---|---|---|---|---|
| 1 | 18:03:51 | app_ventas | 127.0.0.1 | Acceso | Intento de conexión con contraseña incorrecta | No | Bitácora, línea 9 |
| 2 | 18:04:05 | usuario_inexistente | 127.0.0.1 | Acceso | Intento con un rol que no existe | No | Bitácora, línea 12 |
| 3 | 18:04:19 | app_ventas | 127.0.0.1 | Acceso | Conexión correcta (`app-ventas-web`) | Sí | Bitácora, línea 17 |
| 4 | 18:07:07 | postgres | ::1 | Privilegio | `REVOKE UPDATE` a `soporte_ana` | Sí | Bitácora, línea 19 |
| 5 | 18:07:29 | postgres | ::1 | Estructura | `ALTER TABLE clientes ADD COLUMN segmento` | Sí | Bitácora, línea 21 |
| 6 | 18:07:41 | postgres | ::1 | Privilegio | `CREATE ROLE rol_temporal` con contraseña en texto claro | Sí | Bitácora, línea 22 |
| 7 | 18:11:55 | postgres | ::1 | Configuración | `ALTER SYSTEM SET log_statement = 'mod'` | Sí | Bitácora, línea 37 |
| 8 | 18:13:26 | app_ventas | 127.0.0.1 | Datos | `UPDATE` del teléfono del cliente 3 | Sí | Bitácora, línea 41 |
| 9 | 18:17:14 | soporte_ana | 127.0.0.1 | Error | `DELETE` del cliente 5 rechazado (`permission denied`) | No | Bitácora, líneas 48 y 49 |
| 10 | 18:39:57 | app_ventas | 127.0.0.1 | Datos | `UPDATE` del RFC del cliente 3 (`XYZ` a `ZZZ`) | Sí | Bitácora, línea 106; auditoría `id_evento` 1 |
| 11 | 18:43:25 y 18:43:32 | postgres | ::1 | Datos | `INSERT` y `DELETE` de Pedro Ruiz | Sí | Bitácora, líneas 110 y 112; auditoría `id_evento` 2 y 3 |
| 12 | 18:44:43 | app_ventas | 127.0.0.1 | Estructura | Intento de desactivar el disparador (`must be owner`) | No | Bitácora, líneas 121 y 122 |
| 13 | 18:45:22 a 18:45:36 | postgres | ::1 | Estructura / Datos | Desactiva el disparador, cambia el RFC a `GHI` y lo reactiva | Sí | Bitácora, líneas 125 a 127; sin evento en auditoría |

Las líneas 26 a 32 (18:09:42) son una repetición del script de la Actividad 6 y no se cuentan como eventos nuevos.

## Respuestas a Dirección (solo con la evidencia)

1. **¿Quién cambió el RFC?**
   - **Actividad 3 (`XXX`):** No hay evidencia. El cambio se hizo antes de activar `log_connections` y `log_statement`, así que la bitácora no tiene ni la conexión ni la sentencia.
   - **Actividad 7 (`XYZ`):** No hay evidencia del `UPDATE`. La bitácora solo registra la sesión de `app_ventas` (línea 35, de 18:10:29 a 18:11:00) porque `log_statement` valía `ddl`. Es una inferencia por la sesión, no una prueba del cambio.
   - **Actividad 12 (`ZZZ`):** `app_ventas`, desde 127.0.0.1, aplicación `app-ventas-web`, 18:39:57.
   - **Actividad 14 (`GHI`):** `postgres`, desde `::1`, aplicación `psql`, 18:45:29, con el disparador desactivado.
2. **¿Quién cambió el teléfono?** `app_ventas`, desde 127.0.0.1, aplicación `app-ventas-web`, a las 18:13:26 (línea 41).
3. **¿Hubo intentos de acceso fallidos?** Sí, dos, ambos desde 127.0.0.1: `app_ventas` con contraseña incorrecta (18:03:51) y `usuario_inexistente` (18:04:05). Para el cambio de la Actividad 3 no se puede afirmar nada, porque no había registro de conexiones.
4. **¿Qué valor tenía el RFC antes de cada cambio?**
   - **Actividad 3 y Actividad 7:** No hay evidencia registrada.
   - **Actividad 12:** `GAMA780912XYZ` (auditoría, evento 1).
   - **Actividad 14:** No hay evidencia. La bitácora muestra la sentencia, pero el disparador estaba desactivado y la auditoría no guardó el valor anterior.

Un evento que no se registró no tiene hora: se declara como hueco, no se estima.
