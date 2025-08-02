#!/usr/bin/env pwsh
param(
    [switch]$Force,
    [switch]$Volumes
)

$ErrorActionPreference = "Continue"
$startTime = Get-Date

Write-Host "[STOP] Deteniendo ecosistema de testing..." -ForegroundColor Yellow

# Función para ejecutar comando con manejo de errores
function Execute-Command {
    param(
        [string]$Command,
        [string]$Description
    )
    
    Write-Host "[->] $Description..." -ForegroundColor Gray
    try {
        Invoke-Expression $Command
        Write-Host "[OK] $Description completado" -ForegroundColor Green
    } catch {
        Write-Host "[!] Error en $Description`: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Parar todos los contenedores de docker-compose
Execute-Command "docker-compose down --remove-orphans" "Deteniendo servicios principales"

# Parar stack de monitoreo
Execute-Command "docker-compose -f stress-testing/docker-compose-monitoring.yml down --remove-orphans" "Deteniendo stack de monitoreo"

# Si se especifica -Volumes, eliminar volumenes tambien
if ($Volumes) {
    Write-Host "[DELETE] Eliminando volumenes..." -ForegroundColor Yellow
    Execute-Command "docker-compose down --volumes" "Eliminando volumenes principales"
    Execute-Command "docker-compose -f stress-testing/docker-compose-monitoring.yml down --volumes" "Eliminando volumenes de monitoreo"
}

# Si se especifica -Force, hacer limpieza mas agresiva
if ($Force) {
    Write-Host "[CLEAN] Limpieza forzada..." -ForegroundColor Red
    Execute-Command "docker container prune -f" "Eliminando contenedores detenidos"
    Execute-Command "docker network prune -f" "Eliminando redes no utilizadas"
    
    if ($Volumes) {
        Execute-Command "docker volume prune -f" "Eliminando volumenes no utilizados"
    }
}

# Verificar que no queden contenedores corriendo
Write-Host "`n[CHECK] Verificando contenedores restantes..." -ForegroundColor Cyan
$pattern = 'grafana|influxdb|prometheus|zipkin|eureka|gateway|order|payment|product'
$runningContainers = docker ps --format "{{.Names}}" | Where-Object { $_ -match $pattern }

if ($runningContainers) {
    Write-Host "[!] Contenedores aun corriendo:" -ForegroundColor Yellow
    $runningContainers | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "[OK] No hay contenedores del ecosistema corriendo" -ForegroundColor Green
}

$endTime = Get-Date
$totalTime = ($endTime - $startTime).TotalSeconds

Write-Host "`n[SUCCESS] Ecosistema detenido!" -ForegroundColor Green
Write-Host "Tiempo total: $totalTime segundos" -ForegroundColor Green
Write-Host "`nOpciones de uso:" -ForegroundColor Cyan
Write-Host "  .\stop-ecosystem.ps1              # Parada normal" -ForegroundColor White
Write-Host "  .\stop-ecosystem.ps1 -Volumes     # Incluye eliminacion de volumenes" -ForegroundColor White
Write-Host "  .\stop-ecosystem.ps1 -Force       # Limpieza agresiva" -ForegroundColor White
Write-Host "  .\stop-ecosystem.ps1 -Force -Volumes # Limpieza completa" -ForegroundColor White
