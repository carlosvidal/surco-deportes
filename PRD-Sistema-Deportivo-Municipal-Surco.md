# Sistema de Gestión Deportiva Municipal – Surco
## Centro Piloto: Charilla del Estanque

**Versión:** 1.0  
**Fecha:** Diciembre 2024  
**Estado:** MVP en desarrollo

---

## 1. Resumen Ejecutivo

### Problema Central
El Centro Deportivo Municipal de Charilla del Estanque opera actualmente con tarjetas de cartón que no distinguen entre horas compradas y horas consumidas, generando:

- Pérdida de ingresos por falta de control
- Conflictos con vecinos ("yo tenía horas")
- Riesgo de manejo inadecuado de caja
- Imposibilidad de escalar a más sedes

### Solución Propuesta
Sistema web para el personal del centro que permite registrar vecinos, vender paquetes de horas y controlar el consumo en tiempo real, con auditoría completa de todas las operaciones.

### Objetivo del Producto (en una línea)
> Registrar quién entra, qué usa, qué paga y quién lo autorizó, sin fricción para el personal y con auditoría municipal real.

---

## 2. Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Backend | Node.js + Express + Prisma |
| Base de datos | PostgreSQL 16 |
| Frontend | Vue 3 + Vite + Pinia |
| Deploy | Coolify (Docker) |

---

## 3. Principios de Diseño

1. **Operación primero, vecino después**  
   El MVP es para el recepcionista, no para el app del vecino.

2. **Todo descuenta algo**  
   Si no descuenta saldo o deja rastro → no existe.

3. **Nada se borra, todo se anula**  
   El sistema no confía en humanos. Los humanos se auditan.

4. **Multi-sede desde el día 1**  
   Aunque solo haya una piscina hoy.

---

## 4. Instalaciones del Centro

```
┌─────────────────────────────────────────────────────────────────────┐
│  PISCINA ADULTOS (25m)                                              │
│  ┌────┬────┬────┬────┬────┬────┬────┬────┐                         │
│  │ C1 │ C2 │ C3 │ C4 │ C5 │ C6 │ C7 │ C8 │  8 carriles            │
│  └────┴────┴────┴────┴────┴────┴────┴────┘                         │
├─────────────────────────────────────────────────────────────────────┤
│  PISCINA NIÑOS                                                      │
│  ┌────┬────┬────┬────┬────┐                                        │
│  │ C1 │ C2 │ C3 │ C4 │ C5 │  5 carriles                            │
│  └────┴────┴────┴────┴────┘                                        │
├─────────────────────────────────────────────────────────────────────┤
│  OTRAS INSTALACIONES                                                │
│  🎾 Paddle  •  💪 Gimnasio  •  🔥 Parrillas (próximamente)         │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 5. Alcance por Fases

### Fase 1 – MVP (Control Básico)

| Funcionalidad | Estado |
|---------------|--------|
| Registro de vecinos | ✅ Incluido |
| Venta de horas | ✅ Incluido |
| Check-in / Check-out | ✅ Incluido |
| Control de carriles | ✅ Incluido |
| Caja diaria | ✅ Incluido |
| Auditoría básica | ✅ Incluido |

> 👉 Esto ya elimina el caos

### Fase 2 – Orden Operativo

- Reservas simples
- Clases grupales
- Familias / menores
- Reportes por sede
- Histórico por vecino

### Fase 3 – Digitalización Vecinal

- Portal del vecino
- Pagos online
- App / QR
- Integración municipal

---

## 6. Perfiles de Usuario

### Recepcionista
- Opera una sede
- No ve datos financieros globales
- No puede borrar nada
- Puede anular con motivo

### Administrador de Sede
- Revisa cierres
- Ve reportes diarios
- Gestiona personal local

### Administrador Municipal (Distrito)
- Ve todas las sedes
- Consolida ingresos
- Audita personal
- Exporta a contabilidad

### Vecino (MVP = pasivo)
- Identificado por DNI
- Titular de saldo
- Puede ser: Adulto, Tutor de menores, Parte de una familia

---

## 7. Modelo de Datos

```
┌─────────────────────────────────────────────────────────────────────┐
│                           MODELO DE DATOS                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐       ┌──────────────┐       ┌──────────────┐    │
│  │   vecinos    │       │   compras    │       │   consumos   │    │
│  ├──────────────┤       ├──────────────┤       ├──────────────┤    │
│  │ dni (PK)     │──┐    │ id (PK)      │   ┌───│ id (PK)      │    │
│  │ nombre       │  │    │ vecino_dni   │◄──┤   │ vecino_dni   │◄───│
│  │ apellidos    │  │    │ horas        │   │   │ instalacion  │    │
│  │ telefono     │  └───►│ monto        │   │   │ carril       │    │
│  │ email        │       │ metodo_pago  │   │   │ entrada_at   │    │
│  │ distrito     │       │ referencia   │   │   │ salida_at    │    │
│  │ es_surco     │       │ staff_id     │   │   │ staff_id     │    │
│  │ created_at   │       │ created_at   │   │   │ created_at   │    │
│  └──────────────┘       └──────────────┘   │   └──────────────┘    │
│         │                                  │                        │
│         │                                  └────────────────────────│
│         ▼                                                           │
│  ┌──────────────┐       ┌──────────────┐       ┌──────────────┐    │
│  │   familias   │       │    staff     │       │  audit_log   │    │
│  ├──────────────┤       ├──────────────┤       ├──────────────┤    │
│  │ id (PK)      │       │ id (PK)      │       │ id (PK)      │    │
│  │ titular_dni  │       │ nombre       │       │ entidad      │    │
│  │ miembro_dni  │       │ usuario      │       │ entidad_id   │    │
│  │ parentesco   │       │ password     │       │ accion       │    │
│  └──────────────┘       │ rol          │       │ datos (JSON) │    │
│                         └──────────────┘       │ staff_id     │    │
│                                                └──────────────┘    │
│                         ┌──────────────┐                           │
│                         │    cajas     │                           │
│                         ├──────────────┤                           │
│                         │ id (PK)      │                           │
│                         │ fecha        │                           │
│                         │ saldo_inicial│                           │
│                         │ saldo_final  │                           │
│                         │ staff_id     │                           │
│                         └──────────────┘                           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 8. Reglas de Negocio

| # | Regla | Implementación |
|---|-------|----------------|
| 1 | **Saldo = Compras - Consumos** | Cálculo dinámico, nunca almacenado |
| 2 | **Sin saldo, no hay entrada** | Validar antes de check-in |
| 3 | **1 hora = 1 unidad atómica** | No hay fracciones |
| 4 | **Nada se borra** | Soft delete + log de anulaciones |
| 5 | **Menores usan saldo del tutor** | Vincular via tabla `familias` |

### Regla Anti-Vivos
> No hay "me quedo 10 minutitos más" sin registrar otra hora.

---

## 9. Tarifas

### Vecinos de Santiago de Surco

| Paquete | Precio |
|---------|--------|
| 1 hora | S/ 5.00 |
| 4 horas | S/ 18.00 |
| 8 horas | S/ 32.00 |
| 12 horas | S/ 42.00 |

### Otros Distritos

| Paquete | Precio |
|---------|--------|
| 1 hora | S/ 8.00 |
| 4 horas | S/ 28.00 |
| 8 horas | S/ 52.00 |
| 12 horas | S/ 72.00 |

---

## 10. Flujos de Usuario MVP

### Flujo 1: Registro de Vecino Nuevo

```
DNI → Buscar → ¿Existe? 
                  │
        ┌────────┴────────┐
        ▼                 ▼
      [Mostrar        [Formulario
       ficha]          registro]
                          │
                    Guardar → OK
```

### Flujo 2: Venta de Paquete

```
DNI → Buscar vecino → Seleccionar paquete
                            │
                    Calcular precio automático
                    (según distrito)
                            │
                    Método de pago → Confirmar
                            │
                    Imprimir recibo (opcional)
```

### Flujo 3: Check-in (el más usado)

```
DNI → Validar saldo > 0 → Seleccionar instalación
                                   │
                          Seleccionar carril (si aplica)
                                   │
                          Registrar entrada
                          (descuenta 1 hora)
                                   │
                          Mostrar en dashboard
```

---

## 11. Pantallas MVP

### 11.1 Dashboard Principal (Home del Recepcionista)

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏊 CHARILLA DEL ESTANQUE                     [Staff: María]  [⚙]  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─ PISCINA ADULTOS (25m) ──────────────────────────────────────┐  │
│  │  🏊 C1          🏊 C2          🏊 C3          🏊 C4          │  │
│  │  Juan Pérez     María López    ─ Libre ─     Pedro Ruiz     │  │
│  │  ⏱ 45 min      ⏱ 12 min                     ⏱ 58 min       │  │
│  │  [🟢]           [🟢]           [+ Check-in]  [🟡]           │  │
│  │                                                               │  │
│  │  🏊 C5          🏊 C6          🏊 C7          🏊 C8          │  │
│  │  ─ Libre ─     Ana Torres     ─ Libre ─     ─ Libre ─      │  │
│  │                ⏱ 30 min                                      │  │
│  │  [+ Check-in]  [🟢]           [+ Check-in]  [+ Check-in]   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ PISCINA NIÑOS ──────────────────────────────────────────────┐  │
│  │  🧒 C1          🧒 C2          🧒 C3          🧒 C4   🧒 C5  │  │
│  │  Lucía G.      ─ Libre ─     ─ Libre ─     Miguel   ─Libre─ │  │
│  │  ⏱ 20 min                                   ⏱ 5 min         │  │
│  │  [🟢]          [+ Check-in]  [+ Check-in]  [🟢]    [+]     │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ OTRAS INSTALACIONES ────────────────────────────────────────┐  │
│  │  🎾 Paddle: 2/2 ocupados     💪 Gimnasio: 5 personas         │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ ACCIONES RÁPIDAS ───────────────────────────────────────────┐  │
│  │  [🔍 Buscar Vecino]  [💰 Vender Horas]  [📊 Caja del Día]   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Estados visuales de tiempo:**
- 🟢 Verde: > 15 minutos restantes
- 🟡 Naranja: 5-15 minutos restantes
- 🔴 Rojo: < 5 minutos o tiempo excedido

### 11.2 Ficha de Vecino

```
┌─────────────────────────────────────────────────────────────────────┐
│  ← Volver                         FICHA DE VECINO                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  DNI: 12345678              Distrito: Santiago de Surco ✓           │
│  Nombre: Carlos Mendoza Torres                                      │
│  Teléfono: 999-888-777                                              │
│  Emergencia: Ana Mendoza (987-654-321)                              │
│                                                                     │
│  ┌─ SALDO ACTUAL ───────────────────────────────────────────────┐  │
│  │                                                               │  │
│  │      ██████████████████░░░░░░░░   6 horas disponibles        │  │
│  │      (Compradas: 12  •  Usadas: 6)                           │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  [🏊 Piscina Adultos]  [🧒 Piscina Niños]  [🎾 Paddle]  [💪 Gym]   │
│                                                                     │
│  ┌─ HISTORIAL RECIENTE ─────────────────────────────────────────┐  │
│  │  23 Dic  Piscina Adultos C3   11:30 - 12:30   ✓ Completado   │  │
│  │  20 Dic  Piscina Adultos C1   10:00 - 11:00   ✓ Completado   │  │
│  │  18 Dic  +4 horas             S/ 18.00        Efectivo       │  │
│  │  15 Dic  Gimnasio             09:15 - 10:15   ✓ Completado   │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  [💰 Vender Horas]                            [📝 Editar Datos]    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 11.3 Modal de Venta Rápida

```
┌─────────────────────────────────────────────────────────────────────┐
│                        VENTA DE HORAS                         [X]  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Vecino: Carlos Mendoza (12345678)                                  │
│  Tarifa: Vecino Surco                                               │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  ( ) 1 hora   - S/ 5.00                                       │  │
│  │  (●) 4 horas  - S/ 18.00  ← SELECCIONADO                      │  │
│  │  ( ) 8 horas  - S/ 32.00                                      │  │
│  │  ( ) 12 horas - S/ 42.00                                      │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  Método de pago:                                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  (●) Efectivo  ( ) Yape  ( ) Plin  ( ) Transferencia        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Referencia: [_________________] (solo si no es efectivo)          │
│                                                                     │
│                         Total: S/ 18.00                             │
│                                                                     │
│           [Cancelar]                    [✓ Confirmar Venta]         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 11.4 Modal de Check-in

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CHECK-IN                              [X]  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Vecino: Carlos Mendoza (12345678)                                  │
│  Saldo disponible: 6 horas ✓                                        │
│                                                                     │
│  Instalación: PISCINA ADULTOS                                       │
│                                                                     │
│  Seleccionar carril:                                                │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  [C1 ❌]  [C2 ❌]  [C3 ✓]  [C4 ❌]                            │  │
│  │  [C5 ✓]   [C6 ❌]  [C7 ✓]  [C8 ✓]                            │  │
│  └───────────────────────────────────────────────────────────────┘  │
│  ❌ = Ocupado    ✓ = Disponible                                     │
│                                                                     │
│  Carril seleccionado: C5                                            │
│                                                                     │
│  ⚠️ Se descontará 1 hora del saldo                                  │
│                                                                     │
│           [Cancelar]                    [✓ Confirmar Entrada]       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 11.5 Pantalla de Caja

```
┌─────────────────────────────────────────────────────────────────────┐
│  ← Volver                      CAJA DEL DÍA                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Fecha: 23 de Diciembre 2024                                        │
│  Staff: María García                                                │
│  Estado: 🟢 Abierta desde 08:00                                     │
│                                                                     │
│  ┌─ RESUMEN ────────────────────────────────────────────────────┐  │
│  │                                                               │  │
│  │  Saldo inicial:        S/   100.00                           │  │
│  │  ─────────────────────────────────                           │  │
│  │  Ventas efectivo:      S/   245.00                           │  │
│  │  Ventas Yape:          S/   118.00                           │  │
│  │  Ventas Plin:          S/    36.00                           │  │
│  │  Transferencias:       S/    84.00                           │  │
│  │  ─────────────────────────────────                           │  │
│  │  TOTAL VENTAS:         S/   483.00                           │  │
│  │  ─────────────────────────────────                           │  │
│  │  Efectivo esperado:    S/   345.00                           │  │
│  │                                                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ DETALLE DE TRANSACCIONES ───────────────────────────────────┐  │
│  │  14:32  Carlos Mendoza      +4 horas    S/ 18.00   Efectivo  │  │
│  │  14:15  Ana Torres          +8 horas    S/ 32.00   Yape      │  │
│  │  13:45  Pedro Ruiz          +1 hora     S/  5.00   Efectivo  │  │
│  │  12:20  María López         +12 horas   S/ 42.00   Plin      │  │
│  │  ...                                                          │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│                                              [🔒 Cerrar Caja]       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 12. API Endpoints MVP

### Vecinos

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/vecinos/:dni` | Buscar vecino + saldo calculado |
| POST | `/api/vecinos` | Registrar nuevo vecino |
| PUT | `/api/vecinos/:dni` | Actualizar datos del vecino |
| GET | `/api/vecinos/:dni/historial` | Compras y consumos |
| GET | `/api/vecinos/:dni/familia` | Miembros de familia |

### Compras

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/compras` | Registrar venta de paquete |
| GET | `/api/compras/:id` | Detalle de una compra |
| POST | `/api/compras/:id/anular` | Anular compra (con motivo) |

### Consumos

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/consumos/checkin` | Marcar entrada |
| PUT | `/api/consumos/:id/checkout` | Marcar salida |
| POST | `/api/consumos/:id/anular` | Anular consumo (con motivo) |
| GET | `/api/dashboard/activos` | Usuarios actualmente en instalación |

### Caja

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/caja/abrir` | Abrir caja del día |
| GET | `/api/caja/hoy` | Resumen de caja del día |
| POST | `/api/caja/cerrar` | Cerrar caja |
| GET | `/api/caja/:fecha` | Consultar caja de fecha específica |

### Reportes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/reportes/ventas` | Reporte de ventas por período |
| GET | `/api/reportes/ocupacion` | Ocupación por instalación |
| GET | `/api/reportes/auditoria` | Log de auditoría |

---

## 13. Schema Prisma Completo

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ─────────────────────────────────────────────────────────
// USUARIOS DEL SISTEMA (Staff)
// ─────────────────────────────────────────────────────────

model Staff {
  id          Int       @id @default(autoincrement())
  nombre      String
  usuario     String    @unique
  password    String
  rol         Rol       @default(RECEPCION)
  activo      Boolean   @default(true)
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  compras     Compra[]
  consumos    Consumo[]
  cajas       Caja[]

  @@map("staff")
}

enum Rol {
  RECEPCION
  ADMIN_SEDE
  ADMIN_MUNICIPAL
}

// ─────────────────────────────────────────────────────────
// VECINOS
// ─────────────────────────────────────────────────────────

model Vecino {
  dni                 String    @id @db.VarChar(8)
  nombre              String
  apellidos           String
  fechaNacimiento     DateTime? @map("fecha_nacimiento")
  telefono            String?
  email               String?
  distrito            String
  esSurco             Boolean   @default(false) @map("es_surco")
  contactoEmergencia  String?   @map("contacto_emergencia")
  telefonoEmergencia  String?   @map("telefono_emergencia")
  activo              Boolean   @default(true)
  createdAt           DateTime  @default(now())
  updatedAt           DateTime  @updatedAt

  // Relaciones familiares
  titularDe           Familia[] @relation("Titular")
  miembroDe           Familia[] @relation("Miembro")

  compras             Compra[]
  consumos            Consumo[]

  @@map("vecinos")
}

model Familia {
  id          Int         @id @default(autoincrement())
  titularDni  String      @map("titular_dni")
  miembroDni  String      @map("miembro_dni")
  parentesco  Parentesco
  createdAt   DateTime    @default(now())

  titular     Vecino      @relation("Titular", fields: [titularDni], references: [dni])
  miembro     Vecino      @relation("Miembro", fields: [miembroDni], references: [dni])

  @@unique([titularDni, miembroDni])
  @@map("familias")
}

enum Parentesco {
  HIJO
  HIJA
  CONYUGE
  OTRO
}

// ─────────────────────────────────────────────────────────
// COMPRAS (Billetera de Horas)
// ─────────────────────────────────────────────────────────

model Compra {
  id          Int           @id @default(autoincrement())
  vecinoDni   String        @map("vecino_dni")
  horas       Int
  monto       Decimal       @db.Decimal(10, 2)
  metodoPago  MetodoPago    @map("metodo_pago")
  referencia  String?       // Para pagos digitales
  anulada     Boolean       @default(false)
  motivoAnul  String?       @map("motivo_anulacion")
  staffId     Int           @map("staff_id")
  cajaId      Int?          @map("caja_id")
  createdAt   DateTime      @default(now())

  vecino      Vecino        @relation(fields: [vecinoDni], references: [dni])
  staff       Staff         @relation(fields: [staffId], references: [id])
  caja        Caja?         @relation(fields: [cajaId], references: [id])

  @@map("compras")
}

enum MetodoPago {
  EFECTIVO
  YAPE
  PLIN
  TRANSFERENCIA
}

// ─────────────────────────────────────────────────────────
// CONSUMOS (Check-in / Check-out)
// ─────────────────────────────────────────────────────────

model Consumo {
  id            Int           @id @default(autoincrement())
  vecinoDni     String        @map("vecino_dni")
  instalacion   Instalacion
  carril        Int?          // Solo para piscinas
  entradaAt     DateTime      @default(now()) @map("entrada_at")
  salidaAt      DateTime?     @map("salida_at")
  salidaAuto    Boolean       @default(false) @map("salida_auto")
  anulado       Boolean       @default(false)
  motivoAnul    String?       @map("motivo_anulacion")
  staffId       Int           @map("staff_id")
  createdAt     DateTime      @default(now())

  vecino        Vecino        @relation(fields: [vecinoDni], references: [dni])
  staff         Staff         @relation(fields: [staffId], references: [id])

  @@map("consumos")
}

enum Instalacion {
  PISCINA_ADULTOS
  PISCINA_NINOS
  PADDLE
  GIMNASIO
  PARRILLAS
}

// ─────────────────────────────────────────────────────────
// CAJA
// ─────────────────────────────────────────────────────────

model Caja {
  id              Int       @id @default(autoincrement())
  fecha           DateTime  @db.Date
  saldoInicial    Decimal   @default(0) @map("saldo_inicial") @db.Decimal(10, 2)
  saldoFinal      Decimal?  @map("saldo_final") @db.Decimal(10, 2)
  saldoDeclarado  Decimal?  @map("saldo_declarado") @db.Decimal(10, 2)
  diferencia      Decimal?  @db.Decimal(10, 2)
  observaciones   String?
  cerradaAt       DateTime? @map("cerrada_at")
  staffId         Int       @map("staff_id")
  createdAt       DateTime  @default(now())

  staff           Staff     @relation(fields: [staffId], references: [id])
  compras         Compra[]

  @@unique([fecha])
  @@map("cajas")
}

// ─────────────────────────────────────────────────────────
// LOG DE AUDITORÍA
// ─────────────────────────────────────────────────────────

model AuditLog {
  id          Int       @id @default(autoincrement())
  entidad     String    // vecinos, compras, consumos, etc.
  entidadId   String    @map("entidad_id")
  accion      String    // CREATE, UPDATE, ANULAR
  datos       Json?     // Snapshot del cambio
  staffId     Int?      @map("staff_id")
  ip          String?
  createdAt   DateTime  @default(now())

  @@map("audit_log")
}
```

---

## 14. Configuración de Tarifas e Instalaciones

```typescript
// src/utils/config.ts

export const TARIFAS = {
  SURCO: {
    1: 5.00,
    4: 18.00,
    8: 32.00,
    12: 42.00,
  },
  OTROS: {
    1: 8.00,
    4: 28.00,
    8: 52.00,
    12: 72.00,
  },
} as const;

export const INSTALACIONES = {
  PISCINA_ADULTOS: {
    nombre: 'Piscina Adultos',
    descripcion: '25 metros',
    carriles: 8,
    icono: '🏊',
    activa: true,
  },
  PISCINA_NINOS: {
    nombre: 'Piscina Niños',
    descripcion: '',
    carriles: 5,
    icono: '🧒',
    activa: true,
  },
  PADDLE: {
    nombre: 'Cancha Paddle',
    descripcion: '',
    carriles: null,
    icono: '🎾',
    activa: true,
  },
  GIMNASIO: {
    nombre: 'Gimnasio',
    descripcion: '',
    carriles: null,
    icono: '💪',
    activa: true,
  },
  PARRILLAS: {
    nombre: 'Zona Parrillas',
    descripcion: '',
    carriles: null,
    icono: '🔥',
    activa: false, // Próximamente
  },
} as const;

export const TIEMPO_LIMITE_HORA = 60; // minutos
export const ALERTA_AMARILLA = 15; // minutos restantes
export const ALERTA_ROJA = 5; // minutos restantes

export function calcularPrecio(horas: number, esSurco: boolean): number {
  const tarifa = esSurco ? TARIFAS.SURCO : TARIFAS.OTROS;
  return tarifa[horas as keyof typeof tarifa] || horas * tarifa[1];
}
```

---

## 15. Estructura del Proyecto

```
surco-deportes/
├── docker-compose.yml
├── .env.example
├── README.md
│
├── backend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile
│   ├── prisma/
│   │   ├── schema.prisma
│   │   ├── seed.ts
│   │   └── migrations/
│   └── src/
│       ├── index.ts
│       ├── app.ts
│       ├── routes/
│       │   ├── index.ts
│       │   ├── auth.routes.ts
│       │   ├── vecinos.routes.ts
│       │   ├── compras.routes.ts
│       │   ├── consumos.routes.ts
│       │   ├── caja.routes.ts
│       │   └── reportes.routes.ts
│       ├── controllers/
│       │   ├── auth.controller.ts
│       │   ├── vecinos.controller.ts
│       │   ├── compras.controller.ts
│       │   ├── consumos.controller.ts
│       │   ├── caja.controller.ts
│       │   └── reportes.controller.ts
│       ├── services/
│       │   ├── vecino.service.ts
│       │   ├── saldo.service.ts
│       │   ├── compra.service.ts
│       │   ├── consumo.service.ts
│       │   ├── caja.service.ts
│       │   └── audit.service.ts
│       ├── middleware/
│       │   ├── auth.middleware.ts
│       │   ├── errorHandler.ts
│       │   └── audit.middleware.ts
│       ├── utils/
│       │   ├── config.ts
│       │   ├── tarifas.ts
│       │   └── validators.ts
│       └── types/
│           └── index.ts
│
└── frontend/
    ├── package.json
    ├── vite.config.ts
    ├── Dockerfile
    ├── index.html
    └── src/
        ├── main.ts
        ├── App.vue
        ├── router/
        │   └── index.ts
        ├── views/
        │   ├── Dashboard.vue
        │   ├── VecinoFicha.vue
        │   ├── Caja.vue
        │   └── Login.vue
        ├── components/
        │   ├── layout/
        │   │   ├── AppHeader.vue
        │   │   └── AppSidebar.vue
        │   ├── dashboard/
        │   │   ├── InstalacionPanel.vue
        │   │   ├── CarrilCard.vue
        │   │   └── AccionesRapidas.vue
        │   ├── vecino/
        │   │   ├── BuscadorDNI.vue
        │   │   ├── VecinoForm.vue
        │   │   ├── SaldoIndicator.vue
        │   │   └── HistorialList.vue
        │   └── modals/
        │       ├── VentaModal.vue
        │       ├── CheckinModal.vue
        │       └── AnularModal.vue
        ├── stores/
        │   ├── auth.ts
        │   ├── dashboard.ts
        │   ├── vecinos.ts
        │   └── caja.ts
        ├── composables/
        │   ├── useApi.ts
        │   └── useTimer.ts
        ├── services/
        │   └── api.ts
        └── assets/
            └── styles/
                └── main.css
```

---

## 16. Docker Compose para Coolify

```yaml
# docker-compose.yml

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${DB_USER:-surco}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME:-surco_deportes}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-surco}"]
      interval: 5s
      timeout: 5s
      retries: 5

  backend:
    build: ./backend
    environment:
      DATABASE_URL: postgresql://${DB_USER:-surco}:${DB_PASSWORD}@postgres:5432/${DB_NAME:-surco_deportes}
      JWT_SECRET: ${JWT_SECRET}
      NODE_ENV: production
    depends_on:
      postgres:
        condition: service_healthy
    labels:
      - "coolify.port=3000"

  frontend:
    build: ./frontend
    environment:
      VITE_API_URL: ${API_URL:-/api}
    labels:
      - "coolify.port=80"

volumes:
  postgres_data:
```

---

## 17. Variables de Entorno

```bash
# .env.example

# Base de datos
DB_USER=surco
DB_PASSWORD=tu_password_seguro
DB_NAME=surco_deportes
DATABASE_URL=postgresql://surco:tu_password_seguro@postgres:5432/surco_deportes

# Autenticación
JWT_SECRET=tu_jwt_secret_muy_largo_y_seguro

# API
API_URL=/api
NODE_ENV=production

# Frontend
VITE_API_URL=/api
```

---

## 18. Auditoría

### Eventos Registrados

| Entidad | Acciones |
|---------|----------|
| Vecinos | CREATE, UPDATE |
| Compras | CREATE, ANULAR |
| Consumos | CHECKIN, CHECKOUT, ANULAR |
| Caja | ABRIR, CERRAR |
| Staff | LOGIN, LOGOUT |

### Campos del Log

- `entidad`: Tabla afectada
- `entidadId`: ID del registro
- `accion`: Tipo de operación
- `datos`: JSON con snapshot del cambio
- `staffId`: Quién realizó la acción
- `ip`: Dirección IP
- `createdAt`: Timestamp

> 📌 **Regla de oro:** Nada se edita, todo deja huella.

---

## 19. Métricas de Éxito MVP

| Métrica | Objetivo |
|---------|----------|
| Tiempo de check-in | < 15 segundos |
| Errores de saldo | 0 conflictos |
| Cierre de caja | Diferencia < 1% |
| Adopción staff | 100% en semana 2 |

---

## 20. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Resistencia del personal | Alta | Alto | Capacitación + simplificación UX |
| Pérdida de conectividad | Media | Alto | Cache local + sync posterior |
| Datos incorrectos migrados | Media | Medio | Período de validación paralela |
| Vecinos sin DNI | Baja | Bajo | Registro temporal con validación |

---

## 21. Cronograma Sugerido

| Semana | Actividad |
|--------|-----------|
| 1 | Setup proyecto + DB + Auth básico |
| 2 | CRUD Vecinos + Búsqueda DNI |
| 3 | Compras + Cálculo de saldo |
| 4 | Check-in/out + Dashboard tiempo real |
| 5 | Caja diaria + Cierre |
| 6 | Testing + Correcciones |
| 7 | Deploy Coolify + Capacitación |
| 8 | Go-live + Soporte |

---

## Anexo A: Checklist de Lanzamiento

- [ ] Base de datos migrada y con seed inicial
- [ ] Staff creado con credenciales
- [ ] Tarifas configuradas
- [ ] Instalaciones activadas
- [ ] Backup automático configurado
- [ ] Capacitación a recepcionistas
- [ ] Manual de usuario entregado
- [ ] Período de prueba paralelo (1 semana)
- [ ] Go-live definitivo

---

## Anexo B: Contactos

| Rol | Nombre | Contacto |
|-----|--------|----------|
| Product Owner | [Por definir] | |
| Desarrollador | [Por definir] | |
| Admin Centro | [Por definir] | |
| Soporte Técnico | [Por definir] | |

---

*Documento generado: Diciembre 2024*  
*Versión: 1.0 MVP*
