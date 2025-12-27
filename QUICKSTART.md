# Guía de Inicio Rápido

## Opción 1: Inicio Rápido con Docker (Recomendado)

### Requisitos
- Docker y Docker Compose instalados

### Pasos

1. **Ejecutar el script de inicio:**
```bash
./start-dev.sh
```

Esto hará automáticamente:
- Crear archivo .env si no existe
- Iniciar PostgreSQL, Backend y Frontend
- Ejecutar migraciones
- Cargar datos de prueba

2. **Acceder a la aplicación:**
- Frontend: http://localhost
- Backend: http://localhost:3000

3. **Credenciales de prueba:**
- Admin: `admin` / `admin123`
- Recepcionista: `maria.garcia` / `recepcion123`

## Opción 2: Desarrollo Local (Sin Docker)

### Requisitos
- Node.js 20+
- PostgreSQL 16+

### Configurar Base de Datos

```bash
# Crear base de datos en PostgreSQL
createdb surco_deportes

# O desde psql:
psql -U postgres
CREATE DATABASE surco_deportes;
```

### Configurar Backend

```bash
cd backend

# Instalar dependencias
npm install

# Crear archivo .env
cp .env.example .env

# Editar .env con tus credenciales de PostgreSQL
# DATABASE_URL="postgresql://usuario:password@localhost:5432/surco_deportes"

# Generar cliente Prisma
npm run prisma:generate

# Ejecutar migraciones
npm run prisma:migrate

# Cargar datos de prueba
npm run prisma:seed

# Iniciar servidor de desarrollo
npm run dev
```

El backend estará en http://localhost:3000

### Configurar Frontend

```bash
# En otra terminal
cd frontend

# Instalar dependencias
npm install

# Crear archivo .env (opcional)
cp .env.example .env

# Iniciar servidor de desarrollo
npm run dev
```

El frontend estará en http://localhost:5173

## Verificar que Todo Funciona

1. Abrir http://localhost (o http://localhost:5173 en desarrollo local)
2. Login con: `admin` / `admin123`
3. Deberías ver el dashboard con las piscinas
4. Buscar vecino por DNI: `12345678`
5. Deberías ver la ficha de Carlos Mendoza con saldo

## Comandos Útiles

### Docker
```bash
# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar un servicio
docker-compose restart backend

# Detener todo
docker-compose down

# Eliminar todo (incluye base de datos)
docker-compose down -v
```

### Desarrollo Local

#### Backend
```bash
# Ver base de datos con GUI
npm run prisma:studio

# Crear nueva migración
npm run prisma:migrate

# Reiniciar base de datos
npm run prisma:migrate -- reset
```

#### Frontend
```bash
# Build para producción
npm run build

# Preview de producción
npm run preview
```

## Estructura de Archivos Importantes

```
piscina/
├── backend/
│   ├── prisma/schema.prisma       # Modelo de datos
│   ├── src/
│   │   ├── controllers/           # API endpoints
│   │   ├── services/              # Lógica de negocio
│   │   └── routes/index.ts        # Rutas de la API
│   └── .env                       # Configuración (crear desde .env.example)
│
├── frontend/
│   ├── src/
│   │   ├── views/                 # Páginas principales
│   │   ├── stores/                # Estado global (Pinia)
│   │   └── services/api.ts        # Llamadas al backend
│   └── .env                       # Configuración (opcional)
│
└── docker-compose.yml             # Orquestación de servicios
```

## Flujo de Trabajo Básico

### 1. Registrar un Vecino Nuevo
- Dashboard → Buscar DNI que no existe
- Click en "Crear nuevo"
- Completar formulario
- Guardar

### 2. Vender Paquete de Horas
- Buscar vecino por DNI
- Click en "Vender Horas"
- Seleccionar paquete (1, 4, 8 o 12 horas)
- Seleccionar método de pago
- Confirmar

### 3. Check-in (Entrada a Piscina)
- Dashboard → Ver carril libre
- Click en "+ Check-in"
- Ingresar DNI del vecino
- Confirmar (descuenta 1 hora)

### 4. Check-out (Salida)
- Dashboard → Ver carril ocupado
- Click en "Salida"
- Confirma la salida

## Solución de Problemas

### Backend no inicia
```bash
# Verificar logs
docker-compose logs backend

# O en desarrollo local:
cd backend && npm run dev
```

### Frontend no conecta con Backend
- Verificar que el backend esté en http://localhost:3000
- Verificar VITE_API_URL en frontend/.env

### Base de datos no conecta
```bash
# Verificar que PostgreSQL esté corriendo
docker-compose ps

# Verificar DATABASE_URL en backend/.env
```

### Resetear todo
```bash
# Con Docker
docker-compose down -v
./start-dev.sh

# Sin Docker
cd backend
npm run prisma:migrate -- reset
npm run prisma:seed
```

## Próximos Pasos

1. Revisar el [PRD completo](PRD-Sistema-Deportivo-Municipal-Surco.md)
2. Ver la [documentación completa](README.md)
3. Explorar los endpoints de la API
4. Personalizar tarifas en `backend/src/utils/config.ts`

## Soporte

Para problemas o preguntas, revisar:
- [README.md](README.md) - Documentación completa
- [PRD](PRD-Sistema-Deportivo-Municipal-Surco.md) - Especificación del producto
- Logs del sistema: `docker-compose logs -f`
