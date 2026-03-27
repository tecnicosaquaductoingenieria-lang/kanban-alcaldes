// =====================================================
// CONFIGURACIÓN SUPABASE - AQUADUCTO
// =====================================================

const SUPABASE_URL = 'https://wpvtzjhzgzwsjdnpynbf.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_NjoVcQRnSkyjiRE9FrPQNA_86FYGUIo';

// Cliente Supabase (se carga desde CDN)
let supabase = null;

// Inicializar Supabase
async function initSupabase() {
    if (typeof window.supabase !== 'undefined') {
        supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        console.log('✅ Conectado a Supabase');
        return true;
    }
    console.log('⚠️ Supabase no cargado - modo demo');
    return false;
}

// Helper para consultas
async function queryTabla(tabla, filtros = {}) {
    if (!supabase) return null;
    
    let q = supabase.from(tabla).select('*');
    
    if (filtros.where) {
        Object.entries(filtros.where).forEach(([key, value]) => {
            q = q.eq(key, value);
        });
    }
    
    if (filtros.order) {
        q = q.order(filtros.order.column, { ascending: filtros.order.ascending });
    }
    
    const { data, error } = await q;
    if (error) {
        console.error('Error:', error);
        return null;
    }
    return data;
}

// CRUD genérico
async function crearRegistro(tabla, data) {
    if (!supabase) return null;
    const { data: result, error } = await supabase.from(tabla).insert(data).select().single();
    if (error) { console.error(error); return null; }
    return result;
}

async function actualizarRegistro(tabla, id, data) {
    if (!supabase) return null;
    const { data: result, error } = await supabase.from(tabla).update(data).eq('id', id).select().single();
    if (error) { console.error(error); return null; }
    return result;
}

async function eliminarRegistro(tabla, id) {
    if (!supabase) return null;
    const { error } = await supabase.from(tabla).delete().eq('id', id);
    return !error;
}

// Exportar para uso global
window.supabase = null;
window.initSupabase = initSupabase;
window.queryTabla = queryTabla;
window.crearRegistro = crearRegistro;
window.actualizarRegistro = actualizarRegistro;
window.eliminarRegistro = eliminarRegistro;
