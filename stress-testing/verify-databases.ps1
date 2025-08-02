# Script para verificar la población de las bases de datos
Write-Host "Verificando estado de las bases de datos..." -ForegroundColor Green

function Check-Database {
    param(
        [string]$ContainerName,
        [string]$Database,
        [string]$Description
    )
    
    Write-Host ""
    Write-Host "Verificando: $Description" -ForegroundColor Yellow
    
    try {
        # Consultar información básica
        $result = docker exec $ContainerName mysql -u admin -padmin $Database -e "
        SELECT 
            'PRODUCTS' as table_name, COUNT(*) as record_count FROM products
        UNION ALL
        SELECT 
            'ORDERS' as table_name, COUNT(*) as record_count FROM orders  
        UNION ALL
        SELECT 
            'ORDER_ITEMS' as table_name, COUNT(*) as record_count FROM order_items
        UNION ALL
        SELECT 
            'PAYMENTS' as table_name, COUNT(*) as record_count FROM payments;
        " 2>$null
        
        if ($result) {
            Write-Host "Resultados para $Description :" -ForegroundColor Green
            $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        }
    }
    catch {
        Write-Host "Error verificando $ContainerName" -ForegroundColor Red
    }
}

# Verificar cada base de datos
Check-Database -ContainerName "mysql-product" -Database "productdb" -Description "Base de Productos"
Check-Database -ContainerName "mysql-order" -Database "orderdb" -Description "Base de Ordenes"  
Check-Database -ContainerName "mysql-payment" -Database "paymentdb" -Description "Base de Pagos"

Write-Host ""
Write-Host "Verificacion completada!" -ForegroundColor Green
