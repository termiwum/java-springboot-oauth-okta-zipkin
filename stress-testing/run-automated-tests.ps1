# Script de Test Automatizado del Ecosistema de Microservicios
# Ejecuta todos los tests de manera secuencial o paralela

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("sequential", "parallel", "global", "individual")]
    [string]$Mode = "sequential",
    
    [Parameter(Mandatory=$false)]
    [int]$Duration = 5,  # Duración en minutos por test
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipSetup
)

Write-Host "🚀 Iniciando Test Automatizado del Ecosistema de Microservicios" -ForegroundColor Green
Write-Host "📊 Modo: $Mode | Duración: $Duration minutos por test" -ForegroundColor Cyan

# Verificar prerrequisitos
if (-not $SkipSetup) {
    Write-Host "`n🔍 Verificando prerrequisitos..." -ForegroundColor Yellow
    
    # Verificar que Docker esté corriendo
    try {
        docker ps | Out-Null
        Write-Host "✅ Docker está funcionando" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker no está disponible. Inicia Docker Desktop." -ForegroundColor Red
        exit 1
    }
    
    # Verificar que el stack de monitoreo esté corriendo
    $monitoringServices = @("influxdb", "grafana")
    foreach ($service in $monitoringServices) {
        $running = docker ps --filter "name=$service" --format "table {{.Names}}" | Select-String $service
        if ($running) {
            Write-Host "✅ $service está corriendo" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $service no está corriendo. Iniciando stack de monitoreo..." -ForegroundColor Yellow
            docker-compose -f stress-testing/docker-compose-monitoring.yml up -d
            Start-Sleep 10
            break
        }
    }
    
    # Verificar que los servicios principales estén corriendo
    $mainServices = @(
        @{name="cloud-gateway"; port=9090},
        @{name="service-registry"; port=8761},
        @{name="config-server"; port=8888}
    )
    
    foreach ($service in $mainServices) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$($service.port)/actuator/health" -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ $($service.name) está disponible en puerto $($service.port)" -ForegroundColor Green
            }
        } catch {
            Write-Host "❌ $($service.name) no está disponible en puerto $($service.port)" -ForegroundColor Red
            Write-Host "   Asegúrate de que el stack principal esté corriendo" -ForegroundColor Yellow
        }
    }
}

# Configurar variables de entorno para K6
$env:K6_OUT = "influxdb=http://localhost:8086/stress-testing-token"
$env:K6_INFLUXDB_ORGANIZATION = "stress-testing"
$env:K6_INFLUXDB_BUCKET = "k6-metrics"

# Definir tests disponibles
$tests = @(
    @{
        name = "Order Place Test"
        file = "order-place-test.js"
        description = "Test de creación de pedidos con comunicación Order->Product->Payment"
        dashboard = "order-place-dashboard.json"
    },
    @{
        name = "Order Details Test"
        file = "order-details-test.js"
        description = "Test de consulta de detalles con comunicación Order->Product+Payment"
        dashboard = "order-details-dashboard.json"
    },
    @{
        name = "Payment Service Test"
        file = "payment-service-test.js"
        description = "Test completo del servicio de pagos"
        dashboard = "payment-service-dashboard.json"
    },
    @{
        name = "Product Service Test"
        file = "product-service-test.js"
        description = "Test completo del servicio de productos"
        dashboard = "product-service-dashboard.json"
    },
    @{
        name = "Ecosystem Global Test"
        file = "ecosystem-global-test.js"
        description = "Test global del ecosistema completo"
        dashboard = "ecosystem-global-dashboard.json"
    }
)

function Start-K6Test {
    param(
        [string]$TestFile,
        [string]$TestName,
        [string]$Description,
        [int]$DurationMinutes = 5
    )
    
    Write-Host "`n🔥 Ejecutando: $TestName" -ForegroundColor Magenta
    Write-Host "📝 $Description" -ForegroundColor Gray
    
    $testPath = "stress-testing/k6-scripts/$TestFile"
    
    if (-not (Test-Path $testPath)) {
        Write-Host "❌ Archivo de test no encontrado: $testPath" -ForegroundColor Red
        return $false
    }
    
    try {
        # Ejecutar K6 con configuración específica
        $startTime = Get-Date
        k6 run --duration="${DurationMinutes}m" --vus=20 $testPath
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Write-Host "✅ $TestName completado en $($duration.TotalMinutes.ToString('F1')) minutos" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Error ejecutando $TestName : $_" -ForegroundColor Red
        return $false
    }
}

function Start-ParallelTests {
    Write-Host "`n🚀 Ejecutando tests en paralelo..." -ForegroundColor Cyan
    
    $jobs = @()
    
    # Ejecutar tests individuales en paralelo (excepto el global)
    $individualTests = $tests | Where-Object { $_.file -ne "ecosystem-global-test.js" }
    
    foreach ($test in $individualTests) {
        $job = Start-Job -ScriptBlock {
            param($testFile, $testName, $duration)
            
            $env:K6_OUT = "influxdb=http://localhost:8086/stress-testing-token"
            $env:K6_INFLUXDB_ORGANIZATION = "stress-testing" 
            $env:K6_INFLUXDB_BUCKET = "k6-metrics"
            
            k6 run --duration="${duration}m" --vus=15 "stress-testing/k6-scripts/$testFile"
        } -ArgumentList $test.file, $test.name, $Duration
        
        $jobs += @{Job = $job; Name = $test.name}
        Write-Host "🔄 Iniciado job para: $($test.name)" -ForegroundColor Yellow
    }
    
    # Esperar a que todos los jobs terminen
    Write-Host "`n⏳ Esperando a que terminen todos los tests paralelos..." -ForegroundColor Yellow
    
    foreach ($jobInfo in $jobs) {
        Wait-Job $jobInfo.Job | Out-Null
        $result = Receive-Job $jobInfo.Job
        Remove-Job $jobInfo.Job
        
        Write-Host "✅ $($jobInfo.Name) terminado" -ForegroundColor Green
    }
    
    Write-Host "`n🎉 Todos los tests paralelos completados" -ForegroundColor Green
}

# Ejecutar según el modo seleccionado
switch ($Mode) {
    "sequential" {
        Write-Host "`n📋 Ejecutando tests secuencialmente..." -ForegroundColor Cyan
        
        $results = @()
        foreach ($test in $tests) {
            $success = Start-K6Test -TestFile $test.file -TestName $test.name -Description $test.description -DurationMinutes $Duration
            $results += @{Test = $test.name; Success = $success}
            
            if ($success) {
                Write-Host "⏳ Pausa de 30 segundos antes del siguiente test..." -ForegroundColor Yellow
                Start-Sleep 30
            }
        }
        
        # Mostrar resumen
        Write-Host "`n📊 RESUMEN DE RESULTADOS:" -ForegroundColor Cyan
        foreach ($result in $results) {
            $status = if ($result.Success) { "✅ ÉXITO" } else { "❌ ERROR" }
            Write-Host "   $($result.Test): $status"
        }
    }
    
    "parallel" {
        Start-ParallelTests
    }
    
    "global" {
        Write-Host "`n🌐 Ejecutando solo test global del ecosistema..." -ForegroundColor Cyan
        $globalTest = $tests | Where-Object { $_.file -eq "ecosystem-global-test.js" }
        Start-K6Test -TestFile $globalTest.file -TestName $globalTest.name -Description $globalTest.description -DurationMinutes ($Duration * 2)
    }
    
    "individual" {
        Write-Host "`n🎯 Selecciona el test a ejecutar:" -ForegroundColor Cyan
        
        for ($i = 0; $i -lt $tests.Count; $i++) {
            Write-Host "   $($i + 1). $($tests[$i].name)" -ForegroundColor Yellow
            Write-Host "      $($tests[$i].description)" -ForegroundColor Gray
        }
        
        do {
            $selection = Read-Host "`nIngresa el número del test (1-$($tests.Count))"
            $selectedIndex = [int]$selection - 1
        } while ($selectedIndex -lt 0 -or $selectedIndex -ge $tests.Count)
        
        $selectedTest = $tests[$selectedIndex]
        Start-K6Test -TestFile $selectedTest.file -TestName $selectedTest.name -Description $selectedTest.description -DurationMinutes $Duration
    }
}

Write-Host "`n🎯 TESTS COMPLETADOS" -ForegroundColor Green
Write-Host "📊 Accede a Grafana para ver los resultados: http://localhost:3000" -ForegroundColor Cyan
Write-Host "🔍 Revisa las trazas en Zipkin: http://localhost:9411" -ForegroundColor Cyan
Write-Host "💾 Los datos están almacenados en InfluxDB: http://localhost:8086" -ForegroundColor Cyan
