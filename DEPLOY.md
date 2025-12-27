# Guía de Despliegue en Coolify

Esta guía te ayudará a desplegar el Sistema Deportivo Municipal en tu servidor Coolify.

## Tabla de Contenidos

- [Prerequisitos](#prerequisitos)
- [Opción 1: Despliegue con Docker Compose (Recomendado)](#opción-1-despliegue-con-docker-compose-recomendado)
- [Opción 2: Servicios Separados](#opción-2-servicios-separados)
- [Configuración Post-Despliegue](#configuración-post-despliegue)
- [Verificación](#verificación)
- [Troubleshooting](#troubleshooting)

## Prerequisitos

1. Servidor con Coolify instalado y funcionando
2. Acceso SSH al servidor (opcional, para verificación)
3. Dominio configurado (opcional, pero recomendado)
4. Los repositorios Git deben estar públicos o Coolify debe tener acceso a ellos

**Repositorios:**
- Backend: `https://github.com/carlosvidal/surco-deportes-backend`
- Frontend: `https://github.com/carlosvidal/surco-deportes-frontend`

## Opción 1: Despliegue con Docker Compose (Recomendado)

Esta opción despliega todo el stack (PostgreSQL + Backend + Frontend) con un solo comando.

### Paso 1: Crear Nuevo Servicio en Coolify

1. Inicia sesión en tu panel de Coolify
2. Ve a **Projects** > **New Project**
3. Dale un nombre al proyecto: `Sistema Deportivo Surco`
4. Crea un nuevo **Environment** (por ejemplo: `production`)

### Paso 2: Agregar Servicio Docker Compose

1. Dentro del proyecto, haz clic en **Add New Service**
2. Selecciona **Docker Compose**
3. Configura:
   - **Name**: `surco-deportes`
   - **Repository**: Deja en blanco (usaremos un repositorio monorepo)
   - **Docker Compose File**: Selecciona "Custom Docker Compose"

### Paso 3: Configurar Docker Compose

En el editor de Docker Compose, pega el siguiente contenido (que está en tu archivo `docker-compose.yml`):

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - surco-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s

  backend:
    build:
      context: https://github.com/carlosvidal/surco-deportes-backend.git
      dockerfile: Dockerfile
    restart: unless-stopped
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@postgres:5432/${DB_NAME}
      JWT_SECRET: ${JWT_SECRET}
      NODE_ENV: production
      PORT: 3000
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - surco-network
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend:
    build:
      context: https://github.com/carlosvidal/surco-deportes-frontend.git
      dockerfile: Dockerfile
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - surco-network

volumes:
  postgres_data:
    driver: local

networks:
  surco-network:
    driver: bridge
```

### Paso 4: Configurar Variables de Entorno

En la sección **Environment Variables** de Coolify, agrega:

```env
DB_USER=surco
DB_PASSWORD=<GENERAR_PASSWORD_SEGURO>
DB_NAME=surco_deportes
JWT_SECRET=<GENERAR_JWT_SECRET_32_CHARS>
```

**Importante:** Usa contraseñas seguras. Puedes generarlas con:
```bash
# Para DB_PASSWORD
openssl rand -base64 32

# Para JWT_SECRET
openssl rand -base64 48
```

### Paso 5: Configurar Dominio (Opcional)

1. Ve a **Domains** en el servicio frontend
2. Agrega tu dominio: `surco-deportes.tudominio.com`
3. Coolify configurará automáticamente SSL con Let's Encrypt

### Paso 6: Desplegar

1. Haz clic en **Deploy**
2. Coolify comenzará a:
   - Clonar los repositorios
   - Construir las imágenes Docker
   - Crear la red y volúmenes
   - Levantar los contenedores
3. Espera a que el despliegue termine (puede tomar 5-10 minutos)

### Paso 7: Ejecutar Migraciones Iniciales

Después del primer despliegue, necesitas ejecutar las migraciones de Prisma:

1. Ve al contenedor `backend` en Coolify
2. Abre una **Shell/Terminal**
3. Ejecuta:
```bash
npx prisma migrate deploy
npx prisma db seed
```

Esto creará las tablas y el usuario admin inicial.

---

## Opción 2: Servicios Separados

Si prefieres tener más control y servicios separados en Coolify:

### Paso 1: Crear Base de Datos PostgreSQL

1. En Coolify, ve a **Databases** > **New Database**
2. Selecciona **PostgreSQL**
3. Configura:
   - **Name**: `surco-postgres`
   - **Version**: `16`
   - **Database Name**: `surco_deportes`
   - **Username**: `surco`
   - **Password**: (Coolify genera uno automático, guárdalo)

### Paso 2: Desplegar Backend

1. **Add New Service** > **Application**
2. Configura:
   - **Name**: `surco-backend`
   - **Source**: GitHub
   - **Repository**: `carlosvidal/surco-deportes-backend`
   - **Branch**: `main`
   - **Build Pack**: Dockerfile

3. **Environment Variables**:
```env
DATABASE_URL=postgresql://surco:<PASSWORD>@surco-postgres:5432/surco_deportes
JWT_SECRET=<TU_JWT_SECRET>
NODE_ENV=production
PORT=3000
```

4. **Port**: `3000`

5. **Domains**:
   - `api.surco-deportes.tudominio.com` (opcional)

6. Deploy

7. **Ejecutar migraciones** (en la shell del contenedor):
```bash
npx prisma migrate deploy
npx prisma db seed
```

### Paso 3: Desplegar Frontend

1. **Add New Service** > **Application**
2. Configura:
   - **Name**: `surco-frontend`
   - **Source**: GitHub
   - **Repository**: `carlosvidal/surco-deportes-frontend`
   - **Branch**: `main`
   - **Build Pack**: Dockerfile

3. **Build Arguments** (si Coolify lo soporta):
```env
VITE_API_URL=https://api.surco-deportes.tudominio.com/api
```

Si usas el mismo dominio con proxy:
```env
VITE_API_URL=/api
```

4. **Port**: `80`

5. **Domains**:
   - `surco-deportes.tudominio.com`

6. **Proxy Configuration** (si frontend y backend están en el mismo dominio):
   - Configura Nginx para hacer proxy de `/api` al backend

7. Deploy

---

## Configuración Post-Despliegue

### 1. Verificar Usuario Admin

El seed crea un usuario por defecto:
- **Usuario**: `admin`
- **Contraseña**: `admin123`

**⚠️ IMPORTANTE**: Cambia esta contraseña en producción.

### 2. Configurar CORS (si backend y frontend están en dominios diferentes)

Si desplegaste backend y frontend en dominios separados, necesitas configurar CORS en el backend.

Edita `backend/src/app.ts` y actualiza la configuración de CORS:

```typescript
app.use(cors({
  origin: ['https://surco-deportes.tudominio.com'],
  credentials: true
}));
```

### 3. Backups Automáticos

Configura backups automáticos de la base de datos en Coolify:

1. Ve a tu base de datos PostgreSQL
2. **Backups** > **Configure**
3. Habilita backups diarios

---

## Verificación

### 1. Verificar Backend

```bash
curl https://api.surco-deportes.tudominio.com/api/health
```

Respuesta esperada:
```json
{
  "status": "ok",
  "timestamp": "2025-12-26T..."
}
```

### 2. Verificar Base de Datos

En la shell del backend:
```bash
npx prisma studio
```

Deberías ver las tablas creadas y el usuario admin.

### 3. Verificar Frontend

Abre `https://surco-deportes.tudominio.com` en el navegador.

Deberías ver la pantalla de login.

### 4. Login de Prueba

- Usuario: `admin`
- Contraseña: `admin123`

---

## Troubleshooting

### Error: "Cannot connect to database"

**Causa**: El backend no puede conectarse a PostgreSQL.

**Solución**:
1. Verifica que la variable `DATABASE_URL` esté correcta
2. Asegúrate de que el contenedor de PostgreSQL esté corriendo
3. Verifica que estén en la misma red Docker
4. Revisa los logs del backend: `docker logs <backend-container>`

### Error: "Prisma Client not generated"

**Causa**: El cliente de Prisma no se generó durante el build.

**Solución**:
En la shell del backend:
```bash
npx prisma generate
```

O reconstruye la imagen.

### Error: "Migration failed"

**Causa**: Las migraciones no se ejecutaron correctamente.

**Solución**:
```bash
npx prisma migrate deploy --schema=./prisma/schema.prisma
```

### Error 502 en el Frontend

**Causa**: El frontend no puede comunicarse con el backend.

**Solución**:
1. Verifica que `VITE_API_URL` apunte a la URL correcta del backend
2. Si usas proxy reverso, verifica la configuración de nginx
3. Revisa los CORS en el backend

### Frontend carga pero login no funciona

**Causa**: La API URL está mal configurada.

**Solución**:
1. Abre DevTools del navegador (F12)
2. Ve a la pestaña Network
3. Intenta hacer login y ve qué URL se está llamando
4. Ajusta `VITE_API_URL` según sea necesario

### Check-out automático no funciona

**Causa**: El cron job no está corriendo.

**Solución**:
Verifica los logs del backend:
```bash
docker logs -f <backend-container>
```

Deberías ver mensajes como:
```
[CRON] Ejecutando check-out automático...
```

---

## Actualizar la Aplicación

### Con Docker Compose

1. Haz commit de tus cambios en GitHub
2. En Coolify, ve al servicio
3. Haz clic en **Redeploy**
4. Coolify hará:
   - Git pull
   - Rebuild de las imágenes
   - Recreación de contenedores

### Servicios Separados

1. Ve a cada servicio (backend/frontend)
2. Haz clic en **Redeploy**
3. Coolify reconstruirá y desplegará

---

## Monitoreo

### Logs

En Coolify puedes ver los logs en tiempo real:
1. Ve al servicio
2. **Logs** > **Live Logs**

### Métricas

Coolify proporciona métricas básicas:
- CPU Usage
- Memory Usage
- Network I/O

### Health Checks

Coolify monitoreará automáticamente los health checks configurados en el docker-compose.

---

## Seguridad

### Recomendaciones

1. **Cambiar credenciales por defecto**
   - Usuario admin
   - Passwords de base de datos

2. **Usar HTTPS**
   - Coolify configura SSL automáticamente con Let's Encrypt

3. **Configurar Firewall**
   - Solo abrir puertos necesarios (80, 443, 22)

4. **Actualizar regularmente**
   - Mantén las imágenes Docker actualizadas
   - Actualiza dependencias de Node.js

5. **Backups**
   - Configura backups automáticos de la base de datos
   - Descarga backups periódicamente

---

## Recursos Adicionales

- [Documentación de Coolify](https://coolify.io/docs)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Prisma Migrations](https://www.prisma.io/docs/concepts/components/prisma-migrate)

## Soporte

Si tienes problemas durante el despliegue:

1. Revisa los logs en Coolify
2. Verifica las variables de entorno
3. Consulta esta guía de troubleshooting
4. Revisa los repositorios en GitHub

---

**¡Listo!** Tu Sistema Deportivo Municipal debería estar corriendo en Coolify.
