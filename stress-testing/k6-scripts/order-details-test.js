import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { getGatewayToken } from './auth/oauth2-auth.js';

// Métricas personalizadas para Get Order
export const errorRate = new Rate('get_order_errors');
export const orderRetrievalTime = new Trend('get_order_duration');
export const orderSuccessCount = new Counter('get_order_success');
export const serviceChainTime = new Trend('order_details_chain_duration');

export const options = {
    stages: [
        { duration: '1m', target: 15 },   // Warm up
        { duration: '3m', target: 30 },   // Load test
        { duration: '1m', target: 60 },   // Spike test
        { duration: '2m', target: 30 },   // Back to normal
        { duration: '1m', target: 0 },    // Cool down
    ],
    thresholds: {
        http_req_duration: ['p(95)<2000'],
        get_order_errors: ['rate<0.05'],
        'get_order_duration': ['p(95)<1500'],
    },
    tags: {
        test_type: 'order_get',
        service: 'order-service',
        endpoint: '/orders/{id}'
    }
};

export function setup() {
    console.log('🚀 Iniciando test de Get Order Details - Comunicación Order->Product+Payment');
    const token = getGatewayToken();
    if (!token) {
        throw new Error('No se pudo obtener token de autenticación');
    }
    return { token };
}

export default function (data) {
    const { token } = data;

    // IDs de órdenes existentes (simuladas)
    const orderId = Math.floor(Math.random() * 10) + 1; // Órdenes 1-10

    const params = {
        headers: {
            'Authorization': `Bearer ${token}`,
        },
        tags: {
            endpoint: 'get_order',
            method: 'GET',
            chain: 'order_product_payment_details'
        }
    };

    const startTime = Date.now();

    // Realizar request para obtener detalles (Order -> Product + Payment)
    const response = http.get(
        `http://localhost:9090/orders/${orderId}`,
        params
    );

    const duration = Date.now() - startTime;
    orderRetrievalTime.add(duration);
    serviceChainTime.add(duration);

    // Verificaciones
    const isSuccess = check(response, {
        'Status es 200 OK o 404 Not Found': (r) => r.status === 200 || r.status === 404,
        'Si 200: Response contiene orderDetails': (r) => {
            if (r.status === 200) {
                try {
                    const body = JSON.parse(r.body);
                    return body.orderId && body.productDetails && body.paymentDetails;
                } catch (e) {
                    return false;
                }
            }
            return true;
        },
        'Header Content-Type correcto': (r) => r.headers['Content-Type']?.includes('application/json'),
        'Tiempo de respuesta aceptable': (r) => r.timings.duration < 2000,
        'Cadena de servicios funcional': (r) => r.status === 200 || r.status === 404,
    });

    if (isSuccess && response.status === 200) {
        orderSuccessCount.add(1);
        console.log(`✅ Detalles obtenidos exitosamente. OrderID: ${orderId}, Duración: ${duration}ms`);
    } else if (response.status === 404) {
        console.log(`📋 Orden ${orderId} no encontrada (esperado)`);
    } else {
        errorRate.add(1);
        console.error(`❌ Error obteniendo detalles. Status: ${response.status}, OrderID: ${orderId}`);
    }

    // Pausa entre requests
    sleep(Math.random() * 1.5 + 0.5); // 0.5-2 segundos
}

export function teardown(data) {
    console.log('🏁 Test de Get Order Details completado');
    console.log('📊 Verificar dashboard de Order Details en Grafana');
}
