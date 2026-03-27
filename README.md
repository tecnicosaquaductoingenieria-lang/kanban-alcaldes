# Configurar Supabase

## 1. Obtener credenciales

En Supabase Dashboard → Settings → API:

- **Project URL:** `https://wpvtzjhzgzwsjdnpynbf.supabase.co`
- **anon/public key:** (la key pública)
- **service_role key:** (para admin, NO compartir)

## 2. Ejecutar SQL

En Supabase Dashboard → SQL Editor:

1. Copia el contenido de `sql/schema.sql`
2. Pégalo en el SQL Editor
3. Ejecuta "Run"

## 3. Configurar el frontend

Edita `public/config.js` con tu anon key:

```javascript
const SUPABASE_URL = 'https://wpvtzjhzgzwsjdnpynbf.supabase.co';
const SUPABASE_ANON_KEY = 'tu-anon-key-aqui';
```

## 4. Desplegar

1. Sube a GitHub
2. Netlify detectará y desplegará automáticamente

## URLs importantes

- Dashboard: https://supabase.com/dashboard
- Docs: https://supabase.com/docs
