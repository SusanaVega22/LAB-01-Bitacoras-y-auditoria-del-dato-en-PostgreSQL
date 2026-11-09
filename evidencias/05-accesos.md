# Evidencia 05 — Accesos exitosos y fallidos

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 5

## Comandos

Tres conexiones por red desde PowerShell (contraseña omitida):

1. `psql "postgresql://app_ventas:incorrecta@127.0.0.1/comercial"` → `password authentication failed for user "app_ventas"`
2. `psql "postgresql://usuario_inexistente:x@127.0.0.1/comercial"` → `password authentication failed for user "usuario_inexistente"`
3. `psql "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web"` seguido de `SELECT count(*) FROM clientes;` → 5

Filtro: `SELECT linea FROM dba.bitacora WHERE linea LIKE '%client=127.0.0.1%' ORDER BY num;`

## Líneas relevantes de la bitácora (resumen de los campos)

| Hora | PID | Usuario | Aplicación | Mensaje |
|---|---|---|---|---|
| 18:03:51.943 | 9620 | [unknown] | [unknown] | connection received: host=127.0.0.1 port=53894 |
| 18:03:51.961 | 9620 | app_ventas | [unknown] | FATAL: password authentication failed for user "app_ventas" |
| 18:03:51.961 | 9620 | app_ventas | [unknown] | DETAIL: Connection matched file pg_hba.conf line 115: host all all 127.0.0.1/32 scram-sha-256 |
| 18:04:05.584 | 21432 | usuario_inexistente | [unknown] | FATAL: password authentication failed for user "usuario_inexistente" |
| 18:04:05.584 | 21432 | usuario_inexistente | [unknown] | DETAIL: Role "usuario_inexistente" does not exist. |
| 18:04:19.375 | 24212 | app_ventas | [unknown] | connection authenticated: identity="app_ventas" method=scram-sha-256 (pg_hba.conf:115) |
| 18:04:19.375 | 24212 | app_ventas | [unknown] | connection authorized: ... application_name=app-ventas-web |
| 18:04:42.930 | 24212 | app_ventas | app-ventas-web | disconnection: session time: 0:00:23.583 |

## 11.1 Lectura campo por campo (línea FATAL de las 18:03:51 de `app_ventas`)

| Campo | Valor | Significado |
|---|---|---|
| Fecha y hora | 2026-11-02 18:03:51.961 CST | Momento exacto del evento, con milisegundos y zona horaria |
| PID | 9620 | Proceso del servidor que atendió la conexión; agrupa las líneas de una sesión |
| Usuario | app_ventas | Usuario con el que se intentó entrar |
| Base de datos | comercial | Base a la que se quiso conectar |
| Aplicación | [unknown] | Todavía no se conoce el `application_name` en esa etapa |
| Cliente | 127.0.0.1 | Dirección desde donde llegó la conexión |
| Severidad | FATAL | Error que termina la conexión |
| Mensaje | password authentication failed | La contraseña no coincide |
| Regla aplicada | pg_hba.conf línea 115 | `host all all 127.0.0.1/32 scram-sha-256` |

## Respuestas

1. **¿Eso prueba que la aplicación de ventas intentó entrar?** No. Prueba que alguien, desde el equipo 127.0.0.1 y a esa hora, intentó autenticarse con el nombre `app_ventas` y una contraseña incorrecta. El nombre de usuario lo escribe quien se conecta, así que cualquiera que lo conozca puede usarlo. La bitácora identifica el origen y el momento, no a la persona ni a la aplicación.
2. **¿Qué registra cuando el rol no existe y por qué solo en la bitácora?** Registra `DETAIL: Role "usuario_inexistente" does not exist`. El cliente recibe el mismo mensaje que con una contraseña incorrecta. Así un atacante no puede saber qué usuarios existen, pero el administrador sí ve la causa real.
3. **¿Por qué `app=[unknown]` en el intento fallido y `app=app-ventas-web` en la desconexión?** El `application_name` se aplica a la sesión cuando ya fue autenticada y autorizada. En el intento fallido la sesión nunca se establece, y en `connection authorized` el prefijo `%a` todavía dice `[unknown]`; después de eso ya se conoce.
4. **¿Qué patrón sugiere fuerza bruta y cuál es la consulta?** Muchas líneas `FATAL ... password authentication failed` en poco tiempo, desde la misma IP o contra el mismo usuario (o contra muchos usuarios distintos). Consulta:

```sql
SELECT substring(linea from 'user=([^ ]+)') AS usuario,
       substring(linea from 'client=([^ ]+)') AS cliente,
       count(*) AS intentos_fallidos
FROM dba.bitacora
WHERE linea LIKE '%FATAL:%password authentication failed%'
GROUP BY 1, 2
ORDER BY intentos_fallidos DESC;
```

Resultado: `app_ventas` desde 127.0.0.1, 1 intento; `usuario_inexistente` desde 127.0.0.1, 1 intento.
