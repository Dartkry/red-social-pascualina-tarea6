-- Limpieza preventiva para facilitar pruebas repetibles
DROP TABLE IF EXISTS log_actividad_usuario CASCADE;
DROP TABLE IF EXISTS lectura_iot_campus CASCADE;
DROP TABLE IF EXISTS sensor_iot_campus CASCADE;
DROP TABLE IF EXISTS asistencia CASCADE;
DROP TABLE IF EXISTS evento CASCADE;
DROP TABLE IF EXISTS usuario_grupo CASCADE;
DROP TABLE IF EXISTS grupo CASCADE;
DROP TABLE IF EXISTS interaccion CASCADE;
DROP TABLE IF EXISTS comentario CASCADE;
DROP TABLE IF EXISTS post CASCADE;
DROP TABLE IF EXISTS seguidor CASCADE;
DROP TABLE IF EXISTS usuario_habilidad CASCADE;
DROP TABLE IF EXISTS habilidad CASCADE;
DROP TABLE IF EXISTS perfil_acad CASCADE;
DROP TABLE IF EXISTS usuario CASCADE;

-- ============================================================================
-- 1. NÚCLEO RELACIONAL DE LA RED SOCIAL (12 TABLAS DEL DIAGRAMA + JSONB)
-- ============================================================================

-- 1.1 Usuarios registrados
CREATE TABLE usuario (
    id_usuario     SERIAL PRIMARY KEY,
    nombres        VARCHAR(80)  NOT NULL,
    apellidos      VARCHAR(80)  NOT NULL,
    correo_inst    VARCHAR(150) NOT NULL UNIQUE,
    password       VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- 1.2 Perfil académico (HÍBRIDA: columnas fijas + perfil_extendido JSONB)
CREATE TABLE perfil_acad (
    id_perfil        SERIAL PRIMARY KEY,
    id_usuario       INT NOT NULL UNIQUE REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    programa         VARCHAR(120) NOT NULL,
    semestre         SMALLINT NOT NULL CHECK (semestre BETWEEN 1 AND 12),
    biografia        TEXT,
    -- Campo semiestructurado para intereses, modalidad y preferencias cambiantes
    perfil_extendido JSONB NOT NULL DEFAULT '{}'::JSONB
);

-- 1.3 Catálogo de habilidades
CREATE TABLE habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    nombre_hab   VARCHAR(80) NOT NULL UNIQUE
);

-- 1.4 Relación N:M Usuario - Habilidad
CREATE TABLE usuario_habilidad (
    id_usuario    INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_habilidad  INT NOT NULL REFERENCES habilidad(id_habilidad) ON DELETE CASCADE,
    nivel_dominio VARCHAR(30) NOT NULL CHECK (nivel_dominio IN ('Básico', 'Intermedio', 'Avanzado')),
    PRIMARY KEY (id_usuario, id_habilidad)
);

-- 1.5 Red de seguidores
CREATE TABLE seguidor (
    id_seguidor  INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_seguido   INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_seguidor, id_seguido),
    CONSTRAINT chk_no_autoseguimiento CHECK (id_seguidor <> id_seguido)
);

-- 1.6 Publicaciones (HÍBRIDA: datos relacionales + metadatos_multimedia JSONB)
CREATE TABLE post (
    id_post              BIGSERIAL PRIMARY KEY,
    id_usuario           INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    contenido            TEXT NOT NULL,
    categoria            VARCHAR(60) NOT NULL,
    fecha_post           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Metadatos variables: tipo, etiquetas/hashtags, archivos adjuntos y métricas rápidas
    metadatos_multimedia JSONB NOT NULL DEFAULT '{}'::JSONB
);

-- 1.7 Comentarios en publicaciones
CREATE TABLE comentario (
    id_comentario BIGSERIAL PRIMARY KEY,
    id_post       BIGINT NOT NULL REFERENCES post(id_post) ON DELETE CASCADE,
    id_usuario    INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    texto         TEXT NOT NULL,
    fecha_coment  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.8 Interacciones / reacciones en publicaciones
CREATE TABLE interaccion (
    id_interaccion BIGSERIAL PRIMARY KEY,
    id_post        BIGINT NOT NULL REFERENCES post(id_post) ON DELETE CASCADE,
    id_usuario     INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    tipo_reaccion  VARCHAR(30) NOT NULL CHECK (
                       tipo_reaccion IN ('Me gusta', 'Interesante', 'Apoyo', 'Compartido')
                   )
);

-- 1.9 Grupos estudiantiles
CREATE TABLE grupo (
    id_grupo     SERIAL PRIMARY KEY,
    id_creador   INT NOT NULL REFERENCES usuario(id_usuario),
    nombre_grupo VARCHAR(120) NOT NULL UNIQUE,
    tematica     VARCHAR(80)  NOT NULL
);

-- 1.10 Membresía de usuarios en grupos
CREATE TABLE usuario_grupo (
    id_usuario  INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_grupo    INT NOT NULL REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    rol_usuario VARCHAR(30) NOT NULL CHECK (rol_usuario IN ('Administrador', 'Moderador', 'Miembro')),
    PRIMARY KEY (id_usuario, id_grupo)
);

-- 1.11 Eventos universitarios (HÍBRIDA: agenda relacional + detalles_logistica JSONB)
CREATE TABLE evento (
    id_evento          SERIAL PRIMARY KEY,
    id_grupo           INT NOT NULL REFERENCES grupo(id_grupo) ON DELETE CASCADE,
    titulo             VARCHAR(160) NOT NULL,
    fecha_evento       TIMESTAMPTZ  NOT NULL,
    ubicacion          VARCHAR(120) NOT NULL,
    -- Detalles flexibles: modalidad, bloque, aula, aforo máximo y recursos técnicos
    detalles_logistica JSONB NOT NULL DEFAULT '{}'::JSONB
);

-- 1.12 Registro de asistencia a eventos
CREATE TABLE asistencia (
    id_usuario        INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_evento         INT NOT NULL REFERENCES evento(id_evento) ON DELETE CASCADE,
    estado_asistencia VARCHAR(30) NOT NULL CHECK (
                          estado_asistencia IN ('Confirmado', 'Asistió', 'Cancelado')
                      ),
    PRIMARY KEY (id_usuario, id_evento)
);

-- ============================================================================
-- 2. EXTENSIONES OPTIMIZADAS PARA IoT Y BIG DATA (VOLUMEN, VELOCIDAD, VARIEDAD)
-- ============================================================================

-- 2.1 Catálogo de sensores IoT del campus inteligente
CREATE TABLE sensor_iot_campus (
    id_sensor          SERIAL PRIMARY KEY,
    codigo_dispositivo VARCHAR(40) NOT NULL UNIQUE,
    tipo_sensor        VARCHAR(40) NOT NULL CHECK (
                           tipo_sensor IN ('OCUPACION_AULA', 'ASISTENCIA_RFID', 'CLIMA_AULA')
                       ),
    bloque             VARCHAR(30) NOT NULL,
    aula               VARCHAR(30) NOT NULL,
    estado             VARCHAR(20) NOT NULL DEFAULT 'ACTIVO' CHECK (
                           estado IN ('ACTIVO', 'MANTENIMIENTO', 'INACTIVO')
                       ),
    especificaciones   JSONB NOT NULL DEFAULT '{}'::JSONB
);

-- 2.2 Lecturas IoT (Particionada por rango mensual para manejar Big Data)
CREATE TABLE lectura_iot_campus (
    id_lectura    BIGSERIAL,
    id_sensor     INT NOT NULL REFERENCES sensor_iot_campus(id_sensor),
    id_evento     INT REFERENCES evento(id_evento),
    fecha_hora    TIMESTAMPTZ NOT NULL,
    payload_datos JSONB NOT NULL,
    PRIMARY KEY (id_lectura, fecha_hora)
) PARTITION BY RANGE (fecha_hora);

CREATE TABLE lectura_iot_2026_10 PARTITION OF lectura_iot_campus
    FOR VALUES FROM ('2026-10-01 00:00:00-05') TO ('2026-11-01 00:00:00-05');

CREATE TABLE lectura_iot_2026_11 PARTITION OF lectura_iot_campus
    FOR VALUES FROM ('2026-11-01 00:00:00-05') TO ('2026-12-01 00:00:00-05');

CREATE TABLE lectura_iot_2026_12 PARTITION OF lectura_iot_campus
    FOR VALUES FROM ('2026-12-01 00:00:00-05') TO ('2027-01-01 00:00:00-05');

-- 2.3 Logs de actividad de usuarios (alto flujo semiestructurado)
CREATE TABLE log_actividad_usuario (
    id_log          BIGSERIAL PRIMARY KEY,
    id_usuario      INT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    tipo_evento     VARCHAR(40) NOT NULL CHECK (
                        tipo_evento IN ('LOGIN', 'POST', 'INTERACCION', 'ASISTENCIA_IOT', 'BUSQUEDA')
                    ),
    fecha_hora      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    detalles_sesion JSONB NOT NULL DEFAULT '{}'::JSONB
);

-- ============================================================================
-- 3. ÍNDICES DE OPTIMIZACIÓN (GIN PARA JSONB Y B-TREE PARA JOINS Y FECHAS)
-- ============================================================================

-- Índices GIN para búsquedas rápidas dentro de campos JSONB (@>, ?, ?|, ?&)
CREATE INDEX idx_perfil_acad_extendido_gin
    ON perfil_acad USING GIN (perfil_extendido);

CREATE INDEX idx_post_multimedia_gin
    ON post USING GIN (metadatos_multimedia jsonb_path_ops);

CREATE INDEX idx_evento_logistica_gin
    ON evento USING GIN (detalles_logistica);

CREATE INDEX idx_lectura_iot_payload_gin
    ON lectura_iot_campus USING GIN (payload_datos jsonb_path_ops);

CREATE INDEX idx_log_actividad_detalles_gin
    ON log_actividad_usuario USING GIN (detalles_sesion);

-- Índices B-Tree compuestos para cruces (JOIN) y filtros cronológicos de alto volumen
CREATE INDEX idx_post_usuario_fecha
    ON post (id_usuario, fecha_post DESC);

CREATE INDEX idx_interaccion_post
    ON interaccion (id_post, tipo_reaccion);

CREATE INDEX idx_lectura_iot_sensor_fecha
    ON lectura_iot_campus (id_sensor, fecha_hora DESC);

CREATE INDEX idx_lectura_iot_evento
    ON lectura_iot_campus (id_evento)
    WHERE id_evento IS NOT NULL;

CREATE INDEX idx_log_actividad_usuario_fecha
    ON log_actividad_usuario (id_usuario, fecha_hora DESC);
