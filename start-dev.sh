#!/bin/bash

echo "🏊 Iniciando Sistema Deportivo Municipal - Surco"
echo "=================================================="
echo ""

# Verificar si existe Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi

# Verificar si existe docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose no está instalado. Por favor instala Docker Compose primero."
    exit 1
fi

# Verificar si existe .env
if [ ! -f .env ]; then
    echo "📝 Creando archivo .env..."
    cp .env.example .env
    echo "⚠️  Por favor edita el archivo .env con tus credenciales antes de continuar."
    echo "   Presiona Enter para continuar o Ctrl+C para cancelar..."
    read
fi

echo "🐳 Iniciando servicios con Docker Compose..."
docker-compose up -d

echo ""
echo "⏳ Esperando que la base de datos esté lista..."
sleep 5

echo ""
echo "📦 Ejecutando migraciones de base de datos..."
docker-compose exec backend npx prisma migrate deploy

echo ""
echo "🌱 Ejecutando seed de datos iniciales..."
docker-compose exec backend npm run prisma:seed

echo ""
echo "✅ ¡Sistema iniciado correctamente!"
echo ""
echo "🌐 Accede a la aplicación en:"
echo "   Frontend: http://localhost"
echo "   Backend API: http://localhost:3000"
echo "   PostgreSQL: localhost:5432"
echo ""
echo "👤 Credenciales de prueba:"
echo "   Admin: usuario=admin, password=admin123"
echo "   Recepcionista: usuario=maria.garcia, password=recepcion123"
echo ""
echo "📊 Ver logs:"
echo "   docker-compose logs -f"
echo ""
echo "🛑 Detener servicios:"
echo "   docker-compose down"
echo ""
