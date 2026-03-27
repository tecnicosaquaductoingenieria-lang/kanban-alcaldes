// =====================================================
// CONFIGURACIÓN SUPABASE
// =====================================================
// IMPORTANTE: Reemplaza estos valores con los tuyos de Supabase
// Dashboard → Settings → API

const SUPABASE_URL = 'https://wpvtzjhzgzwsjdnpynbf.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';

// Clients
let supabase = null;

// Inicializar cliente Supabase
function initSupabase() {
    if (typeof window.supabase !== 'undefined') {
        supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        console.log('✅ Supabase conectado');
        return true;
    }
    console.log('❌ Cliente Supabase no cargado');
    return false;
}

// Verificar conexión
async function checkConnection() {
    if (!supabase) return false;
    try {
        const { data, error } = await supabase.from('columnas').select('count');
        return !error;
    } catch (e) {
        return false;
    }
}

// =====================================================
// API WRAPPERS (usa Supabase o fallback localStorage)
// =====================================================

let useLocal = true; // Fallback si Supabase no está configurado

async function API(endpoint, options = {}) {
    // Si Supabase está configurado, usar Supabase
    if (supabase && SUPABASE_ANON_KEY !== 'YOUR_ANON_KEY_HERE') {
        return API_supabase(endpoint, options);
    }
    // Fallback a localStorage
    return API_local(endpoint, options);
}

async function API_supabase(endpoint, options = {}) {
    const { method = 'GET', body = null, table = '' } = options;
    
    let query = supabase.from(table).select('*');
    
    switch (method) {
        case 'GET':
            if (endpoint.includes('/')) {
                const [t, id] = endpoint.split('/');
                if (id) {
                    query = query.eq('id', id);
                    const { data, error } = await query.single();
                    return error ? { error: error.message } : { data };
                }
            }
            const { data, error } = await query;
            return error ? { error: error.message } : { data };
            
        case 'POST':
            const { data: newData, error: postError } = await supabase
                .from(table)
                .insert(body)
                .select()
                .single();
            return postError ? { error: postError.message } : { data: newData };
            
        case 'PUT':
            const { data: updData, error: updError } = await supabase
                .from(table)
                .update(body)
                .eq('id', endpoint.split('/')[1])
                .select()
                .single();
            return updError ? { error: updError.message } : { data: updData };
            
        case 'DELETE':
            const { error: delError } = await supabase
                .from(table)
                .delete()
                .eq('id', endpoint.split('/')[1]);
            return delError ? { error: delError.message } : { success: true };
    }
}

// =====================================================
// FALLBACK: localStorage para desarrollo sin Supabase
// =====================================================

function API_local(endpoint, options = {}) {
    const { method = 'GET', body = null } = options;
    
    return new Promise((resolve) => {
        setTimeout(() => {
            if (!localStorage.getItem('kanban_data')) {
                localStorage.setItem('kanban_data', JSON.stringify({
                    columnas: [
                        { id: 'nuevo', name: 'Nuevo', color: '#3498db' },
                        { id: 'en-progreso', name: 'En Progreso', color: '#f39c12' },
                        { id: 'pendiente-info', name: 'Pendiente Info', color: '#9b59b6' },
                        { id: 'completado', name: 'Completado', color: '#27ae60' },
                        { id: 'archivado', name: 'Archivado', color: '#7f8c8d' }
                    ],
                    tarjetas: [],
                    alcalde: [],
                    usuarios: [
                        { id: 'admin', password: 'admin123', role: 'admin', name: 'Administrador' },
                        { id: 'ceo', password: 'ceo123', role: 'ceo', name: 'CEO' }
                    ]
                }));
            }
            
            const data = JSON.parse(localStorage.getItem('kanban_data'));
            
            if (endpoint === 'columnas') resolve({ data: data.columnas });
            else if (endpoint === 'tarjetas') resolve({ data: data.tarjetas });
            else if (endpoint === 'alcalde') resolve({ data: data.alcalde });
            else if (endpoint === 'stats') {
                const stats = {
                    total: data.tarjetas.length,
                    alumnosActivos: data.alcalde.filter(a => a.estado === 'activo').length,
                    byColumn: {}
                };
                data.columnas.forEach(c => {
                    stats.byColumn[c.name] = data.tarjetas.filter(t => t.column_id === c.id).length;
                });
                resolve({ data: stats });
            }
            else resolve({ data: null });
        }, 50);
    });
}

// Exportar para uso global
window.initSupabase = initSupabase;
window.checkConnection = checkConnection;
window.API = API;
