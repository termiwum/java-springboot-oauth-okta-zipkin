import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { getGatewayToken } from './auth/oauth2-auth.js';

// Métricas personalizadas para Product Service
export const errorRate = new Rate('product_errors');
export const productGetTime = new Trend('product_get_duration');
export const productCreateTime = new Trend('product_create_duration');
export const inventoryUpdateTime = new Trend('inventory_update_duration');
export const productSuccessCount = new Counter('product_success');

export const options = {
    stages: [
        { duration: '1m', target: 15 },   // Warm up
        { duration: '3m', target: 30 },   // Load test
        { duration: '1m', target: 55 },   // Spike test
        { duration: '2m', target: 30 },   // Back to normal
        { duration: '1m', target: 0 },    // Cool down
    ],
    thresholds: {
        http_req_duration: ['p(95)<2000'],
        product_errors: ['rate<0.06'],
        'product_get_duration': ['p(95)<1000'],
    },
    tags: {
        test_type: 'product_service',
        service: 'product-service',
        endpoint: '/products'
    }
};

export function setup() {
    console.log('🚀 Iniciando test de Product Service - CRUD completo y gestión de inventario');
    const token = getGatewayToken();
    if (!token) {
        throw new Error('No se pudo obtener token de autenticación');
    }
    return { token };
}

export default function (data) {
    const { token } = data;

    const params = {
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
        }
    };

    // 50% consultar productos, 30% reducir cantidad, 20% crear productos
    const action = Math.random();

    if (action < 0.5) {
        // Test de consulta de producto (Customer/Admin)
        const productId = Math.floor(Math.random() * 10) + 1;
        const startTime = Date.now();

        const response = http.get(
            `http://localhost:9090/products/${productId}`,
            {
                ...params,
                tags: {
                    endpoint: 'get_product',
                    method: 'GET'
                }
            }
        );

        const duration = Date.now() - startTime;
        productGetTime.add(duration);

        const isSuccess = check(response, {
            'Status es 200 OK o 404 Not Found': (r) => r.status === 200 || r.status === 404,
            'Si 200: Response contiene product details': (r) => {
                if (r.status === 200) {
                    try {
                        const body = JSON.parse(r.body);
                        return body.productId && body.productName && body.price !== undefined;
                    } catch (e) {
                        return false;
                    }
                }
                return true;
            },
            'Tiempo de consulta aceptable': (r) => r.timings.duration < 1500,
        });

        if (isSuccess && response.status === 200) {
            productSuccessCount.add(1);
            console.log(`✅ Producto consultado exitosamente. ProductID: ${productId}, Duración: ${duration}ms`);
        } else if (response.status === 404) {
            console.log(`📋 Producto ${productId} no encontrado (esperado)`);
        } else {
            errorRate.add(1);
            console.error(`❌ Error consultando producto. Status: ${response.status}, ProductID: ${productId}`);
        }

    } else if (action < 0.8) {
        // Test de reducción de cantidad (llamado por Order Service)
        const productId = Math.floor(Math.random() * 5) + 1;
        const quantity = Math.floor(Math.random() * 3) + 1;
        const startTime = Date.now();

        const response = http.put(
            `http://localhost:9090/products/reduceQuantity/${productId}?quantity=${quantity}`,
            null,
            {
                ...params,
                tags: {
                    endpoint: 'reduce_quantity',
                    method: 'PUT'
                }
            }
        );

        const duration = Date.now() - startTime;
        inventoryUpdateTime.add(duration);

        const isSuccess = check(response, {
            'Status es 200 OK': (r) => r.status === 200,
            'Tiempo de actualización aceptable': (r) => r.timings.duration < 2000,
        });

        if (isSuccess) {
            productSuccessCount.add(1);
            console.log(`✅ Inventario actualizado. ProductID: ${productId}, Cantidad reducida: ${quantity}, Duración: ${duration}ms`);
        } else {
            errorRate.add(1);
            console.error(`❌ Error actualizando inventario. Status: ${response.status}, ProductID: ${productId}`);
        }

    } else {
        // Test de creación de producto (Admin only)
        const productPayload = JSON.stringify({
            name: `Test Product ${Math.floor(Math.random() * 1000)}`,
            price: (Math.random() * 200 + 10).toFixed(2),
            quantity: Math.floor(Math.random() * 100) + 10
        });

        const startTime = Date.now();

        const response = http.post(
            'http://localhost:9090/products',
            productPayload,
            {
                ...params,
                tags: {
                    endpoint: 'create_product',
                    method: 'POST'
                }
            }
        );

        const duration = Date.now() - startTime;
        productCreateTime.add(duration);

        const isSuccess = check(response, {
            'Status es 201 Created': (r) => r.status === 201,
            'Response contiene productId': (r) => r.body && !isNaN(parseInt(r.body)),
            'Tiempo de creación aceptable': (r) => r.timings.duration < 2500,
        });

        if (isSuccess) {
            productSuccessCount.add(1);
            console.log(`✅ Producto creado exitosamente. ProductID: ${response.body}, Duración: ${duration}ms`);
        } else {
            errorRate.add(1);
            console.error(`❌ Error creando producto. Status: ${response.status}`);
        }
    }

    // Pausa entre requests
    sleep(Math.random() * 1.8 + 0.3); // 0.3-2.1 segundos
}

export function teardown(data) {
    console.log('🏁 Test de Product Service completado');
    console.log('📊 Verificar dashboard de Product Service en Grafana');
}
