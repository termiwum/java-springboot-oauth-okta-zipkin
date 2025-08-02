# Script para detener completamente todos los contenedores y ecosistemas
Write-Host "Deteniendo todos los contenedores y ecosistemas..." -ForegroundColor Red

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "DETENIENDO ECOSISTEMA COMPLETO" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Yellow

# Detener todos los contenedores en ejecucion
Write-Host "1. Deteniendo todos los contenedores Docker..." -ForegroundColor Cyan
docker stop $(docker ps -q) 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   Contenedores detenidos correctamente" -ForegroundColor Green
} else {
    Write-Host "   No hay contenedores ejecutandose o ya estan detenidos" -ForegroundColor Yellow
}

# Eliminar todos los contenedores
Write-Host ""
Write-Host "2. Eliminando todos los contenedores..." -ForegroundColor Cyan
docker rm $(docker ps -aq) 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   Contenedores eliminados correctamente" -ForegroundColor Green
} else {
    Write-Host "   No hay contenedores para eliminar" -ForegroundColor Yellow
}

# Detener servicios de docker-compose en stress-testing
Write-Host ""
Write-Host "3. Deteniendo servicios de stress-testing..." -ForegroundColor Cyan
docker-compose -f docker-compose-monitoring.yml down --remove-orphans 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   Servicios de monitoring detenidos" -ForegroundColor Green
} else {
    Write-Host "   Servicios de monitoring ya estaban detenidos" -ForegroundColor Yellow
}

# Cambiar al directorio raiz del proyecto y detener ecosistema principal
Write-Host ""
Write-Host "4. Deteniendo ecosistema principal..." -ForegroundColor Cyan
cd ..
docker-compose down --remove-orphans 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   Ecosistema principal detenido" -ForegroundColor Green
} else {
    Write-Host "   Ecosistema principal ya estaba detenido" -ForegroundColor Yellow
}

# Limpiar redes Docker
Write-Host ""
Write-Host "5. Limpiando redes Docker..." -ForegroundColor Cyan
docker network prune -f 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   Redes Docker limpiadas" -ForegroundColor Green
} else {
    Write-Host "   No hay redes para limpiar" -ForegroundColor Yellow
}

# Limpiar volumenes no utilizados
Write-Host ""
Write-Host "6. Limpiando volumenes no utilizados..." -ForegroundColor Cyan
docker volume prune -f 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   Volumenes limpiados" -ForegroundColor Green
} else {
    Write-Host "   No hay volumenes para limpiar" -ForegroundColor Yellow
}

# Mostrar estado final
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "ESTADO FINAL DEL SISTEMA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Yellow

Write-Host ""
Write-Host "Contenedores en ejecucion:" -ForegroundColor White
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "   No hay contenedores ejecutandose" -ForegroundColor Green
}

Write-Host ""
Write-Host "Redes Docker activas:" -ForegroundColor White
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" 2>$null

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "LIMPIEZA COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Todos los contenedores y servicios han sido detenidos" -ForegroundColor Green
Write-Host "El sistema esta listo para un reinicio limpio" -ForegroundColor Green
Write-Host ""
Write-Host "Para reiniciar el ecosistema completo ejecute:" -ForegroundColor Yellow
Write-Host "  ./start-ecosystem.ps1" -ForegroundColor Cyan
Write-Host ""

# Volver al directorio de stress-testing
cd stress-testing
