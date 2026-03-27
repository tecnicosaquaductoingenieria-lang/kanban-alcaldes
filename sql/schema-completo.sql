-- =============================================
-- AQUADUCTO - SISTEMA DE GESTIÓN
-- Schema completo para Supabase
-- =============================================

-- Tabla de CONTACTOS
CREATE TABLE IF NOT EXISTS contactos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    empresa TEXT DEFAULT '',
    cargo TEXT DEFAULT '',
    email TEXT DEFAULT '',
    telefono TEXT DEFAULT '',
    notas TEXT DEFAULT '',
    estado TEXT DEFAULT 'activo' CHECK (estado IN ('activo', 'inactivo')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de COLUMNAS del Kanban
CREATE TABLE IF NOT EXISTS columnas (
    id TEXT PRIMARY KEY,
    nombre TEXT NOT NULL,
    color TEXT DEFAULT '#007cc3',
    posicion INTEGER DEFAULT 0
);

-- Insertar columnas por defecto
INSERT INTO columnas (id, nombre, color, posicion) VALUES
    ('nuevo', 'Nuevo', '#007cc3', 1),
    ('progreso', 'En Progreso', '#f59e0b', 2),
    ('pendiente', 'Pendiente Info', '#8b5cf6', 3),
    ('completado', 'Completado', '#00d084', 4)
ON CONFLICT (id) DO NOTHING;

-- Tabla de TAREAS
CREATE TABLE IF NOT EXISTS tareas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo TEXT NOT NULL,
    descripcion TEXT DEFAULT '',
    columna_id TEXT DEFAULT 'nuevo' REFERENCES columnas(id),
    prioridad TEXT DEFAULT 'media' CHECK (prioridad IN ('alta', 'media', 'baja')),
    contacto_id UUID REFERENCES contactos(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de CHECKLIST (sub-tareas dentro de una tarea)
CREATE TABLE IF NOT EXISTS checklist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tarea_id UUID REFERENCES tareas(id) ON DELETE CASCADE,
    texto TEXT NOT NULL,
    completado BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- DATOS DE EJEMPLO
-- =============================================

-- Contactos de ejemplo
INSERT INTO contactos (nombre, empresa, cargo, email, telefono, notas) VALUES
    ('María López', 'Ayuntamiento de Sevilla', 'Concejala de Urbanismo', 'maria.lopez@ayto-sevilla.es', '+34 954 000 000', 'Proyecto de renovación urbana en centro histórico'),
    ('Carlos Martínez', 'Diputación de Málaga', 'Director de Infraestructura', 'carlos.martinez@dipmalaga.es', '+34 952 000 000', 'Proyecto de carreteras - pendiente propuesta técnica')
ON CONFLICT DO NOTHING;

-- Una tarea de ejemplo
INSERT INTO tareas (titulo, descripcion, columna_id, prioridad, contacto_id) 
SELECT 'Revisar presupuesto proyecto Sevilla', 'Necesitamos enviar el presupuesto detallado para aprobar el proyecto', 'pendiente', 'alta', id 
FROM contactos WHERE email = 'maria.lopez@ayto-sevilla.es'
LIMIT 1;

-- Checklist de ejemplo para la tarea
INSERT INTO checklist (tarea_id, texto, completado)
SELECT t.id, 'Presupuesto detallado', false
FROM tareas t WHERE t.titulo LIKE '%Sevilla%'
LIMIT 1;

-- =============================================
-- SEGURIDAD (RLS - Row Level Security)
-- =============================================

ALTER TABLE contactos ENABLE ROW LEVEL SECURITY;
ALTER TABLE columnas ENABLE ROW LEVEL SECURITY;
ALTER TABLE tareas ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklist ENABLE ROW LEVEL SECURITY;

-- Permisos públicos para desarrollo
CREATE POLICY "Permiso total contactos" ON contactos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permiso total columnas" ON columnas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permiso total tareas" ON tareas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Permiso total checklist" ON checklist FOR ALL USING (true) WITH CHECK (true);
