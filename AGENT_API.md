# =====================================================
# AQUADUCTO - API AGENT
# Endpoints para que yo (CEO) pueda gestionar datos
# =====================================================

# Configuración
const SUPABASE_URL = 'https://wpvtzjhzgzwsjdnpynbf.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_NjoVcQRnSkyjiRE9FrPQNA_86FYGUIo';

# =====================================================
# AGENT FUNCTIONS (yo las uso para gestionar)
# =====================================================

# Crear un contacto nuevo
fn crear_contacto(nombre, empresa, cargo, email, telefono, notas) {
    POST /rest/v1/contactos
    {
        "nombre": nombre,
        "empresa": empresa, 
        "cargo": cargo,
        "email": email,
        "telefono": telefono,
        "notas": notas,
        "estado": "activo"
    }
}

# Crear una tarea con checklist
fn crear_tarea(titulo, descripcion, contacto_email, prioridad, columna, checklist_items[]) {
    # 1. Buscar contacto por email
    contacto = GET /rest/v1/contactos?email=eq.contacto_email
    
    # 2. Crear tarea
    tarea_id = POST /rest/v1/tareas
    {
        "titulo": titulo,
        "descripcion": descripcion,
        "contacto_id": contacto.id,
        "prioridad": prioridad,
        "columna_id": columna
    }
    
    # 3. Crear checklist items
    FOR item IN checklist_items:
        POST /rest/v1/checklist
        {
            "tarea_id": tarea_id,
            "texto": item,
            "completado": false
        }
}

# Añadir item a checklist de tarea
fn anadir_checklist(tarea_id, texto_item) {
    POST /rest/v1/checklist
    {
        "tarea_id": tarea_id,
        "texto": texto_item,
        "completado": false
    }
}

# Mover tarea a otra columna
fn mover_tarea(tarea_id, nueva_columna) {
    PATCH /rest/v1/tareas?id=eq.tarea_id
    {
        "columna_id": nueva_columna
    }
}

# Marcar checklist como completado
fn completar_checklist(checklist_id) {
    PATCH /rest/v1/checklist?id=eq.checklist_id
    {
        "completado": true
    }
}

# Obtener dashboard completo
fn get_dashboard() {
    contactos = GET /rest/v1/contactos
    tareas = GET /rest/v1/tareas
    columnas = GET /rest/v1/columnas
    checklist = GET /rest/v1/checklist
    
    # Calcular estadísticas
    stats = {
        "total_contactos": COUNT(contactos),
        "total_tareas": COUNT(tareas),
        "tareas_por_columna": GROUP_BY(tareas, columna_id),
        "tareas_activas": COUNT(tareas WHERE columna_id != "completado"),
        "pendientes_info": COUNT(tareas WHERE columna_id == "pendiente")
    }
    
    RETURN { contactos, tareas, columnas, checklist, stats }
}

# =====================================================
# EJEMPLOS DE USO DESDE EL CEO (yo)
# =====================================================

# "Añade contacto de Juan García"
# → crear_contacto("Juan García", "Constructora SL", "Director", "juan@constructora.es", "+34 600 000 000", "Proyecto importante")

# "Nueva tarea: Revisar presupuesto para María López"
# → crear_tarea("Revisar presupuesto", "Necesario para aprobar proyecto", "maria.lopez@ayto-sevilla.es", "alta", "pendiente", ["Presupuesto detallado", "Certificado financiero"])

# "Añade a la tarea de Sevilla el item 'Estudio geotécnico'"
# → anadir_checklist(tarea_id, "Estudio geotécnico")
