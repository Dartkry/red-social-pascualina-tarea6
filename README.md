# Tarea 6 — Arquitectura de Base de Datos Híbrida (Red Social Estudiantil Pascualina)

**Institución:** Institución Universitaria Pascual Bravo  
**Programa:** Tecnología en Desarrollo de Software (Modalidad Virtual)  
**Estudiante:** Daniel Grisales Lopera  
**Motor de base de datos:** PostgreSQL 16+  

## Descripción
Diseño e implementación de una arquitectura de base de datos híbrida que integra tablas relacionales tradicionales, campos semiestructurados (`JSONB`), particionamiento por rango temporal para lecturas de sensores IoT del campus y *logs* de actividad (*Big Data*), junto con índices `GIN` y `B-Tree` y consultas SQL analíticas.

## Estructura del repositorio

```text
Tarea6/
├── README.md
├── aporte_foro.txt
├── Diccionarios/
│   ├── 01_ddl_arquitectura_hibrida.sql
│   ├── 02_datos_prueba.sql
│   ├── 03_dml_consultas_semiestructuradas.sql
│   └── diccionario_datos_hibrido.md
├── Informe/
│   ├── Informe_Tecnico_Tarea6_Daniel_Grisales.docx
│   └── Informe_Tecnico_Tarea6_Daniel_Grisales.pdf
└── Video/
    ├── guion_video_sustentacion.md
    └── enlace_video.txt
```

## Cómo ejecutar los scripts localmente con Docker + PostgreSQL

Si deseas probar los scripts rápidamente desde PowerShell o WSL2 con Docker Desktop:

```bash
# 1. Levantar un contenedor temporal de PostgreSQL 16
docker run --name pg-tarea6 -e POSTGRES_PASSWORD=pascualina -e POSTGRES_DB=red_social_hibrida -p 5432:5432 -d postgres:16

# 2. Ejecutar los scripts en orden (DDL -> Datos -> Consultas DML)
docker exec -i pg-tarea6 psql -U postgres -d red_social_hibrida < Diccionarios/01_ddl_arquitectura_hibrida.sql
docker exec -i pg-tarea6 psql -U postgres -d red_social_hibrida < Diccionarios/02_datos_prueba.sql
docker exec -i pg-tarea6 psql -U postgres -d red_social_hibrida < Diccionarios/03_dml_consultas_semiestructuradas.sql
```
