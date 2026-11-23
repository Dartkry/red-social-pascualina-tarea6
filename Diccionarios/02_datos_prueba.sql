-- 1. Usuarios
INSERT INTO usuario (nombres, apellidos, correo_inst, password) VALUES
('Daniel',     'Grisales Lopera', 'daniel.grisales@pascualbravo.edu.co',  'hash_demo_01'),
('Laura Sofía','Martínez Ruiz',   'laura.martinez@pascualbravo.edu.co',   'hash_demo_02'),
('Mateo',      'Restrepo Vélez',  'mateo.restrepo@pascualbravo.edu.co',   'hash_demo_03'),
('Camila',     'Zapata Gómez',    'camila.zapata@pascualbravo.edu.co',    'hash_demo_04'),
('Sebastián',  'Muñoz Ríos',      'sebastian.munoz@pascualbravo.edu.co',  'hash_demo_05');

-- 2. Perfil académico con perfil_extendido en JSONB
INSERT INTO perfil_acad (id_usuario, programa, semestre, biografia, perfil_extendido) VALUES
(1, 'Tecnología en Desarrollo de Software', 3, 'Apasionado por bases de datos, Docker y desarrollo backend.',
 '{"modalidad": "Virtual", "intereses": ["Bases de Datos", "IoT", "Videojuegos"], "notificaciones": {"correo": true, "push": true}}'::JSONB),
(2, 'Ingeniería de Software', 5, 'Enfocada en analítica de datos y arquitectura de sistemas.',
 '{"modalidad": "Presencial", "intereses": ["Big Data", "Analítica", "IA"], "notificaciones": {"correo": true, "push": false}}'::JSONB),
(3, 'Tecnología en Desarrollo de Software', 4, 'Desarrollador web full-stack con interés en APIs.',
 '{"modalidad": "Virtual", "intereses": ["Desarrollo Web", "IoT"], "notificaciones": {"correo": false, "push": true}}'::JSONB),
(4, 'Ingeniería Mecánica', 6, 'Integrante de semillero de robótica y campus inteligente.',
 '{"modalidad": "Presencial", "intereses": ["Robótica", "IoT", "Campus Inteligente"], "notificaciones": {"correo": true, "push": true}}'::JSONB),
(5, 'Tecnología en Gestión del Diseño Gráfico', 2, 'Diseño de interfaces y experiencia de usuario.',
 '{"modalidad": "Presencial", "intereses": ["UX", "Diseño Digital", "Fotografía"], "notificaciones": {"correo": true, "push": true}}'::JSONB);

-- 3. Habilidades y relación usuario_habilidad
INSERT INTO habilidad (nombre_hab) VALUES
('PostgreSQL'), ('Docker'), ('Python'), ('JavaScript'), ('Sensores IoT'), ('Figma');

INSERT INTO usuario_habilidad (id_usuario, id_habilidad, nivel_dominio) VALUES
(1, 1, 'Intermedio'), (1, 2, 'Intermedio'),
(2, 1, 'Avanzado'),   (2, 3, 'Avanzado'),
(3, 4, 'Avanzado'),   (3, 1, 'Intermedio'),
(4, 5, 'Avanzado'),   (5, 6, 'Intermedio');

-- 4. Seguidores
INSERT INTO seguidor (id_seguidor, id_seguido) VALUES
(1, 2), (1, 4), (2, 1), (3, 1), (4, 1), (5, 4);

-- 5. Publicaciones (POST) con metadatos_multimedia JSONB
INSERT INTO post (id_usuario, contenido, categoria, fecha_post, metadatos_multimedia) VALUES
(1, 'Comparto guía práctica sobre cómo acelerar consultas JSONB usando índices GIN en PostgreSQL.',
 'Académico', '2026-11-10 09:30:00-05',
 '{"tipo": "articulo", "etiquetas": ["PostgreSQL", "JSONB", "BigData"], "adjuntos": [{"formato": "pdf", "tamano_mb": 2.4}], "vistas": 185}'::JSONB),
(2, 'Comparamos tiempos de respuesta entre tablas relacionales puras y modelos híbridos con Big Data.',
 'Investigación', '2026-11-12 14:15:00-05',
 '{"tipo": "infografia", "etiquetas": ["BigData", "Analítica", "SQL"], "adjuntos": [{"formato": "png", "tamano_mb": 1.8}], "vistas": 240}'::JSONB),
(4, 'Instalamos sensores de ocupación y temperatura en el Bloque 5 para monitorear laboratorios.',
 'Tecnología', '2026-11-15 11:00:00-05',
 '{"tipo": "video", "etiquetas": ["IoT", "CampusInteligente", "Sensores"], "adjuntos": [{"formato": "mp4", "tamano_mb": 34.5, "duracion_seg": 145}], "vistas": 320}'::JSONB),
(3, 'Ejemplo de API REST consumiendo directamente objetos JSONB desde PostgreSQL hacia React.',
 'Tecnología', '2026-11-18 16:40:00-05',
 '{"tipo": "codigo", "etiquetas": ["JSONB", "API", "React"], "adjuntos": [{"formato": "zip", "tamano_mb": 0.9}], "vistas": 142}'::JSONB),
(5, 'Prototipo de pantalla para consultar en tiempo real los salones con cupo disponible.',
 'Diseño', '2026-11-19 18:20:00-05',
 '{"tipo": "galeria", "etiquetas": ["UX", "IoT", "CampusInteligente"], "adjuntos": [{"formato": "png", "tamano_mb": 3.1}, {"formato": "png", "tamano_mb": 2.7}], "vistas": 275}'::JSONB);

-- 6. Comentarios e Interacciones
INSERT INTO comentario (id_post, id_usuario, texto) VALUES
(1, 2, 'Excelente explicación de jsonb_path_ops.'),
(1, 3, 'Me sirvió mucho para el taller de la semana.'),
(3, 1, '¿Los sensores envían las lecturas por MQTT?'),
(3, 5, 'Podemos conectar estos datos al prototipo del tablero.');

INSERT INTO interaccion (id_post, id_usuario, tipo_reaccion) VALUES
(1, 2, 'Me gusta'), (1, 3, 'Interesante'), (1, 4, 'Compartido'),
(2, 1, 'Me gusta'), (2, 3, 'Me gusta'),
(3, 1, 'Apoyo'),    (3, 2, 'Me gusta'),    (3, 5, 'Compartido'),
(4, 1, 'Me gusta'), (5, 4, 'Me gusta'),    (5, 2, 'Interesante');

-- 7. Grupos y membresías
INSERT INTO grupo (id_creador, nombre_grupo, tematica) VALUES
(1, 'Semillero de Bases de Datos y Analítica', 'Bases de Datos'),
(4, 'Club de IoT y Campus Inteligente',        'IoT'),
(3, 'Comunidad de Desarrollo Web Pascualina',  'Desarrollo Web');

INSERT INTO usuario_grupo (id_usuario, id_grupo, rol_usuario) VALUES
(1, 1, 'Administrador'), (2, 1, 'Miembro'), (3, 1, 'Miembro'),
(4, 2, 'Administrador'), (1, 2, 'Miembro'), (5, 2, 'Miembro'),
(3, 3, 'Administrador'), (1, 3, 'Miembro');

-- 8. Eventos con detalles_logistica en JSONB y asistencias
INSERT INTO evento (id_grupo, titulo, fecha_evento, ubicacion, detalles_logistica) VALUES
(1, 'Taller de Arquitecturas Híbridas en PostgreSQL', '2026-11-14 08:00:00-05', 'Bloque 5 - Lab 502',
 '{"modalidad": "Híbrida", "bloque": "Bloque 5", "aula": "Lab 502", "aforo_maximo": 35, "recursos": ["Proyector", "Docker", "WiFi"]}'::JSONB),
(2, 'Jornada de Demostración IoT en el Campus', '2026-11-16 14:00:00-05', 'Bloque 3 - Auditorio 301',
 '{"modalidad": "Presencial", "bloque": "Bloque 3", "aula": "Auditorio 301", "aforo_maximo": 80, "recursos": ["Sonido", "Sensores RFID", "Streaming"]}'::JSONB),
(3, 'Hackatón Estudiantil de Datos Abiertos', '2026-11-20 09:00:00-05', 'Bloque 5 - Lab 504',
 '{"modalidad": "Presencial", "bloque": "Bloque 5", "aula": "Lab 504", "aforo_maximo": 40, "recursos": ["Computadores", "Servidor Local"]}'::JSONB);

INSERT INTO asistencia (id_usuario, id_evento, estado_asistencia) VALUES
(1, 1, 'Asistió'), (2, 1, 'Asistió'), (3, 1, 'Confirmado'),
(4, 2, 'Asistió'), (1, 2, 'Asistió'), (5, 2, 'Asistió'),
(3, 3, 'Asistió'), (2, 3, 'Confirmado');

-- 9. Sensores IoT del campus
INSERT INTO sensor_iot_campus (codigo_dispositivo, tipo_sensor, bloque, aula, estado, especificaciones) VALUES
('IOT-B5-502-OCU',  'OCUPACION_AULA',  'Bloque 5', 'Lab 502',       'ACTIVO',
 '{"fabricante": "SenseCampus", "protocolo": "MQTT", "intervalo_seg": 60, "firmware": "v2.4"}'::JSONB),
('IOT-B3-301-RFID', 'ASISTENCIA_RFID', 'Bloque 3', 'Auditorio 301', 'ACTIVO',
 '{"fabricante": "EduPass", "protocolo": "HTTP", "frecuencia_mhz": 13.56, "firmware": "v1.9"}'::JSONB),
('IOT-B5-504-OCU',  'OCUPACION_AULA',  'Bloque 5', 'Lab 504',       'ACTIVO',
 '{"fabricante": "SenseCampus", "protocolo": "MQTT", "intervalo_seg": 60, "firmware": "v2.4"}'::JSONB),
('IOT-B5-502-CLM',  'CLIMA_AULA',      'Bloque 5', 'Lab 502',       'ACTIVO',
 '{"fabricante": "EnviroLab", "protocolo": "MQTT", "intervalo_seg": 300, "firmware": "v3.1"}'::JSONB);

-- 10. Lecturas IoT (particiones de octubre y noviembre de 2026)
INSERT INTO lectura_iot_campus (id_sensor, id_evento, fecha_hora, payload_datos) VALUES
(1, NULL, '2026-10-25 10:00:00-05',
 '{"personas_detectadas": 18, "capacidad_aula": 35, "porcentaje_ocupacion": 51.4, "alerta_aforo": false}'::JSONB),
(1, 1, '2026-11-14 08:30:00-05',
 '{"personas_detectadas": 32, "capacidad_aula": 35, "porcentaje_ocupacion": 91.4, "alerta_aforo": true}'::JSONB),
(1, 1, '2026-11-14 09:30:00-05',
 '{"personas_detectadas": 34, "capacidad_aula": 35, "porcentaje_ocupacion": 97.1, "alerta_aforo": true}'::JSONB),
(4, 1, '2026-11-14 09:30:00-05',
 '{"temperatura_c": 26.8, "humedad_pct": 64, "co2_ppm": 980, "alerta_ventilacion": true}'::JSONB),
(2, 2, '2026-11-16 14:05:00-05',
 '{"asistencias_registradas": 68, "carnets_validos": 66, "carnets_rechazados": 2, "tiempo_promedio_ms": 210}'::JSONB),
(2, 2, '2026-11-16 15:00:00-05',
 '{"asistencias_registradas": 74, "carnets_validos": 72, "carnets_rechazados": 2, "tiempo_promedio_ms": 195}'::JSONB),
(3, 3, '2026-11-20 10:00:00-05',
 '{"personas_detectadas": 36, "capacidad_aula": 40, "porcentaje_ocupacion": 90.0, "alerta_aforo": true}'::JSONB),
(3, 3, '2026-11-20 14:00:00-05',
 '{"personas_detectadas": 29, "capacidad_aula": 40, "porcentaje_ocupacion": 72.5, "alerta_aforo": false}'::JSONB);

-- 11. Logs de actividad de usuarios
INSERT INTO log_actividad_usuario (id_usuario, tipo_evento, fecha_hora, detalles_sesion) VALUES
(1, 'LOGIN',          '2026-11-14 07:55:00-05', '{"dispositivo": "Desktop", "so": "Windows 11", "duracion_seg": 1800, "origen": "Web"}'::JSONB),
(1, 'POST',           '2026-11-10 09:30:00-05', '{"dispositivo": "Desktop", "so": "Windows 11", "duracion_seg": 420,  "origen": "Web"}'::JSONB),
(2, 'ASISTENCIA_IOT', '2026-11-14 08:05:00-05', '{"dispositivo": "Carnet RFID", "bloque": "Bloque 5", "duracion_seg": 2, "origen": "Campus"}'::JSONB),
(2, 'INTERACCION',    '2026-11-15 11:20:00-05', '{"dispositivo": "Mobile", "so": "Android", "duracion_seg": 95,  "origen": "App"}'::JSONB),
(3, 'BUSQUEDA',       '2026-11-18 16:10:00-05', '{"dispositivo": "Laptop", "so": "Ubuntu", "termino": "JSONB", "duracion_seg": 240, "origen": "Web"}'::JSONB),
(4, 'ASISTENCIA_IOT', '2026-11-16 14:02:00-05', '{"dispositivo": "Carnet RFID", "bloque": "Bloque 3", "duracion_seg": 2, "origen": "Campus"}'::JSONB),
(4, 'POST',           '2026-11-15 11:00:00-05', '{"dispositivo": "Mobile", "so": "iOS", "duracion_seg": 610, "origen": "App"}'::JSONB),
(5, 'LOGIN',          '2026-11-19 18:00:00-05', '{"dispositivo": "Mobile", "so": "Android", "duracion_seg": 920, "origen": "App"}'::JSONB);
