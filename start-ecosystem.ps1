# 🚀 Script de Automatización PowerShell - Ecosistema de Microservicios Docker
# Este script automatiza el proceso completo de levantamiento del ecosistema en Windows

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "cleanup", "help", "")]
    [string]$Action = "start"
)

# Función para verificar si Docker está corriendo
function Test-Docker {
    Write-Host "🐳 Verificando Docker..." -ForegroundColor Cyan
    try {
        docker info *>$null
        Write-Host "✅ Docker está corriendo" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Error: Docker no está corriendo. Inicia Docker Desktop y vuelve a intentar." -ForegroundColor Red
        exit 1
    }
}

# Función para crear la red
function New-MicroservicesNetwork {
    Write-Host "🌐 Creando red de microservicios..." -ForegroundColor Cyan
    docker network create microservices-network 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Red 'microservices-network' creada" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Red 'microservices-network' ya existe" -ForegroundColor Yellow
    }
}

# Función para levantar infraestructura
function Start-Infrastructure {
    Write-Host "📊 Levantando servicios de infraestructura..." -ForegroundColor Cyan
    
    # Redis
    Write-Host "🔄 Iniciando Redis..." -ForegroundColor Yellow
    docker run -d --name redis --network microservices-network -p 6379:6379 redis:alpine 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Redis iniciado" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Redis ya está corriendo" -ForegroundColor Yellow
    }
    
    # Zipkin
    Write-Host "🔄 Iniciando Zipkin..." -ForegroundColor Yellow
    docker run -d --name zipkin --network microservices-network -p 9411:9411 openzipkin/zipkin 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Zipkin iniciado" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Zipkin ya está corriendo" -ForegroundColor Yellow
    }
    
    Write-Host "✅ Infraestructura lista" -ForegroundColor Green
}

# Función para levantar bases de datos MySQL
function Start-Databases {
    Write-Host "🗄️  Levantando bases de datos MySQL..." -ForegroundColor Cyan
    
    $databases = @(
        @{ Name = "mysql-product"; Port = 3307; DB = "product_db" },
        @{ Name = "mysql-payment"; Port = 3308; DB = "payment_db" },
        @{ Name = "mysql-order"; Port = 3309; DB = "order_db" }
    )
    
    foreach ($db in $databases) {
        Write-Host "🔄 Iniciando $($db.Name)..." -ForegroundColor Yellow
        docker run -d --name $($db.Name) --network microservices-network `
            -e MYSQL_ROOT_PASSWORD=admin `
            -e MYSQL_DATABASE=$($db.DB) `
            -e MYSQL_USER=admin `
            -e MYSQL_PASSWORD=admin `
            -p "$($db.Port):3306" `
            mysql:8.0 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $($db.Name) iniciado en puerto $($db.Port)" -ForegroundColor Green
        } else {
            Write-Host "ℹ️  $($db.Name) ya está corriendo" -ForegroundColor Yellow
        }
    }
    
    Write-Host "✅ Bases de datos listas" -ForegroundColor Green
}

# Función para construir imágenes
function Build-MicroserviceImages {
    Write-Host "🏗️  Construyendo imágenes de microservicios..." -ForegroundColor Cyan
    
    $services = @("service-registry", "config-server", "product-service", "payment-service", "order-service", "cloud-gateway")
    
    foreach ($service in $services) {
        Write-Host "🔨 Construyendo $service..." -ForegroundColor Yellow
        Push-Location $service
        
        # Maven build
        .\mvnw.cmd clean package -DskipTests -q
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Error al construir $service" -ForegroundColor Red
            Pop-Location
            continue
        }
        
        # Docker build
        docker build -t $service . -q
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $service construido exitosamente" -ForegroundColor Green
        } else {
            Write-Host "❌ Error al crear imagen Docker de $service" -ForegroundColor Red
        }
        
        Pop-Location
    }
    
    Write-Host "✅ Construcción de imágenes completada" -ForegroundColor Green
}

# Función para levantar microservicios
function Start-Microservices {
    Write-Host "🚀 Iniciando microservicios..." -ForegroundColor Cyan
    
    # Service Registry
    Write-Host "🔄 Iniciando Service Registry (Eureka)..." -ForegroundColor Yellow
    docker run -d --name service-registry --network microservices-network -p 8761:8761 service-registry 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Service Registry iniciado" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Service Registry ya está corriendo" -ForegroundColor Yellow
    }
    
    Write-Host "⏳ Esperando que Eureka esté listo (30 segundos)..." -ForegroundColor Yellow
    Start-Sleep 30
    
    # Config Server
    Write-Host "🔄 Iniciando Config Server..." -ForegroundColor Yellow
    docker run -d --name config-server --network microservices-network `
        -p 9296:9296 `
        -e EUREKA_HOST=service-registry `
        config-server 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Config Server iniciado" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Config Server ya está corriendo" -ForegroundColor Yellow
    }
    
    Write-Host "⏳ Esperando que Config Server esté listo (20 segundos)..." -ForegroundColor Yellow
    Start-Sleep 20
    
    # Servicios de Negocio
    $businessServices = @(
        @{ Name = "product-service"; DB = "mysql-product" },
        @{ Name = "payment-service"; DB = "mysql-payment" },
        @{ Name = "order-service"; DB = "mysql-order" }
    )
    
    foreach ($service in $businessServices) {
        Write-Host "🔄 Iniciando $($service.Name)..." -ForegroundColor Yellow
        docker run -d --name $($service.Name) --network microservices-network `
            -e EUREKA_HOST=service-registry `
            -e CONFIG_SERVER_HOST=config-server `
            -e ZIPKIN_HOST=zipkin `
            -e DB_HOST=$($service.DB) `
            $($service.Name) 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $($service.Name) iniciado" -ForegroundColor Green
        } else {
            Write-Host "ℹ️  $($service.Name) ya está corriendo" -ForegroundColor Yellow
        }
    }
    
    Write-Host "⏳ Esperando que servicios de negocio estén listos (30 segundos)..." -ForegroundColor Yellow
    Start-Sleep 30
    
    # Cloud Gateway
    Write-Host "🔄 Iniciando API Gateway..." -ForegroundColor Yellow
    docker run -d --name cloud-gateway --network microservices-network `
        -p 9090:9090 `
        -e EUREKA_HOST=service-registry `
        -e CONFIG_SERVER_HOST=config-server `
        -e ZIPKIN_HOST=zipkin `
        cloud-gateway 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ API Gateway iniciado" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  API Gateway ya está corriendo" -ForegroundColor Yellow
    }
    
    Write-Host "✅ Todos los microservicios iniciados" -ForegroundColor Green
}

# Función para verificar el estado
function Test-Ecosystem {
    Write-Host "🔍 Verificando estado del ecosistema..." -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "📊 Estado de contenedores:" -ForegroundColor Cyan
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "network=microservices-network"
    
    Write-Host ""
    Write-Host "🌐 URLs de acceso:" -ForegroundColor Cyan
    Write-Host "  • Eureka Dashboard: http://localhost:8761" -ForegroundColor White
    Write-Host "  • Config Server: http://localhost:9296" -ForegroundColor White
    Write-Host "  • API Gateway: http://localhost:9090" -ForegroundColor White
    Write-Host "  • Zipkin UI: http://localhost:9411" -ForegroundColor White
    
    Write-Host ""
    Write-Host "⏳ Esperando que todos los servicios se registren en Eureka (60 segundos)..." -ForegroundColor Yellow
    Start-Sleep 60
    
    Write-Host ""
    Write-Host "🎉 ¡Ecosistema completamente operativo!" -ForegroundColor Green
    Write-Host "📋 Verifica el registro de servicios en: http://localhost:8761" -ForegroundColor Cyan
}

# Función principal
function Start-Ecosystem {
    Write-Host "🎯 Iniciando configuración completa del ecosistema..." -ForegroundColor Magenta
    Write-Host ""
    
    Test-Docker
    New-MicroservicesNetwork
    Start-Infrastructure
    Start-Databases
    Build-MicroserviceImages
    Start-Microservices
    Test-Ecosystem
    
    Write-Host ""
    Write-Host "🎉 ¡Configuración completada exitosamente!" -ForegroundColor Green
    Write-Host "🚀 El ecosistema está listo para usar en: http://localhost:9090" -ForegroundColor Cyan
}

# Función para limpiar el entorno
function Remove-Ecosystem {
    Write-Host "🧹 Limpiando entorno Docker..." -ForegroundColor Cyan
    
    # Obtener contenedores de la red
    $containers = docker ps -aq --filter "network=microservices-network" 2>$null
    
    if ($containers) {
        # Detener contenedores
        Write-Host "🛑 Deteniendo contenedores..." -ForegroundColor Yellow
        docker stop $containers 2>$null
        
        # Eliminar contenedores
        Write-Host "🗑️  Eliminando contenedores..." -ForegroundColor Yellow
        docker rm $containers 2>$null
    } else {
        Write-Host "ℹ️  No hay contenedores para eliminar" -ForegroundColor Yellow
    }
    
    # Eliminar red
    Write-Host "🌐 Eliminando red..." -ForegroundColor Yellow
    docker network rm microservices-network 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Red eliminada" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Red no existe" -ForegroundColor Yellow
    }
    
    Write-Host "✅ Limpieza completada" -ForegroundColor Green
}

# Función de ayuda
function Show-Help {
    Write-Host "🚀 Script de Automatización - Ecosistema de Microservicios" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Uso: .\start-ecosystem.ps1 [start|cleanup|help]" -ForegroundColor White
    Write-Host ""
    Write-Host "Comandos:" -ForegroundColor Cyan
    Write-Host "  start    - Inicia el ecosistema completo (por defecto)" -ForegroundColor White
    Write-Host "  cleanup  - Limpia todo el entorno Docker" -ForegroundColor White
    Write-Host "  help     - Muestra esta ayuda" -ForegroundColor White
    Write-Host ""
    Write-Host "Ejemplos:" -ForegroundColor Cyan
    Write-Host "  .\start-ecosystem.ps1" -ForegroundColor Gray
    Write-Host "  .\start-ecosystem.ps1 start" -ForegroundColor Gray
    Write-Host "  .\start-ecosystem.ps1 cleanup" -ForegroundColor Gray
}

# Ejecutar según el parámetro
switch ($Action.ToLower()) {
    "start" { Start-Ecosystem }
    "" { Start-Ecosystem }
    "cleanup" { Remove-Ecosystem }
    "help" { Show-Help }
    default {
        Write-Host "❌ Comando no reconocido: $Action" -ForegroundColor Red
        Write-Host "Usa '.\start-ecosystem.ps1 help' para ver los comandos disponibles" -ForegroundColor Yellow
        exit 1
    }
}
