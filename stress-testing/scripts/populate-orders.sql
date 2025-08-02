-- Script para poblar la base de datos de órdenes para 2M+ usuarios
USE orderdb;

-- Crear tabla de órdenes si no existe
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    order_status VARCHAR(20) DEFAULT 'PENDING',
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer (customer_id),
    INDEX idx_status (order_status),
    INDEX idx_created (created_at),
    INDEX idx_amount (total_amount)
);

-- Crear tabla de items de órdenes si no existe
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    INDEX idx_order (order_id),
    INDEX idx_product (product_id),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Crear procedimiento para insertar órdenes masivamente
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS InsertMassiveOrders()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE order_id BIGINT;
    DECLARE customer_id BIGINT;
    DECLARE order_total DECIMAL(12,2);
    DECLARE status_list JSON DEFAULT JSON_ARRAY('PENDING','PROCESSING','SHIPPED','COMPLETED','CANCELLED');
    DECLARE order_status VARCHAR(20);
    DECLARE items_count INT;
    DECLARE item_idx INT;
    DECLARE product_id BIGINT;
    DECLARE quantity INT;
    DECLARE unit_price DECIMAL(10,2);
    DECLARE item_total DECIMAL(12,2);
    
    -- Limpiar tablas existentes
    SET FOREIGN_KEY_CHECKS = 0;
    TRUNCATE TABLE order_items;
    TRUNCATE TABLE orders;
    SET FOREIGN_KEY_CHECKS = 1;
    
    -- Insertar 500,000 órdenes para simular actividad de 2M usuarios
    WHILE i <= 500000 DO
        -- Customer ID aleatorio entre 1 y 2,000,000
        SET customer_id = 1 + FLOOR(RAND() * 2000000);
        
        -- Status aleatorio con mayor probabilidad de COMPLETED
        CASE FLOOR(RAND() * 10)
            WHEN 0,1 THEN SET order_status = 'PENDING';
            WHEN 2 THEN SET order_status = 'PROCESSING';
            WHEN 3,4 THEN SET order_status = 'SHIPPED';
            WHEN 5,6,7,8 THEN SET order_status = 'COMPLETED';
            ELSE SET order_status = 'CANCELLED';
        END CASE;
        
        -- Insertar orden base
        INSERT INTO orders (customer_id, total_amount, order_status, shipping_address, created_at) VALUES
        (
            customer_id,
            0.00, -- Se calculará después
            order_status,
            CONCAT(
                FLOOR(100 + RAND() * 9900), ' ',
                ELT(FLOOR(1 + RAND() * 10), 'Main St', 'Oak Ave', 'Pine Rd', 'Elm St', 'Maple Dr', 'Cedar Ln', 'Birch Ct', 'Spruce Way', 'Willow St', 'Ash Blvd'),
                ', City, State ', 
                LPAD(FLOOR(10000 + RAND() * 89999), 5, '0')
            ),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY)
        );
        
        SET order_id = LAST_INSERT_ID();
        SET order_total = 0.00;
        
        -- Número aleatorio de items por orden (1-8 items)
        SET items_count = 1 + FLOOR(RAND() * 8);
        SET item_idx = 1;
        
        -- Insertar items para esta orden
        WHILE item_idx <= items_count DO
            -- Product ID aleatorio entre 1 y 10000 (productos disponibles)
            SET product_id = 1 + FLOOR(RAND() * 10000);
            
            -- Cantidad aleatoria entre 1 y 10
            SET quantity = 1 + FLOOR(RAND() * 10);
            
            -- Precio unitario aleatorio entre $5 y $2000
            SET unit_price = ROUND(5 + (RAND() * 1995), 2);
            SET item_total = quantity * unit_price;
            
            INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES
            (order_id, product_id, quantity, unit_price, item_total);
            
            SET order_total = order_total + item_total;
            SET item_idx = item_idx + 1;
        END WHILE;
        
        -- Actualizar total de la orden
        UPDATE orders SET total_amount = order_total WHERE id = order_id;
        
        SET i = i + 1;
        
        -- Commit cada 5000 registros para optimizar performance
        IF i % 5000 = 0 THEN
            COMMIT;
            -- Mostrar progreso
            SELECT CONCAT('Procesadas ', i, ' órdenes de 500,000') as progreso;
        END IF;
    END WHILE;
    
END//
DELIMITER ;

-- Ejecutar el procedimiento (esto puede tomar varios minutos)
SELECT 'Iniciando inserción masiva de órdenes...' as status;
CALL InsertMassiveOrders();

-- Crear índices adicionales para optimizar consultas
CREATE INDEX idx_customer_status ON orders(customer_id, order_status);
CREATE INDEX idx_amount_created ON orders(total_amount, created_at);
CREATE INDEX idx_order_product ON order_items(order_id, product_id);

-- Verificar resultados
SELECT COUNT(*) as total_orders FROM orders;
SELECT COUNT(*) as total_order_items FROM order_items;

SELECT 
    order_status,
    COUNT(*) as order_count,
    AVG(total_amount) as avg_amount,
    SUM(total_amount) as total_revenue
FROM orders 
GROUP BY order_status;

-- Estadísticas de items por orden
SELECT 
    items_per_order,
    COUNT(*) as orders_count
FROM (
    SELECT order_id, COUNT(*) as items_per_order
    FROM order_items
    GROUP BY order_id
) as order_stats
GROUP BY items_per_order
ORDER BY items_per_order;

-- Top 10 órdenes por valor
SELECT id, customer_id, total_amount, order_status, created_at
FROM orders 
ORDER BY total_amount DESC 
LIMIT 10;
