-- CONSULTA 1: Rendimiento de publicaciones por categoría (vistas JSONB + reacciones)
-- Insight: Medir qué categorías generan más interacciones y visualizaciones.
-- Técnicas: LEFT JOIN (post + interaccion + comentario), extracción JSONB (->>), COUNT, SUM, GROUP BY.
-- ----------------------------------------------------------------------------
SELECT
    p.categoria,
    COUNT(DISTINCT p.id_post)             AS total_posts,
    COUNT(DISTINCT i.id_interaccion)      AS total_interacciones,
    COUNT(DISTINCT c.id_comentario)       AS total_comentarios,
    SUM((p.metadatos_multimedia->>'vistas')::INT) AS vistas_acumuladas
FROM post p
LEFT JOIN interaccion i ON p.id_post = i.id_post
LEFT JOIN comentario  c ON p.id_post = c.id_post
GROUP BY p.categoria
ORDER BY total_interacciones DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 2: Búsqueda optimizada con índice GIN por etiqueta (hashtag) en POST
-- Insight: Recuperar publicaciones sobre "IoT" aprovechando el operador @>.
-- Técnicas: Operador @> (idx_post_multimedia_gin), INNER JOIN con usuario.
-- ----------------------------------------------------------------------------
SELECT
    p.id_post,
    u.nombres || ' ' || u.apellidos AS autor,
    p.categoria,
    p.metadatos_multimedia->>'tipo' AS tipo_contenido,
    (p.metadatos_multimedia->>'vistas')::INT AS vistas
FROM post p
INNER JOIN usuario u ON p.id_usuario = u.id_usuario
WHERE p.metadatos_multimedia @> '{"etiquetas": ["IoT"]}'::JSONB
ORDER BY vistas DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 3: Tendencia de etiquetas más usadas en la red social
-- Insight: Conocer los temas más activos entre los estudiantes.
-- Técnicas: LATERAL jsonb_array_elements_text, COUNT, AVG, GROUP BY.
-- ----------------------------------------------------------------------------
SELECT
    etiqueta,
    COUNT(*) AS menciones,
    ROUND(AVG((p.metadatos_multimedia->>'vistas')::NUMERIC), 1) AS promedio_vistas
FROM post p,
     LATERAL jsonb_array_elements_text(p.metadatos_multimedia->'etiquetas') AS etiqueta
GROUP BY etiqueta
ORDER BY menciones DESC, promedio_vistas DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 4: Ocupación real de aulas por evento (IoT) vs. aforo y asistencias
-- Insight: Comparar el aforo máximo (JSONB) y asistentes registrados vs. sensores IoT.
-- Técnicas: Multi-JOIN (lectura_iot_campus + sensor_iot_campus + evento + grupo),
--           AVG, MAX, COUNT y filtro por rango de fecha (partition pruning).
-- ----------------------------------------------------------------------------
SELECT
    e.titulo AS nombre_evento,
    g.nombre_grupo,
    s.bloque,
    s.aula,
    (e.detalles_logistica->>'aforo_maximo')::INT AS aforo_maximo,
    COUNT(l.id_lectura) AS lecturas_iot,
    ROUND(AVG((l.payload_datos->>'personas_detectadas')::NUMERIC), 1) AS promedio_personas,
    MAX((l.payload_datos->>'porcentaje_ocupacion')::NUMERIC) AS pico_ocupacion_pct
FROM lectura_iot_campus l
INNER JOIN sensor_iot_campus s ON l.id_sensor = s.id_sensor
INNER JOIN evento e            ON l.id_evento = e.id_evento
INNER JOIN grupo g             ON e.id_grupo  = g.id_grupo
WHERE s.tipo_sensor = 'OCUPACION_AULA'
  AND l.fecha_hora >= '2026-11-01 00:00:00-05'
  AND l.fecha_hora <  '2026-12-01 00:00:00-05'
GROUP BY e.titulo, g.nombre_grupo, s.bloque, s.aula, e.detalles_logistica->>'aforo_maximo'
ORDER BY pico_ocupacion_pct DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 5: Alertas IoT de aforo o ventilación en tiempo real
-- Insight: Detectar aulas con sobrecupo o necesidad de ventilación.
-- Técnicas: Operador @> sobre payload_datos JSONB (índice GIN), LEFT JOIN con evento.
-- ----------------------------------------------------------------------------
SELECT
    l.fecha_hora,
    s.codigo_dispositivo,
    s.tipo_sensor,
    s.bloque,
    s.aula,
    COALESCE(e.titulo, 'Uso regular de aula') AS actividad_asociada,
    l.payload_datos
FROM lectura_iot_campus l
INNER JOIN sensor_iot_campus s ON l.id_sensor = s.id_sensor
LEFT JOIN evento e             ON l.id_evento = e.id_evento
WHERE l.payload_datos @> '{"alerta_aforo": true}'::JSONB
   OR l.payload_datos @> '{"alerta_ventilacion": true}'::JSONB
ORDER BY l.fecha_hora DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 6: Resumen de asistencia automatizada RFID vs. tabla ASISTENCIA
-- Insight: Medir carnets válidos, rechazos y latencia de lectura en eventos.
-- Técnicas: Multi-JOIN (lectura_iot_campus + sensor_iot_campus + evento), MAX, SUM, AVG.
-- ----------------------------------------------------------------------------
SELECT
    e.titulo AS nombre_evento,
    s.bloque,
    s.aula,
    MAX((l.payload_datos->>'asistencias_registradas')::INT) AS max_lecturas_rfid,
    MAX((l.payload_datos->>'carnets_validos')::INT)         AS carnets_validos,
    SUM((l.payload_datos->>'carnets_rechazados')::INT)      AS total_rechazos,
    ROUND(AVG((l.payload_datos->>'tiempo_promedio_ms')::NUMERIC), 1) AS latencia_promedio_ms
FROM lectura_iot_campus l
INNER JOIN sensor_iot_campus s ON l.id_sensor = s.id_sensor
INNER JOIN evento e            ON l.id_evento = e.id_evento
WHERE s.tipo_sensor = 'ASISTENCIA_RFID'
GROUP BY e.titulo, s.bloque, s.aula;

-- ----------------------------------------------------------------------------
-- CONSULTA 7: Segmentación estudiantil por programa, modalidad (JSONB) y habilidades
-- Insight: Identificar distribución de estudiantes y total de habilidades registradas.
-- Técnicas: JOIN (perfil_acad + usuario + usuario_habilidad), extracción JSONB, COUNT, AVG.
-- ----------------------------------------------------------------------------
SELECT
    pa.programa,
    pa.perfil_extendido->>'modalidad' AS modalidad,
    COUNT(DISTINCT pa.id_usuario)     AS total_estudiantes,
    ROUND(AVG(pa.semestre), 1)        AS semestre_promedio,
    COUNT(uh.id_habilidad)            AS total_habilidades_registradas
FROM perfil_acad pa
INNER JOIN usuario u           ON pa.id_usuario = u.id_usuario
LEFT JOIN usuario_habilidad uh ON u.id_usuario  = uh.id_usuario
GROUP BY pa.programa, pa.perfil_extendido->>'modalidad'
ORDER BY total_estudiantes DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 8: Actividad y duración de sesión por dispositivo (logs Big Data)
-- Insight: Priorizar mejoras en App móvil frente a plataforma Web.
-- Técnicas: INNER JOIN (log_actividad_usuario + usuario), extracción JSONB, COUNT, SUM, AVG, HAVING.
-- ----------------------------------------------------------------------------
SELECT
    l.detalles_sesion->>'dispositivo' AS dispositivo,
    l.detalles_sesion->>'origen'      AS canal_origen,
    COUNT(l.id_log)                   AS total_eventos,
    COUNT(DISTINCT l.id_usuario)      AS usuarios_activos,
    SUM((l.detalles_sesion->>'duracion_seg')::INT) AS duracion_total_seg,
    ROUND(AVG((l.detalles_sesion->>'duracion_seg')::NUMERIC), 1) AS duracion_promedio_seg
FROM log_actividad_usuario l
INNER JOIN usuario u ON l.id_usuario = u.id_usuario
GROUP BY l.detalles_sesion->>'dispositivo', l.detalles_sesion->>'origen'
HAVING COUNT(l.id_log) >= 1
ORDER BY total_eventos DESC;
