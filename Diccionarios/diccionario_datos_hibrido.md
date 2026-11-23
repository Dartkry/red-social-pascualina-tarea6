## 1. Inventario completo de tablas y campos (12 tablas del diagrama + 3 tablas IoT / Big Data)

| Tabla | Tipo | Campos estructurados clave | Campo semiestructurado (`JSONB`) | Optimización aplicada |
| :--- | :--- | :--- | :--- | :--- |
| `usuario` | Relacional | `id_usuario` (PK), `nombres`, `apellidos`, `correo_inst`, `password`, `fecha_registro` | No aplica | `UNIQUE` en `correo_inst` |
| `perfil_acad` | Híbrida | `id_perfil` (PK), `id_usuario` (FK), `programa`, `semestre`, `biografia` | `perfil_extendido` (modalidad, intereses, notificaciones) | Índice `GIN` + `CHECK` semestre |
| `habilidad` | Relacional | `id_habilidad` (PK), `nombre_hab` | No aplica | `UNIQUE` en `nombre_hab` |
| `usuario_habilidad` | Relacional | `id_usuario` (PK, FK), `id_habilidad` (PK, FK), `nivel_dominio` | No aplica | Clave primaria compuesta + `CHECK` |
| `seguidor` | Relacional | `id_seguidor` (PK, FK), `id_seguido` (PK, FK), `fecha_inicio` | No aplica | `CHECK (id_seguidor <> id_seguido)` |
| `post` | Híbrida | `id_post` (PK), `id_usuario` (FK), `contenido`, `categoria`, `fecha_post` | `metadatos_multimedia` (tipo, etiquetas, adjuntos, vistas) | `GIN` (`jsonb_path_ops`) + B-Tree fecha |
| `comentario` | Relacional | `id_comentario` (PK), `id_post` (FK), `id_usuario` (FK), `texto`, `fecha_coment` | No aplica | Integridad referencial en cascada |
| `interaccion` | Relacional | `id_interaccion` (PK), `id_post` (FK), `id_usuario` (FK), `tipo_reaccion` | No aplica | B-Tree `(id_post, tipo_reaccion)` |
| `grupo` | Relacional | `id_grupo` (PK), `id_creador` (FK), `nombre_grupo`, `tematica` | No aplica | `UNIQUE` en `nombre_grupo` |
| `usuario_grupo` | Relacional | `id_usuario` (PK, FK), `id_grupo` (PK, FK), `rol_usuario` | No aplica | Clave compuesta + `CHECK` rol |
| `evento` | Híbrida | `id_evento` (PK), `id_grupo` (FK), `titulo`, `fecha_evento`, `ubicacion` | `detalles_logistica` (modalidad, bloque, aula, aforo, recursos) | Índice `GIN` en `detalles_logistica` |
| `asistencia` | Relacional | `id_usuario` (PK, FK), `id_evento` (PK, FK), `estado_asistencia` | No aplica | Clave compuesta + `CHECK` estado |
| `sensor_iot_campus` | Híbrida IoT | `id_sensor` (PK), `codigo_dispositivo`, `tipo_sensor`, `bloque`, `aula`, `estado` | `especificaciones` (fabricante, protocolo, intervalo, firmware) | `CHECK` en tipo y estado |
| `lectura_iot_campus` | IoT / Big Data | `id_lectura` (`BIGSERIAL`), `id_sensor` (FK), `id_evento` (FK), `fecha_hora` | `payload_datos` (ocupación, clima, asistencias RFID, alertas) | Partición `RANGE` mensual + `GIN` + B-Tree |
| `log_actividad_usuario` | Big Data / Logs | `id_log` (PK), `id_usuario` (FK), `tipo_evento`, `fecha_hora` | `detalles_sesion` (dispositivo, SO, duración, origen) | `GIN` + B-Tree `(id_usuario, fecha_hora DESC)` |

## 2. Inventario completo de consultas SQL (DML)

| # | Consulta y tablas | Operadores JSONB y SQL | Insight de negocio |
| :--- | :--- | :--- | :--- |
| 1 | Rendimiento por categoría (`post`, `interaccion`, `comentario`) | `->>`, `LEFT JOIN`, `COUNT`, `SUM`, `GROUP BY` | Medir qué categorías generan más reacciones y vistas |
| 2 | Búsqueda por etiqueta IoT (`post`, `usuario`) | `@>` (índice GIN), `->>`, `INNER JOIN` | Filtrar publicaciones por hashtag sin escaneo secuencial |
| 3 | Tendencia de etiquetas (`post`) | `LATERAL jsonb_array_elements_text`, `COUNT`, `AVG` | Identificar los temas más activos y su alcance promedio |
| 4 | Ocupación real en eventos (`lectura_iot_campus`, `sensor_iot_campus`, `evento`, `grupo`) | `->>`, multi-JOIN, `COUNT`, `AVG`, `MAX`, rango fecha | Comparar aforo máximo vs. ocupación medida por sensores |
| 5 | Alertas IoT de aforo y ventilación (`lectura_iot_campus`, `sensor_iot_campus`, `evento`) | `@>` (índice GIN), `INNER/LEFT JOIN`, `COALESCE` | Detectar salones con sobrecupo o necesidad de ventilación |
| 6 | Asistencia RFID en eventos (`lectura_iot_campus`, `sensor_iot_campus`, `evento`) | `->>`, multi-JOIN, `MAX`, `SUM`, `AVG`, `GROUP BY` | Controlar carnets válidos, rechazos y latencia de lectura |
| 7 | Segmentación estudiantil (`perfil_acad`, `usuario`, `usuario_habilidad`) | `->>`, `INNER/LEFT JOIN`, `COUNT`, `AVG`, `GROUP BY` | Conocer distribución por programa, modalidad y habilidades |
| 8 | Uso por dispositivo (`log_actividad_usuario`, `usuario`) | `->>`, `INNER JOIN`, `COUNT`, `SUM`, `AVG`, `HAVING` | Priorizar mejoras técnicas en App móvil frente a Web |
