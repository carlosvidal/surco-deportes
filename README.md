# Sistema de Gestión Deportiva Municipal – Surco

## Centro Piloto: Charilla del Estanque

Sistema web para gestión de piscinas y centros deportivos municipales con control de horas, check-in/check-out en tiempo real y auditoría completa.

## Características Principales (MVP)

- ✅ Registro de vecinos con validación de DNI
- ✅ Venta de paquetes de horas (1, 4, 8, 12 horas)
- ✅ Check-in / Check-out en tiempo real
- ✅ Control de carriles de piscina
- ✅ Cálculo automático de saldo (Compras - Consumos)
- ✅ Auditoría completa de operaciones
- ✅ Caja diaria con cierre
- ✅ Sistema multi-sede desde día 1

## Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Backend | Node.js + Express + TypeScript |
| Base de datos | PostgreSQL 16 + Prisma ORM |
| Frontend | Vue 3 + Vite + Pinia |
| Deploy | Docker + Docker Compose |

## Estructura del Proyecto

```
piscina/
├── backend/
│   ├── src/
│   │   ├── controllers/      # Controladores de API
│   │   ├── services/         # Lógica de negocio
│   │   ├── middleware/       # Auth, errores, etc.
│   │   ├── routes/           # Definición de rutas
│   │   ├── types/            # Tipos TypeScript
│   │   └── utils/            # Configuración y utilidades
│   ├── prisma/
│   │   ├── schema.prisma     # Modelo de datos
│   │   └── seed.ts           # Datos iniciales
│   └── Dockerfile
│
├── frontend/
│   ├── src/
│   │   ├── views/            # Páginas principales
│   │   ├── components/       # Componentes reutilizables
│   │   ├── stores/           # Estado global (Pinia)
│   │   ├── services/         # Llamadas a API
│   │   └── router/           # Rutas de Vue
│   └── Dockerfile
│
├── docker-compose.yml
├── .env.example
└── README.md
```

## Instalación y Uso

### Requisitos Previos

- Node.js 20+
- PostgreSQL 16+ (o usar Docker)
- npm o yarn

### Opción 1: Desarrollo Local

#### 1. Configurar variables de entorno

```bash
# Crear archivo .env en la raíz
cp .env.example .env

# Editar .env con tus credenciales
```

#### 2. Instalar dependencias del Backend

```bash
cd backend
npm install
```

#### 3. Configurar base de datos

```bash
# Generar cliente de Prisma
npm run prisma:generate

# Ejecutar migraciones
npm run prisma:migrate

# Ejecutar seed (datos de prueba)
npm run prisma:seed
```

#### 4. Iniciar el Backend

```bash
npm run dev
# El servidor estará en http://localhost:3000
```

#### 5. Instalar dependencias del Frontend

```bash
cd ../frontend
npm install
```

#### 6. Iniciar el Frontend

```bash
npm run dev
# La aplicación estará en http://localhost:5173
```

### Opción 2: Con Docker

```bash
# Crear archivo .env
cp .env.example .env

# Iniciar todos los servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Ejecutar migraciones
docker-compose exec backend npx prisma migrate deploy

# Ejecutar seed
docker-compose exec backend npm run prisma:seed
```

La aplicación estará disponible en:
- Frontend: http://localhost
- Backend API: http://localhost:3000
- Base de datos: localhost:5432

## Credenciales de Prueba

Después de ejecutar el seed, podrás usar:

### Administrador Municipal
- Usuario: `admin`
- Contraseña: `admin123`

### Recepcionista
- Usuario: `maria.garcia`
- Contraseña: `recepcion123`

## Vecinos de Prueba

| DNI | Nombre | Distrito | Es Surco |
|-----|--------|----------|----------|
| 12345678 | Carlos Mendoza Torres | Santiago de Surco | Sí |
| 87654321 | María López García | Santiago de Surco | Sí |
| 11223344 | Pedro Ruiz Sánchez | Miraflores | No |

## API Endpoints

### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `GET /api/auth/verify` - Verificar token

### Vecinos
- `GET /api/vecinos/:dni` - Buscar vecino por DNI
- `POST /api/vecinos` - Registrar nuevo vecino
- `PUT /api/vecinos/:dni` - Actualizar datos
- `GET /api/vecinos/:dni/historial` - Historial completo
- `GET /api/vecinos/buscar?q=query` - Buscar por nombre

### Consumos (Check-in/Check-out)
- `POST /api/consumos/checkin` - Registrar entrada
- `PUT /api/consumos/:id/checkout` - Registrar salida
- `POST /api/consumos/:id/anular` - Anular consumo
- `GET /api/consumos/activos` - Consumos activos
- `GET /api/consumos/activos/:instalacion` - Por instalación

## Tarifas

### Vecinos de Santiago de Surco
- 1 hora: S/ 5.00
- 4 horas: S/ 18.00
- 8 horas: S/ 32.00
- 12 horas: S/ 42.00

### Otros Distritos
- 1 hora: S/ 8.00
- 4 horas: S/ 28.00
- 8 horas: S/ 52.00
- 12 horas: S/ 72.00

## Reglas de Negocio

1. **Saldo = Compras - Consumos** (calculado dinámicamente)
2. Sin saldo, no hay entrada
3. 1 hora = 1 unidad atómica (no hay fracciones)
4. Nada se borra, todo se anula (soft delete)
5. Un vecino solo puede tener un consumo activo a la vez

## Instalaciones Disponibles

- 🏊 **Piscina Adultos** - 8 carriles (25m)
- 🧒 **Piscina Niños** - 5 carriles
- 🎾 **Paddle** - Sin carriles
- 💪 **Gimnasio** - Sin carriles
- 🔥 **Parrillas** - (Próximamente)

## Auditoría

Todas las operaciones importantes quedan registradas en `audit_log`:
- Registro y actualización de vecinos
- Compras y anulaciones
- Check-ins, check-outs y anulaciones
- Apertura y cierre de caja
- Logins de staff

## Comandos Útiles

### Backend

```bash
# Desarrollo
npm run dev

# Build
npm run build

# Producción
npm start

# Prisma Studio (GUI)
npm run prisma:studio

# Crear migración
npm run prisma:migrate
```

### Frontend

```bash
# Desarrollo
npm run dev

# Build
npm run build

# Preview de producción
npm run preview
```

### Docker

```bash
# Iniciar servicios
docker-compose up -d

# Detener servicios
docker-compose down

# Ver logs
docker-compose logs -f [servicio]

# Reconstruir
docker-compose up -d --build

# Limpiar volúmenes
docker-compose down -v
```

## Próximas Funcionalidades (Fase 2)

- [ ] Reservas simples
- [ ] Clases grupales
- [ ] Gestión de familias/menores
- [ ] Reportes por sede
- [ ] Exportación de datos
- [ ] Venta de paquetes desde el frontend

## Próximas Funcionalidades (Fase 3)

- [ ] Portal del vecino
- [ ] Pagos online
- [ ] App móvil / QR
- [ ] Integración con sistema municipal

## Soporte

Para reportar problemas o sugerencias, contactar al equipo de desarrollo.

## Licencia

Uso exclusivo para la Municipalidad de Santiago de Surco.

---

**Versión:** 1.0 MVP
**Fecha:** Diciembre 2024
**Estado:** En desarrollo
