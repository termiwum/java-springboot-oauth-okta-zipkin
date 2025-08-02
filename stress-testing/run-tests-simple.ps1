# Script simple para ejecutar pruebas de estres
param(
    [string]$TestType = "individual"
)

Write-Host "Ejecutando pruebas de estres..." -ForegroundColor Green

# Verificar que K6 este instalado
if (-not (Get-Command k6 -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: K6 no esta instalado" -ForegroundColor Red
    exit 1
}

# Configurar variables de entorno para K6
$env:K6_OUT = "influxdb=http://localhost:8086/k6-metrics"

# Directorio de scripts K6
$scriptsDir = "k6-scripts"

# Tests disponibles
$tests = @(
    @{name="Product Service Test"; file="product-service-test.js"},
    @{name="Payment Service Test"; file="payment-service-test.js"},
    @{name="Order Place Test"; file="order-place-test.js"},
    @{name="Order Details Test"; file="order-details-test.js"},
    @{name="Ecosystem Global Test"; file="ecosystem-global-test.js"}
)

if ($TestType -eq "individual") {
    Write-Host "Selecciona el test a ejecutar:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $tests.Count; $i++) {
        Write-Host "  $($i + 1). $($tests[$i].name)" -ForegroundColor Yellow
    }
    
    $selection = Read-Host "Ingresa el numero del test (1-$($tests.Count))"
    $selectedIndex = [int]$selection - 1
    
    if ($selectedIndex -ge 0 -and $selectedIndex -lt $tests.Count) {
        $selectedTest = $tests[$selectedIndex]
        $testPath = Join-Path $scriptsDir $selectedTest.file
        
        Write-Host "Ejecutando: $($selectedTest.name)" -ForegroundColor Magenta
        Write-Host "Archivo: $testPath" -ForegroundColor Gray
        
        if (Test-Path $testPath) {
            k6 run --duration=3m --vus=10 $testPath
        } else {
            Write-Host "ERROR: Archivo de test no encontrado: $testPath" -ForegroundColor Red
        }
    } else {
        Write-Host "ERROR: Seleccion invalida" -ForegroundColor Red
    }
} else {
    Write-Host "Ejecutando todos los tests secuencialmente..." -ForegroundColor Cyan
    
    foreach ($test in $tests) {
        $testPath = Join-Path $scriptsDir $test.file
        
        if (Test-Path $testPath) {
            Write-Host "Ejecutando: $($test.name)" -ForegroundColor Magenta
            k6 run --duration=2m --vus=5 $testPath
            Start-Sleep 10
        } else {
            Write-Host "ADVERTENCIA: Test no encontrado: $testPath" -ForegroundColor Yellow
        }
    }
}

Write-Host "Pruebas completadas!" -ForegroundColor Green
