# Configuración para Coolify - Tu Servidor

Esta es la configuración específica para tu despliegue en Coolify.

## 📊 Base de Datos Existente

Ya tienes una base de datos PostgreSQL configurada en Coolify:

```
Host: noow4s4ckwok0wsswk0goc80
Port: 5432
Database: postgres
User: postgres
```

## 🚀 Opción Recomendada: Servicios Separados

Ya que tienes PostgreSQL configurado, te recomiendo desplegar Backend y Frontend como servicios separados.

### Paso 1: Desplegar Backend

1. **En Coolify**: Projects > Tu Proyecto > Add New Service
2. **Tipo**: Application
3. **Configuración**:

#### Source
- **Repository**: `https://github.com/carlosvidal/surco-deportes-backend`
- **Branch**: `main`
- **Build Pack**: Dockerfile

#### Environment Variables

Agrega estas variables en la sección Environment Variables de Coolify:

```env
DATABASE_URL=postgres://postgres:uKs9SVSUrxmQV1Q9P5MFgxsYzCJiqophcJ7YDbWKaAutpsYxgqNlDI9jYB1AhG0u@noow4s4ckwok0wsswk0goc80:5432/postgres

JWT_SECRET=<GENERAR_UN_SECRET_NUEVO>

NODE_ENV=production

PORT=3000
```

Para generar `JWT_SECRET` seguro:
```bash
openssl rand -base64 48
```

O usa este ejemplo (cámbialo):
```
JWT_SECRET=8K7m2P9nR4tV6xY1zB3dF5gH8jL0mN2pQ4rS6uW8yA0cE2fG4h
```

#### Port Mapping
- **Port**: `3000`

#### Domains (Opcional)
- Puedes agregar un dominio o usar la URL que Coolify te asigne
- Ejemplo: `api-surco.tudominio.com`

#### Deploy
- Haz clic en **Deploy**
- Espera a que termine el build (5-10 minutos)

### Paso 2: Ejecutar Migraciones (IMPORTANTE)

Una vez que el backend esté desplegado:

1. **Ve al servicio backend en Coolify**
2. **Abre la Terminal/Shell del contenedor**
3. **Ejecuta estos comandos**:

```bash
# Generar cliente de Prisma
npx prisma generate

# Ejecutar migraciones
npx prisma migrate deploy

# Crear usuario admin inicial
npx prisma db seed
```

**Salida esperada**:
```
✓ Generated Prisma Client
✓ Migrations deployed
✓ Seed executed successfully

Usuario admin creado:
- Usuario: admin
- Contraseña: admin123
```

### Paso 3: Verificar Backend

Abre la URL del backend + `/api/health`:

```bash
curl https://tu-backend-url.com/api/health
```

Deberías ver:
```json
{
  "status": "ok",
  "timestamp": "2025-12-26T..."
}
```

### Paso 4: Desplegar Frontend

1. **En Coolify**: Add New Service
2. **Tipo**: Application
3. **Configuración**:

#### Source
- **Repository**: `https://github.com/carlosvidal/surco-deportes-frontend`
- **Branch**: `main`
- **Build Pack**: Dockerfile

#### Build Arguments

Si Coolify soporta build arguments, agrega:

```env
VITE_API_URL=https://tu-backend-url.com/api
```

Si usas el mismo dominio con subdirectorios:
```env
VITE_API_URL=/api
```

**IMPORTANTE**: Si usas `/api`, necesitarás configurar un proxy reverso (ver abajo).

#### Port Mapping
- **Port**: `80`

#### Domains
- Agrega tu dominio principal: `surco-deportes.tudominio.com`

#### Deploy
- Haz clic en **Deploy**

### Paso 5: Configuración de Proxy (Si usas el mismo dominio)

Si quieres que frontend y backend estén en el mismo dominio:
- Frontend: `https://surco-deportes.tudominio.com`
- Backend: `https://surco-deportes.tudominio.com/api`

Necesitas configurar Coolify para que haga proxy de `/api` al backend.

**Opción A: Usando nginx en Coolify**

El frontend ya tiene configurado el proxy en `nginx.conf` (líneas 25-37), pero esto solo funciona si ambos servicios están en la misma red Docker.

**Opción B: URLs separadas (Más fácil)**

- Frontend: `https://app.surco-deportes.tudominio.com`
- Backend: `https://api.surco-deportes.tudominio.com`

Entonces en el frontend:
```env
VITE_API_URL=https://api.surco-deportes.tudominio.com/api
```

Y necesitas actualizar CORS en el backend.

### Paso 6: Configurar CORS en Backend (Si usas dominios separados)

Si frontend y backend están en dominios diferentes, necesitas configurar CORS:

1. **Edita el archivo** `backend/src/app.ts` en GitHub
2. **Encuentra la línea de CORS** (aproximadamente línea 15-20)
3. **Actualízala**:

```typescript
app.use(cors({
  origin: [
    'https://app.surco-deportes.tudominio.com',
    'https://surco-deportes.tudominio.com'
  ],
  credentials: true
}));
```

4. **Haz commit y push**
5. **Redeploy el backend** en Coolify

## 🔐 Credenciales de Acceso

Después del seed, puedes acceder con:

- **Usuario**: `admin`
- **Contraseña**: `admin123`

⚠️ **Cámbiala inmediatamente después del primer login**

## ✅ Verificación Final

### 1. Backend Health Check
```bash
curl https://tu-backend-url/api/health
```

### 2. Test Login
```bash
curl -X POST https://tu-backend-url/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"admin","password":"admin123"}'
```

Deberías recibir un token JWT.

### 3. Frontend
- Abre `https://tu-frontend-url.com`
- Deberías ver la pantalla de login
- Intenta hacer login con admin/admin123

## 🎯 Resumen de URLs

Anota tus URLs aquí:

```
Base de Datos: noow4s4ckwok0wsswk0goc80:5432
Backend: _______________________
Frontend: _______________________
```

## 📝 Variables de Entorno - Resumen

### Backend
```env
DATABASE_URL=postgres://postgres:uKs9SVSUrxmQV1Q9P5MFgxsYzCJiqophcJ7YDbWKaAutpsYxgqNlDI9jYB1AhG0u@noow4s4ckwok0wsswk0goc80:5432/postgres
JWT_SECRET=<tu_secret_generado>
NODE_ENV=production
PORT=3000
```

### Frontend
```env
VITE_API_URL=<url_de_tu_backend>/api
```

## 🔄 Actualizar la Aplicación

Cuando hagas cambios en el código:

1. **Haz commit y push** a GitHub
2. **En Coolify**, ve al servicio
3. **Click en "Redeploy"**
4. Coolify hará git pull y rebuild automáticamente

## 🐛 Troubleshooting

### Error: "Prisma Client not generated"

En la shell del backend:
```bash
npx prisma generate
```

### Error: "Cannot connect to database"

Verifica que `DATABASE_URL` esté correctamente configurada en las variables de entorno de Coolify.

### Error 502 en Frontend

1. Verifica que el backend esté corriendo
2. Revisa `VITE_API_URL` en las variables del frontend
3. Si usas dominios separados, verifica CORS

### Frontend carga pero login no funciona

1. Abre DevTools (F12) > Network
2. Intenta hacer login
3. Ve a qué URL está llamando
4. Ajusta `VITE_API_URL` según sea necesario

## 📞 Próximos Pasos

1. ✅ Despliega el backend
2. ✅ Ejecuta migraciones y seed
3. ✅ Verifica el health check
4. ✅ Despliega el frontend
5. ✅ Configura dominios
6. ✅ Haz login de prueba
7. ✅ Cambia la contraseña del admin

---

**¿Listo para comenzar?** Empieza con el Paso 1: Desplegar Backend.
