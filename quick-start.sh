#!/bin/bash

# Script optimizado de arranque completo del ecosistema
# Optimizaciones aplicadas para reducir tiempos de inicio

echo "🚀 Iniciando ecosistema de microservicios optimizado..."

# Fase 1: Construir en paralelo todas las imágenes (aprovecha múltiples cores)
echo "⚡ Fase 1: Construyendo imágenes en paralelo..."
start_time=$(date +%s)

# Construir imágenes en paralelo para acelerar el proceso
docker-compose build --parallel --no-cache

build_time=$(date +%s)
echo "✅ Imágenes construidas en $((build_time - start_time)) segundos"

# Fase 2: Iniciar infraestructura básica
echo "🏗️  Fase 2: Iniciando infraestructura básica..."
docker-compose up -d redis zipkin mysql-product mysql-payment mysql-order

# Esperar a que las bases de datos estén listas
echo "⏳ Esperando bases de datos..."
timeout=60
while [ $timeout -gt 0 ]; do
  if docker-compose ps | grep -E "(mysql.*healthy|redis.*healthy|zipkin.*healthy)" | wc -l | grep -q "4"; then
    break
  fi
  echo "⏱️  Esperando infraestructura... ${timeout}s restantes"
  sleep 5
  timeout=$((timeout - 5))
done

# Fase 3: Iniciar servicios core (con dependencias relajadas)
echo "🎯 Fase 3: Iniciando servicios core..."
docker-compose up -d service-registry
sleep 15  # Dar tiempo al service registry

docker-compose up -d config-server
sleep 10  # Dar tiempo al config server

# Fase 4: Iniciar servicios de negocio en paralelo
echo "💼 Fase 4: Iniciando servicios de negocio..."
docker-compose up -d product-service payment-service order-service

# Fase 5: Iniciar API Gateway
echo "🌐 Fase 5: Iniciando API Gateway..."
sleep 20  # Esperar a que los servicios se registren
docker-compose up -d cloud-gateway

end_time=$(date +%s)
total_time=$((end_time - start_time))

echo ""
echo "🎉 ¡Ecosistema iniciado!"
echo "⏱️  Tiempo total: ${total_time} segundos"
echo ""
echo "🌐 URLs disponibles:"
echo "  • Eureka Dashboard: http://localhost:8761"
echo "  • API Gateway:      http://localhost:9090"
echo "  • Config Server:    http://localhost:9296"
echo "  • Zipkin Tracing:   http://localhost:9411"
echo ""
echo "📊 Estado de servicios:"
docker-compose ps
