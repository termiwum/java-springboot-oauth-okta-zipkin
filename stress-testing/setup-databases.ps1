# Script para configurar bases de datos y permisos antes de poblar
Write-Host "Configurando bases de datos y permisos..." -ForegroundColor Green

function Setup-Database {
    param(
        [string]$ContainerName,
        [string]$DatabaseName,
        [string]$Description
    )
    
    Write-Host ""
    Write-Host "Configurando: $Description" -ForegroundColor Yellow
    
    try {
        # Intentar con diferentes credenciales
        Write-Host "Intentando conexion con root..." -ForegroundColor Gray
        
        # Crear base de datos y usuario con permisos
        $setupSQL = @"
CREATE DATABASE IF NOT EXISTS $DatabaseName;
CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'apppassword';
GRANT ALL PRIVILEGES ON $DatabaseName.* TO 'appuser'@'%';
GRANT ALL PRIVILEGES ON $DatabaseName.* TO 'admin'@'%';
FLUSH PRIVILEGES;
SHOW DATABASES;
"@
        
        # Guardar SQL temporalmente
        $setupSQL | Out-File -FilePath "./temp-setup.sql" -Encoding UTF8
        
        # Copiar y ejecutar
        docker cp "./temp-setup.sql" "${ContainerName}:/tmp/setup.sql"
        
        # Intentar con root primero
        Write-Host "Ejecutando configuracion con root..." -ForegroundColor Gray
        docker exec $ContainerName mysql -u root -prootpassword -e "source /tmp/setup.sql" 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Intentando con admin..." -ForegroundColor Gray
            docker exec $ContainerName mysql -u admin -padmin -e "source /tmp/setup.sql"
        }
        
        # Limpiar
        docker exec $ContainerName rm /tmp/setup.sql
        Remove-Item "./temp-setup.sql" -Force
        
        Write-Host "Configuracion completada para $Description" -ForegroundColor Green
    }
    catch {
        Write-Host "Error configurando $ContainerName : $_" -ForegroundColor Red
    }
}

# Configurar cada base de datos
Setup-Database -ContainerName "mysql-product" -DatabaseName "productdb" -Description "Base de Productos"
Setup-Database -ContainerName "mysql-payment" -DatabaseName "paymentdb" -Description "Base de Pagos" 
Setup-Database -ContainerName "mysql-order" -DatabaseName "orderdb" -Description "Base de Ordenes"

Write-Host ""
Write-Host "Configuracion de bases de datos completada!" -ForegroundColor Green
