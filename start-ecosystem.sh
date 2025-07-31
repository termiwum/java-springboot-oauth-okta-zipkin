#!/bin/bash

# 🚀 Script de Automatización - Ecosistema de Microservicios Docker
# Este script automatiza el proceso completo de levantamiento del ecosistema

echo "🐳 Iniciando configuración del ecosistema de microservicios..."

# Función para verificar si Docker está corriendo
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Error: Docker no está corriendo. Inicia Docker Desktop y vuelve a intentar."
        exit 1
    fi
    echo "✅ Docker está corriendo"
}

# Función para crear la red
create_network() {
    echo "🌐 Creando red de microservicios..."
    docker network create microservices-network 2>/dev/null || echo "ℹ️  Red ya existe"
    echo "✅ Red 'microservices-network' lista"
}

# Función para levantar infraestructura
setup_infrastructure() {
    echo "📊 Levantando servicios de infraestructura..."
    
    # Redis
    echo "🔄 Iniciando Redis..."
    docker run -d --name redis --network microservices-network \
        -p 6379:6379 \
        redis:alpine 2>/dev/null || echo "ℹ️  Redis ya está corriendo"
    
    # Zipkin
    echo "🔄 Iniciando Zipkin..."
    docker run -d --name zipkin --network microservices-network \
        -p 9411:9411 \
        openzipkin/zipkin 2>/dev/null || echo "ℹ️  Zipkin ya está corriendo"
    
    echo "✅ Infraestructura lista"
}

# Función para levantar bases de datos MySQL
setup_databases() {
    echo "🗄️  Levantando bases de datos MySQL..."
    
    # MySQL Product
    echo "🔄 Iniciando MySQL Product..."
    docker run -d --name mysql-product --network microservices-network \
        -e MYSQL_ROOT_PASSWORD=admin \
        -e MYSQL_DATABASE=product_db \
        -e MYSQL_USER=admin \
        -e MYSQL_PASSWORD=admin \
        -p 3307:3306 \
        mysql:8.0 2>/dev/null || echo "ℹ️  MySQL Product ya está corriendo"
    
    # MySQL Payment
    echo "🔄 Iniciando MySQL Payment..."
    docker run -d --name mysql-payment --network microservices-network \
        -e MYSQL_ROOT_PASSWORD=admin \
        -e MYSQL_DATABASE=payment_db \
        -e MYSQL_USER=admin \
        -e MYSQL_PASSWORD=admin \
        -p 3308:3306 \
        mysql:8.0 2>/dev/null || echo "ℹ️  MySQL Payment ya está corriendo"
    
    # MySQL Order
    echo "🔄 Iniciando MySQL Order..."
    docker run -d --name mysql-order --network microservices-network \
        -e MYSQL_ROOT_PASSWORD=admin \
        -e MYSQL_DATABASE=order_db \
        -e MYSQL_USER=admin \
        -e MYSQL_PASSWORD=admin \
        -p 3309:3306 \
        mysql:8.0 2>/dev/null || echo "ℹ️  MySQL Order ya está corriendo"
    
    echo "✅ Bases de datos listas"
}

# Función para construir imágenes
build_images() {
    echo "🏗️  Construyendo imágenes de microservicios..."
    
    services=("service-registry" "config-server" "product-service" "payment-service" "order-service" "cloud-gateway")
    
    for service in "${services[@]}"; do
        echo "🔨 Construyendo $service..."
        cd "$service"
        ./mvnw clean package -DskipTests -q
        docker build -t "$service" . -q
        cd ..
        echo "✅ $service construido"
    done
    
    echo "✅ Todas las imágenes construidas"
}

# Función para levantar microservicios
start_microservices() {
    echo "🚀 Iniciando microservicios..."
    
    # Service Registry
    echo "🔄 Iniciando Service Registry (Eureka)..."
    docker run -d --name service-registry --network microservices-network \
        -p 8761:8761 \
        service-registry 2>/dev/null || echo "ℹ️  Service Registry ya está corriendo"
    
    echo "⏳ Esperando que Eureka esté listo (30 segundos)..."
    sleep 30
    
    # Config Server
    echo "🔄 Iniciando Config Server..."
    docker run -d --name config-server --network microservices-network \
        -p 9296:9296 \
        -e EUREKA_HOST=service-registry \
        config-server 2>/dev/null || echo "ℹ️  Config Server ya está corriendo"
    
    echo "⏳ Esperando que Config Server esté listo (20 segundos)..."
    sleep 20
    
    # Product Service
    echo "🔄 Iniciando Product Service..."
    docker run -d --name product-service --network microservices-network \
        -e EUREKA_HOST=service-registry \
        -e CONFIG_SERVER_HOST=config-server \
        -e ZIPKIN_HOST=zipkin \
        -e DB_HOST=mysql-product \
        product-service 2>/dev/null || echo "ℹ️  Product Service ya está corriendo"
    
    # Payment Service
    echo "🔄 Iniciando Payment Service..."
    docker run -d --name payment-service --network microservices-network \
        -e EUREKA_HOST=service-registry \
        -e CONFIG_SERVER_HOST=config-server \
        -e ZIPKIN_HOST=zipkin \
        -e DB_HOST=mysql-payment \
        payment-service 2>/dev/null || echo "ℹ️  Payment Service ya está corriendo"
    
    # Order Service
    echo "🔄 Iniciando Order Service..."
    docker run -d --name order-service --network microservices-network \
        -e EUREKA_HOST=service-registry \
        -e CONFIG_SERVER_HOST=config-server \
        -e ZIPKIN_HOST=zipkin \
        -e DB_HOST=mysql-order \
        order-service 2>/dev/null || echo "ℹ️  Order Service ya está corriendo"
    
    echo "⏳ Esperando que servicios de negocio estén listos (30 segundos)..."
    sleep 30
    
    # Cloud Gateway
    echo "🔄 Iniciando API Gateway..."
    docker run -d --name cloud-gateway --network microservices-network \
        -p 9090:9090 \
        -e EUREKA_HOST=service-registry \
        -e CONFIG_SERVER_HOST=config-server \
        -e ZIPKIN_HOST=zipkin \
        cloud-gateway 2>/dev/null || echo "ℹ️  Cloud Gateway ya está corriendo"
    
    echo "✅ Todos los microservicios iniciados"
}

# Función para verificar el estado
verify_ecosystem() {
    echo "🔍 Verificando estado del ecosistema..."
    
    echo ""
    echo "📊 Estado de contenedores:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "network=microservices-network"
    
    echo ""
    echo "🌐 URLs de acceso:"
    echo "  • Eureka Dashboard: http://localhost:8761"
    echo "  • Config Server: http://localhost:9296"
    echo "  • API Gateway: http://localhost:9090"
    echo "  • Zipkin UI: http://localhost:9411"
    
    echo ""
    echo "⏳ Esperando que todos los servicios se registren en Eureka (60 segundos)..."
    sleep 60
    
    echo ""
    echo "🎉 ¡Ecosistema completamente operativo!"
    echo "📋 Verifica el registro de servicios en: http://localhost:8761"
}

# Función principal
main() {
    echo "🎯 Iniciando configuración completa del ecosistema..."
    echo ""
    
    check_docker
    create_network
    setup_infrastructure
    setup_databases
    build_images
    start_microservices
    verify_ecosystem
    
    echo ""
    echo "🎉 ¡Configuración completada exitosamente!"
    echo "🚀 El ecosistema está listo para usar en: http://localhost:9090"
}

# Función para limpiar el entorno
cleanup() {
    echo "🧹 Limpiando entorno Docker..."
    
    # Detener contenedores
    echo "🛑 Deteniendo contenedores..."
    docker stop $(docker ps -q --filter "network=microservices-network") 2>/dev/null || echo "No hay contenedores corriendo"
    
    # Eliminar contenedores
    echo "🗑️  Eliminando contenedores..."
    docker rm $(docker ps -aq --filter "network=microservices-network") 2>/dev/null || echo "No hay contenedores para eliminar"
    
    # Eliminar red
    echo "🌐 Eliminando red..."
    docker network rm microservices-network 2>/dev/null || echo "Red no existe"
    
    echo "✅ Limpieza completada"
}

# Verificar argumentos
case "${1:-}" in
    "start"|"")
        main
        ;;
    "cleanup"|"clean")
        cleanup
        ;;
    "help"|"-h"|"--help")
        echo "Uso: $0 [start|cleanup|help]"
        echo ""
        echo "Comandos:"
        echo "  start    - Inicia el ecosistema completo (por defecto)"
        echo "  cleanup  - Limpia todo el entorno Docker"
        echo "  help     - Muestra esta ayuda"
        ;;
    *)
        echo "❌ Comando no reconocido: $1"
        echo "Usa '$0 help' para ver los comandos disponibles"
        exit 1
        ;;
esac
