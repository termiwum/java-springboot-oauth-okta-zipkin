-- Script para poblar la base de datos de pagos para 2M+ usuarios
USE paymentdb;

-- Crear tabla de pagos si no existe
CREATE TABLE IF NOT EXISTS payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    transaction_id VARCHAR(100) UNIQUE,
    processor_response TEXT,
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order (order_id),
    INDEX idx_status (payment_status),
    INDEX idx_method (payment_method),
    INDEX idx_processed (processed_at),
    INDEX idx_amount (amount)
);

-- Crear procedimiento para insertar pagos masivamente
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS InsertMassivePayments()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE order_id BIGINT;
    DECLARE payment_amount DECIMAL(12,2);
    DECLARE payment_method VARCHAR(50);
    DECLARE payment_status VARCHAR(20);
    DECLARE transaction_id VARCHAR(100);
    DECLARE processed_time TIMESTAMP;
    DECLARE methods JSON DEFAULT JSON_ARRAY('CREDIT_CARD','DEBIT_CARD','PAYPAL','APPLE_PAY','GOOGLE_PAY','BANK_TRANSFER','CRYPTO_BTC','CRYPTO_ETH');
    DECLARE statuses JSON DEFAULT JSON_ARRAY('PENDING','PROCESSING','COMPLETED','FAILED','REFUNDED','CANCELLED');
    
    -- Limpiar tabla existente
    TRUNCATE TABLE payments;
    
    -- Insertar 600,000 pagos (más pagos que órdenes debido a reintento y reembolsos)
    WHILE i <= 600000 DO
        -- Order ID aleatorio entre 1 y 500,000
        SET order_id = 1 + FLOOR(RAND() * 500000);
        
        -- Monto aleatorio entre $5 y $50,000 (algunos pagos grandes para empresas)
        SET payment_amount = ROUND(5 + (RAND() * 49995), 2);
        
        -- Método de pago aleatorio con distribución realista
        CASE FLOOR(RAND() * 100)
            WHEN 0 TO 45 THEN SET payment_method = 'CREDIT_CARD';
            WHEN 46 TO 65 THEN SET payment_method = 'DEBIT_CARD';
            WHEN 66 TO 80 THEN SET payment_method = 'PAYPAL';
            WHEN 81 TO 88 THEN SET payment_method = 'APPLE_PAY';
            WHEN 89 TO 95 THEN SET payment_method = 'GOOGLE_PAY';
            WHEN 96 TO 98 THEN SET payment_method = 'BANK_TRANSFER';
            WHEN 99 THEN SET payment_method = 'CRYPTO_BTC';
            ELSE SET payment_method = 'CRYPTO_ETH';
        END CASE;
        
        -- Status del pago con mayor probabilidad de éxito
        CASE FLOOR(RAND() * 100)
            WHEN 0 TO 5 THEN SET payment_status = 'PENDING';
            WHEN 6 TO 10 THEN SET payment_status = 'PROCESSING';
            WHEN 11 TO 85 THEN SET payment_status = 'COMPLETED';
            WHEN 86 TO 92 THEN SET payment_status = 'FAILED';
            WHEN 93 TO 97 THEN SET payment_status = 'REFUNDED';
            ELSE SET payment_status = 'CANCELLED';
        END CASE;
        
        -- Generar transaction ID único
        SET transaction_id = CONCAT(
            'TXN_',
            DATE_FORMAT(NOW(), '%Y%m%d'),
            '_',
            UPPER(LEFT(payment_method, 3)),
            '_',
            LPAD(i, 8, '0')
        );
        
        -- Tiempo de procesamiento (NULL para PENDING/PROCESSING)
        IF payment_status IN ('COMPLETED', 'FAILED', 'REFUNDED', 'CANCELLED') THEN
            SET processed_time = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 8760) HOUR);
        ELSE
            SET processed_time = NULL;
        END IF;
        
        INSERT INTO payments (
            order_id, 
            amount, 
            payment_method, 
            payment_status, 
            transaction_id, 
            processor_response,
            processed_at,
            created_at
        ) VALUES (
            order_id,
            payment_amount,
            payment_method,
            payment_status,
            transaction_id,
            CASE payment_status
                WHEN 'COMPLETED' THEN JSON_OBJECT('status', 'success', 'code', '200', 'message', 'Payment processed successfully')
                WHEN 'FAILED' THEN JSON_OBJECT('status', 'error', 'code', '402', 'message', 'Insufficient funds')
                WHEN 'REFUNDED' THEN JSON_OBJECT('status', 'refunded', 'code', '200', 'message', 'Refund processed')
                ELSE JSON_OBJECT('status', 'processing', 'code', '102', 'message', 'Payment in progress')
            END,
            processed_time,
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 8760) HOUR)
        );
        
        SET i = i + 1;
        
        -- Commit cada 10000 registros para optimizar performance
        IF i % 10000 = 0 THEN
            COMMIT;
            -- Mostrar progreso
            SELECT CONCAT('Procesados ', i, ' pagos de 600,000') as progreso;
        END IF;
    END WHILE;
    
    -- Insertar pagos especiales para testing (con IDs conocidos)
    INSERT INTO payments (order_id, amount, payment_method, payment_status, transaction_id, processed_at) VALUES
    (1, 1500.00, 'CREDIT_CARD', 'COMPLETED', 'TEST_TXN_001', NOW()),
    (2, 299.99, 'PAYPAL', 'COMPLETED', 'TEST_TXN_002', NOW()),
    (3, 89.99, 'DEBIT_CARD', 'COMPLETED', 'TEST_TXN_003', NOW()),
    (4, 199.99, 'APPLE_PAY', 'COMPLETED', 'TEST_TXN_004', NOW()),
    (5, 49.99, 'GOOGLE_PAY', 'COMPLETED', 'TEST_TXN_005', NOW());
    
END//
DELIMITER ;

-- Ejecutar el procedimiento (esto puede tomar varios minutos)
SELECT 'Iniciando inserción masiva de pagos...' as status;
CALL InsertMassivePayments();

-- Crear índices adicionales para optimizar consultas
CREATE INDEX idx_method_status ON payments(payment_method, payment_status);
CREATE INDEX idx_amount_processed ON payments(amount, processed_at);
CREATE INDEX idx_created_status ON payments(created_at, payment_status);

-- Verificar resultados
SELECT COUNT(*) as total_payments FROM payments;

SELECT 
    payment_method,
    COUNT(*) as payment_count,
    AVG(amount) as avg_amount,
    SUM(amount) as total_amount
FROM payments 
GROUP BY payment_method
ORDER BY payment_count DESC;

SELECT 
    payment_status,
    COUNT(*) as status_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM payments), 2) as percentage,
    AVG(amount) as avg_amount
FROM payments 
GROUP BY payment_status
ORDER BY status_count DESC;

-- Estadísticas por día (últimos 30 días)
SELECT 
    DATE(created_at) as payment_date,
    COUNT(*) as daily_payments,
    SUM(amount) as daily_revenue,
    AVG(amount) as avg_payment
FROM payments 
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(created_at)
ORDER BY payment_date DESC
LIMIT 10;

-- Top 10 pagos más grandes
SELECT id, order_id, amount, payment_method, payment_status, transaction_id
FROM payments 
ORDER BY amount DESC 
LIMIT 10;
