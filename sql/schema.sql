-- =====================================================
-- KANBAN + ALCALDES - Supabase Schema
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- ALCALDES (Contactos/Personas de empresas)
-- =====================================================
CREATE TABLE IF NOT EXISTS alcaldes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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

-- =====================================================
-- COLUMNAS (Estados del Kanban)
-- =====================================================
CREATE TABLE IF NOT EXISTS columnas (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    color TEXT DEFAULT '#3498db',
    position INTEGER DEFAULT 0
);

-- Insertar columnas por defecto
INSERT INTO columnas (id, name, color, position) VALUES
    ('nuevo', 'Nuevo', '#3498db', 1),
    ('en-progreso', 'En Progreso', '#f39c12', 2),
    ('pendiente-info', 'Pendiente Info', '#9b59b6', 3),
    ('completado', 'Completado', '#27ae60', 4),
    ('archivado', 'Archivado', '#7f8c8d', 5)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- TARJETAS
-- =====================================================
CREATE TABLE IF NOT EXISTS tarjetas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    column_id TEXT DEFAULT 'nuevo' REFERENCES columnas(id),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('high', 'medium', 'low')),
    tags TEXT[] DEFAULT '{}',
    alcalde_id UUID REFERENCES alcaldes(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- COMENTARIOS
-- =====================================================
CREATE TABLE IF NOT EXISTS comentarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tarjeta_id UUID REFERENCES tarjetas(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    author TEXT DEFAULT 'Usuario',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- HISTORIAL (movimientos de tarjetas)
-- =====================================================
CREATE TABLE IF NOT EXISTS historial (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tarjeta_id UUID REFERENCES tarjetas(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    detail TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- USUARIOS (simplificado, para auth futura)
-- =====================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id TEXT PRIMARY KEY,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'ceo')),
    name TEXT NOT NULL
);

-- Insertar usuarios demo
INSERT INTO usuarios (id, password, role, name) VALUES
    ('admin', 'admin123', 'admin', 'Administrador'),
    ('ceo', 'ceo123', 'ceo', 'CEO')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- ALCALDES DEMO
-- =====================================================
INSERT INTO alcaldes (nombre, empresa, cargo, email, telefono, notas, estado) VALUES
    ('María López', 'Ayuntamiento de Sevilla', 'Concejala de Urbanismo', 'maria.lopez@ayto-sevilla.es', '+34 954 000 000', 'Proyecto de renovación urbana. Primera toma de contacto.', 'activo'),
    ('Carlos Martínez', 'Diputación de Málaga', 'Director de Infraestructura', 'carlos.martinez@dipmalaga.es', '+34 952 000 000', 'Proyecto de carreteras. Pendiente propuesta técnica.', 'activo')
ON CONFLICT DO NOTHING;

-- =====================================================
-- FUNCIONES ÚTILES
-- =====================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
DROP TRIGGER IF EXISTS update_alcaldes_updated_at ON alcaldes;
CREATE TRIGGER update_alcaldes_updated_at
    BEFORE UPDATE ON alcaldes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_tarjetas_updated_at ON tarjetas;
CREATE TRIGGER update_tarjetas_updated_at
    BEFORE UPDATE ON tarjetas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- POLICIES (Seguridad Row Level Security)
-- =====================================================

-- Habilitar RLS
ALTER TABLE alcaldes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tarjetas ENABLE ROW LEVEL SECURITY;
ALTER TABLE comentarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial ENABLE ROW LEVEL SECURITY;
ALTER TABLE columnas ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- Policies públicas (para desarrollo)
-- En producción, cambiar a políticas más restrictivas con auth
CREATE POLICY "Allow all on alcaldes" ON alcaldes FOR ALL USING (true);
CREATE POLICY "Allow all on tarjetas" ON tarjetas FOR ALL USING (true);
CREATE POLICY "Allow all on comentarios" ON comentarios FOR ALL USING (true);
CREATE POLICY "Allow all on historial" ON historial FOR ALL USING (true);
CREATE POLICY "Allow all on columnas" ON columnas FOR ALL USING (true);
CREATE POLICY "Allow all on usuarios" ON usuarios FOR ALL USING (true);

-- =====================================================
-- VISTAS ÚTILES
-- =====================================================

-- Vista de estadísticas
CREATE OR REPLACE VIEW stats AS
SELECT 
    (SELECT COUNT(*) FROM tarjetas) as total_tarjetas,
    (SELECT COUNT(*) FROM alcaldes WHERE estado = 'activo') as total_alcaldes_activos,
    (SELECT COUNT(*) FROM tarjetas WHERE column_id = 'nuevo') as en_nuevo,
    (SELECT COUNT(*) FROM tarjetas WHERE column_id = 'en-progreso') as en_progreso,
    (SELECT COUNT(*) FROM tarjetas WHERE column_id = 'completado') as completados;
