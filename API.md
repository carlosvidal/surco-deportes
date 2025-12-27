# Documentación de la API

Base URL: `http://localhost:3000/api`

## Autenticación

Todos los endpoints excepto `/auth/login` requieren un token JWT en el header:
```
Authorization: Bearer <token>
```

### POST /auth/login
Iniciar sesión y obtener token.

**Request:**
```json
{
  "usuario": "admin",
  "password": "admin123"
}
```

**Response 200:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "staff": {
    "id": 1,
    "nombre": "Administrador Municipal",
    "usuario": "admin",
    "rol": "ADMIN_MUNICIPAL"
  }
}
```

### GET /auth/verify
Verificar si el token actual es válido.

**Response 200:**
```json
{
  "staff": {
    "id": 1,
    "nombre": "Administrador Municipal",
    "usuario": "admin",
    "rol": "ADMIN_MUNICIPAL",
    "activo": true
  }
}
```

---

## Vecinos

### GET /vecinos/:dni
Buscar vecino por DNI (incluye saldo calculado).

**Response 200:**
```json
{
  "dni": "12345678",
  "nombre": "Carlos",
  "apellidos": "Mendoza Torres",
  "telefono": "999888777",
  "email": "carlos@example.com",
  "distrito": "Santiago de Surco",
  "esSurco": true,
  "contactoEmergencia": "Ana Mendoza",
  "telefonoEmergencia": "987654321",
  "saldo": 6,
  "horasCompradas": 12,
  "horasConsumidas": 6
}
```

**Response 404:**
```json
{
  "error": "Vecino no encontrado"
}
```

### POST /vecinos
Registrar nuevo vecino.

**Request:**
```json
{
  "dni": "12345678",
  "nombre": "Carlos",
  "apellidos": "Mendoza Torres",
  "telefono": "999888777",
  "email": "carlos@example.com",
  "distrito": "Santiago de Surco",
  "esSurco": true,
  "contactoEmergencia": "Ana Mendoza",
  "telefonoEmergencia": "987654321"
}
```

**Response 201:**
```json
{
  "dni": "12345678",
  "nombre": "Carlos",
  "apellidos": "Mendoza Torres",
  "activo": true,
  "createdAt": "2024-12-23T10:00:00.000Z",
  ...
}
```

### PUT /vecinos/:dni
Actualizar datos de un vecino.

**Request:**
```json
{
  "telefono": "999777666",
  "email": "nuevo@email.com"
}
```

### GET /vecinos/:dni/historial
Obtener historial completo de compras y consumos.

**Response 200:**
```json
{
  "compras": [
    {
      "id": 1,
      "horas": 4,
      "monto": "18.00",
      "metodoPago": "EFECTIVO",
      "createdAt": "2024-12-23T10:00:00.000Z",
      "staff": {
        "nombre": "María García"
      }
    }
  ],
  "consumos": [
    {
      "id": 1,
      "instalacion": "PISCINA_ADULTOS",
      "carril": 3,
      "entradaAt": "2024-12-23T11:00:00.000Z",
      "salidaAt": "2024-12-23T12:00:00.000Z",
      "staff": {
        "nombre": "María García"
      }
    }
  ]
}
```

### GET /vecinos/buscar?q=carlos
Buscar vecinos por nombre, apellido o DNI.

**Response 200:**
```json
[
  {
    "dni": "12345678",
    "nombre": "Carlos",
    "apellidos": "Mendoza Torres",
    "distrito": "Santiago de Surco",
    "esSurco": true
  }
]
```

### GET /vecinos/:dni/familia
Obtener información familiar del vecino.

**Response 200:**
```json
{
  "dependientes": [
    {
      "id": 1,
      "parentesco": "HIJO",
      "miembro": {
        "dni": "87654321",
        "nombre": "Juanito",
        "apellidos": "Mendoza López"
      }
    }
  ],
  "titular": null
}
```

---

## Consumos (Check-in / Check-out)

### POST /consumos/checkin
Registrar entrada a una instalación.

**Request:**
```json
{
  "vecinoDni": "12345678",
  "instalacion": "PISCINA_ADULTOS",
  "carril": 3
}
```

**Instalaciones válidas:**
- `PISCINA_ADULTOS`
- `PISCINA_NINOS`
- `PADDLE`
- `GIMNASIO`
- `PARRILLAS`

**Response 201:**
```json
{
  "id": 1,
  "vecinoDni": "12345678",
  "instalacion": "PISCINA_ADULTOS",
  "carril": 3,
  "entradaAt": "2024-12-23T11:00:00.000Z",
  "salidaAt": null,
  "vecino": {
    "nombre": "Carlos",
    "apellidos": "Mendoza Torres"
  }
}
```

**Response 400:**
```json
{
  "error": "El vecino no tiene saldo suficiente"
}
```

Otros errores:
- "El vecino ya tiene un consumo activo"
- "El carril está ocupado"

### PUT /consumos/:id/checkout
Registrar salida de una instalación.

**Response 200:**
```json
{
  "id": 1,
  "vecinoDni": "12345678",
  "instalacion": "PISCINA_ADULTOS",
  "carril": 3,
  "entradaAt": "2024-12-23T11:00:00.000Z",
  "salidaAt": "2024-12-23T12:00:00.000Z",
  "salidaAuto": false
}
```

### POST /consumos/:id/anular
Anular un consumo (devuelve la hora al vecino).

**Request:**
```json
{
  "motivo": "Consumo registrado por error"
}
```

**Response 200:**
```json
{
  "id": 1,
  "anulado": true,
  "motivoAnul": "Consumo registrado por error",
  ...
}
```

### GET /consumos/activos
Obtener todos los consumos activos (sin salida).

**Response 200:**
```json
[
  {
    "id": 1,
    "vecinoDni": "12345678",
    "vecino": {
      "nombre": "Carlos",
      "apellidos": "Mendoza Torres"
    },
    "instalacion": "PISCINA_ADULTOS",
    "carril": 3,
    "entradaAt": "2024-12-23T11:00:00.000Z",
    "tiempoTranscurrido": 45,
    "tiempoRestante": 15
  }
]
```

### GET /consumos/activos/:instalacion
Obtener consumos activos de una instalación específica.

**Response 200:**
```json
[
  {
    "id": 1,
    "vecinoDni": "12345678",
    "vecino": {
      "nombre": "Carlos",
      "apellidos": "Mendoza Torres"
    },
    "instalacion": "PISCINA_ADULTOS",
    "carril": 3,
    "tiempoTranscurrido": 45,
    "tiempoRestante": 15
  }
]
```

### POST /consumos/cerrar-vencidos
Cerrar automáticamente los consumos que excedieron 60 minutos.

**Response 200:**
```json
{
  "message": "Se cerraron 3 consumos",
  "cerrados": [...]
}
```

---

## Health Check

### GET /health
Verificar estado del servidor.

**Response 200:**
```json
{
  "status": "ok",
  "timestamp": "2024-12-23T12:00:00.000Z"
}
```

---

## Códigos de Estado HTTP

- `200` - OK
- `201` - Created
- `400` - Bad Request (error en los datos enviados)
- `401` - Unauthorized (no autenticado o token inválido)
- `403` - Forbidden (no tiene permisos)
- `404` - Not Found
- `500` - Internal Server Error

---

## Ejemplo de Uso con cURL

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usuario":"admin","password":"admin123"}'
```

### Buscar Vecino
```bash
curl http://localhost:3000/api/vecinos/12345678 \
  -H "Authorization: Bearer <tu-token>"
```

### Check-in
```bash
curl -X POST http://localhost:3000/api/consumos/checkin \
  -H "Authorization: Bearer <tu-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "vecinoDni": "12345678",
    "instalacion": "PISCINA_ADULTOS",
    "carril": 3
  }'
```

---

## Próximos Endpoints (Pendientes)

### Compras
- `POST /compras` - Registrar venta de paquete
- `GET /compras/:id` - Detalle de compra
- `POST /compras/:id/anular` - Anular compra

### Caja
- `POST /caja/abrir` - Abrir caja del día
- `GET /caja/hoy` - Resumen de caja actual
- `POST /caja/cerrar` - Cerrar caja
- `GET /caja/:fecha` - Consultar caja de fecha específica

### Reportes
- `GET /reportes/ventas` - Reporte de ventas
- `GET /reportes/ocupacion` - Reporte de ocupación
- `GET /reportes/auditoria` - Log de auditoría

---

**Última actualización:** Diciembre 2024
