# Evidencia — Exportar y conservar la bitácora

Estudiante: Susana Valentina Vega García (grupo 4-4, UAS, Facultad de Informática Culiacán)
Actividad: 16

## Procedimiento

Se creó la carpeta `C:\LAB-01\evidencias` y se exportó desde SQL Shell con `\o` (en lugar de la redirección `>` de la guía, porque en Windows la redirección de PowerShell cambia la codificación del archivo y la vista ya necesitaba una conversión LATIN1):

```
\encoding UTF8
\pset format unaligned
\pset tuples_only on
\o C:/LAB-01/evidencias/bitacora-lab01.log
SELECT replace(linea, '<contraseña del rol temporal>', '<REDACTED>') FROM dba.bitacora ORDER BY num;
\o
```

Verificación: el archivo tiene 268 líneas y `Select-String` de la contraseña original no devuelve nada; la palabra `REDACTED` aparece en las líneas 43 y 61 (`CREATE ROLE rol_temporal LOGIN PASSWORD '<REDACTED>'`).

Hash SHA-256 (archivo `bitacora-lab01.sha256`):

```
fb59e16a170a691ef91b4ac2a486e41e749d6bad098557d3be1b5dd47a4c62df  bitacora-lab01.log
```

Documentación para el informe: el archivo se exportó con la contraseña del rol temporal sustituida por `<REDACTED>`.

## Respuestas

1. **¿Un SHA-256 impide que alguien modifique la bitácora?** No. Solo permite detectar si cambió: si se modifica un carácter, el hash sale distinto. Permite demostrar que el archivo es el mismo que cuando se calculó el hash, siempre que el hash esté protegido.
2. **¿Dónde guardar el hash?** Fuera del servidor y en manos de otra área o persona: un repositorio con control de acceso (como el GitLab de la materia), un sistema de custodia o un documento firmado. Si el hash está junto al archivo y el mismo administrador puede cambiar ambos, no sirve como control.
3. **¿Riesgos de conservar la bitácora solo en el servidor que la produce?** Que se pierda si el servidor falla, se reinstala o rota los archivos, y que un atacante o administrador con control total la borre o altere para ocultar sus acciones. Además puede llenarse el disco y contiene datos sensibles en un solo lugar.
4. **¿Cuánto tiempo conservarla?** No hay cifra única. Propuesta: 12 meses (los primeros 3 de acceso rápido y el resto en archivo protegido), por el equilibrio entre poder investigar incidentes detectados tarde, el costo de almacenamiento y el riesgo de guardar datos personales. El criterio formal se completa en el LAB-03.
