-- Script para poblar la base de datos de productos para 2M+ usuarios
USE productdb;

-- Crear tabla de productos si no existe
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    category VARCHAR(100),
    sku VARCHAR(50) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_stock (stock_quantity),
    INDEX idx_price (price)
);

-- Crear procedimiento para insertar productos masivamente
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS InsertMassiveProducts()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE category_list VARCHAR(1000) DEFAULT 'Electronics,Computers,Gaming,Mobile,Audio,Home,Sports,Books,Clothing,Health';
    DECLARE categories JSON DEFAULT JSON_ARRAY('Electronics','Computers','Gaming','Mobile','Audio','Home','Sports','Books','Clothing','Health');
    DECLARE base_price DECIMAL(10,2);
    DECLARE stock_qty INT;
    DECLARE cat_name VARCHAR(100);
    
    -- Limpiar tabla existente
    TRUNCATE TABLE products;
    
    -- Insertar 10,000 productos base
    WHILE i <= 10000 DO
        -- Seleccionar categoría aleatoria
        SET cat_name = JSON_UNQUOTE(JSON_EXTRACT(categories, CONCAT('$[', FLOOR(RAND() * 10), ']')));
        
        -- Precio aleatorio entre $5 y $2000
        SET base_price = ROUND(5 + (RAND() * 1995), 2);
        
        -- Stock aleatorio entre 100 y 50,000 unidades para soportar alta demanda
        SET stock_qty = 100 + FLOOR(RAND() * 49900);
        
        INSERT INTO products (name, description, price, stock_quantity, category, sku) VALUES
        (
            CONCAT(cat_name, ' Product ', i),
            CONCAT('High-quality ', cat_name, ' product with advanced features. SKU: PRD-', LPAD(i, 6, '0')),
            base_price,
            stock_qty,
            cat_name,
            CONCAT('PRD-', LPAD(i, 6, '0'))
        );
        
        SET i = i + 1;
        
        -- Commit cada 1000 registros para optimizar performance
        IF i % 1000 = 0 THEN
            COMMIT;
        END IF;
    END WHILE;
    
    -- Insertar productos premium específicos con stock muy alto
    INSERT INTO products (name, description, price, stock_quantity, category, sku) VALUES
    ('Gaming Laptop Pro', 'Ultimate gaming laptop with RTX 4090', 2999.99, 100000, 'Gaming', 'GAMING-LAPTOP-001'),
    ('Wireless Gaming Mouse', 'Professional gaming mouse with RGB', 89.99, 500000, 'Gaming', 'GAMING-MOUSE-001'),
    ('Mechanical Keyboard RGB', 'Cherry MX switches with full RGB', 159.99, 300000, 'Gaming', 'GAMING-KB-001'),
    ('4K Gaming Monitor', '32-inch 4K 144Hz gaming monitor', 799.99, 75000, 'Gaming', 'GAMING-MON-001'),
    ('Gaming Headset Pro', 'Noise-canceling gaming headset', 199.99, 250000, 'Gaming', 'GAMING-HS-001'),
    ('Smartphone Pro Max', 'Latest flagship smartphone', 1299.99, 200000, 'Mobile', 'PHONE-PRO-001'),
    ('Wireless Earbuds Pro', 'Premium noise-canceling earbuds', 299.99, 400000, 'Audio', 'EARBUDS-PRO-001'),
    ('Smartwatch Ultra', 'Advanced fitness and health tracking', 499.99, 150000, 'Electronics', 'WATCH-ULTRA-001'),
    ('Tablet Pro 12"', 'Professional tablet with stylus', 899.99, 100000, 'Electronics', 'TABLET-PRO-001'),
    ('Home Security Camera', 'AI-powered security camera system', 349.99, 80000, 'Home', 'SECURITY-CAM-001');
    
END//
DELIMITER ;

-- Ejecutar el procedimiento
CALL InsertMassiveProducts();

-- Crear índices adicionales para optimizar consultas
CREATE INDEX idx_name_category ON products(name, category);
CREATE INDEX idx_price_stock ON products(price, stock_quantity);

-- Verificar resultados
SELECT COUNT(*) as total_products FROM products;
SELECT category, COUNT(*) as products_per_category, 
       AVG(stock_quantity) as avg_stock,
       SUM(stock_quantity) as total_stock
FROM products 
GROUP BY category;

-- Mostrar algunos productos de ejemplo
SELECT id, name, price, stock_quantity, category 
FROM products 
WHERE stock_quantity > 100000 
ORDER BY stock_quantity DESC 
LIMIT 10;
