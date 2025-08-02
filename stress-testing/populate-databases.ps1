# Script para poblar todas las bases de datos del ecosistema
Write-Host "Poblando bases de datos del ecosistema de microservicios..." -ForegroundColor Green

# Función para ejecutar SQL en un contenedor MySQL
function Execute-SQL {
    param(
        [string]$ContainerName,
        [string]$SqlFile,
        [string]$Database
    )
    
    Write-Host "Poblando base de datos en contenedor: $ContainerName" -ForegroundColor Yellow
    
    try {
        # Copiar archivo SQL al contenedor
        docker cp $SqlFile "${ContainerName}:/tmp/script.sql"
        
        # Ejecutar el script SQL
        docker exec $ContainerName mysql -u admin -padmin -e "source /tmp/script.sql"
        
        # Limpiar archivo temporal
        docker exec $ContainerName rm /tmp/script.sql
        
        Write-Host "Base de datos $ContainerName poblada exitosamente" -ForegroundColor Green
    }
    catch {
        Write-Host "Error poblando $ContainerName : $_" -ForegroundColor Red
    }
}

# Poblar base de datos de productos
Execute-SQL -ContainerName "mysql-product" -SqlFile "./scripts/populate-products.sql" -Database "productdb"

# Poblar base de datos de pagos
Execute-SQL -ContainerName "mysql-payment" -SqlFile "./scripts/populate-payments.sql" -Database "paymentdb"

# Poblar base de datos de órdenes
Execute-SQL -ContainerName "mysql-order" -SqlFile "./scripts/populate-orders.sql" -Database "orderdb"

Write-Host ""
Write-Host "Todas las bases de datos han sido pobladas!" -ForegroundColor Green
Write-Host "Resumen de datos insertados:" -ForegroundColor Cyan
Write-Host "   Productos: 10 items" -ForegroundColor White
Write-Host "   Pagos: 10 transacciones" -ForegroundColor White
Write-Host "   Ordenes: 10 ordenes con items asociados" -ForegroundColor White
Write-Host ""
Write-Host "Las pruebas de stress testing ahora pueden ejecutarse exitosamente!" -ForegroundColor Green
