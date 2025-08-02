# Script de limpieza total del sistema Docker y memoria
Write-Host "ATENCION: Limpieza total del sistema Docker" -ForegroundColor Red
Write-Host "Esto eliminara TODOS los contenedores, imagenes, volumenes y redes" -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Esta seguro que desea continuar? (escriba 'SI' para confirmar)"
if ($confirmation -ne "SI") {
    Write-Host "Operacion cancelada" -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "LIMPIEZA TOTAL DEL SISTEMA" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Red

# Detener todos los contenedores
Write-Host "1. Deteniendo todos los contenedores..." -ForegroundColor Cyan
docker stop $(docker ps -aq) 2>$null

# Eliminar todos los contenedores
Write-Host "2. Eliminando todos los contenedores..." -ForegroundColor Cyan
docker rm $(docker ps -aq) 2>$null

# Eliminar todas las imagenes
Write-Host "3. Eliminando todas las imagenes Docker..." -ForegroundColor Cyan
docker rmi $(docker images -q) -f 2>$null

# Limpiar todo el sistema Docker
Write-Host "4. Limpieza completa del sistema Docker..." -ForegroundColor Cyan
docker system prune -a -f --volumes 2>$null

# Limpiar cache de construccion
Write-Host "5. Limpiando cache de construccion..." -ForegroundColor Cyan
docker builder prune -a -f 2>$null

# Resetear Docker Desktop (solo en Windows)
Write-Host "6. Limpiando datos de Docker Desktop..." -ForegroundColor Cyan
Stop-Service docker 2>$null
Start-Sleep -Seconds 5
Start-Service docker 2>$null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "LIMPIEZA TOTAL COMPLETADA" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "El sistema Docker ha sido completamente limpiado" -ForegroundColor Green
Write-Host "Se han eliminado:" -ForegroundColor White
Write-Host "  - Todos los contenedores" -ForegroundColor Gray
Write-Host "  - Todas las imagenes" -ForegroundColor Gray
Write-Host "  - Todos los volumenes" -ForegroundColor Gray
Write-Host "  - Todas las redes personalizadas" -ForegroundColor Gray
Write-Host "  - Todo el cache de construccion" -ForegroundColor Gray
Write-Host ""
Write-Host "El sistema esta completamente limpio y listo para empezar desde cero" -ForegroundColor Green
