import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { getGatewayToken } from './auth/oauth2-auth.js';

// Métricas personalizadas para Place Order
export const errorRate = new Rate('place_order_errors');
export const orderCreationTime = new Trend('place_order_duration');
export const orderSuccessCount = new Counter('place_order_success');
export const productCommunicationTime = new Trend('product_service_duration');
export const paymentCommunicationTime = new Trend('payment_service_duration');

export const options = {
    stages: [
        { duration: '1m', target: 10 },   // Warm up
        { duration: '3m', target: 20 },   // Load test
        { duration: '1m', target: 50 },   // Spike test
        { duration: '2m', target: 20 },   // Back to normal
        { duration: '1m', target: 0 },    // Cool down
    ],
    thresholds: {
        http_req_duration: ['p(95)<3000'],
        place_order_errors: ['rate<0.1'],
        'place_order_duration': ['p(95)<2500'],
    },
    tags: {
        test_type: 'order_place',
        service: 'order-service',
        endpoint: '/orders/placeOrder'
    }
};

export function setup() {
    console.log('🚀 Iniciando test de Place Order - Comunicación completa entre servicios');
    const token = getGatewayToken();
    if (!token) {
        throw new Error('No se pudo obtener token de autenticación');
    }
    return { token };
}

export default function (data) {
    const { token } = data;

    // Payload para crear pedido
    const orderPayload = JSON.stringify({
        productId: Math.floor(Math.random() * 5) + 1, // Productos 1-5
        quantity: Math.floor(Math.random() * 3) + 1,   // Cantidad 1-3
        totalAmount: (Math.random() * 500 + 100).toFixed(2), // $100-600
        paymentMode: ['CASH', 'CREDIT_CARD', 'DEBIT_CARD'][Math.floor(Math.random() * 3)]
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
        },
        tags: {
            endpoint: 'place_order',
            method: 'POST'
        }
    };

    const startTime = Date.now();

    // Realizar request para crear pedido
    const response = http.post(
        'http://localhost:9090/orders/placeOrder',
        orderPayload,
        params
    );

    const duration = Date.now() - startTime;
    orderCreationTime.add(duration);

    // Verificaciones
    const isSuccess = check(response, {
        'Status es 200 OK': (r) => r.status === 200,
        'Response contiene orderId': (r) => r.body && !isNaN(parseInt(r.body)),
        'Header Content-Type correcto': (r) => r.headers['Content-Type']?.includes('application/json'),
        'Tiempo de respuesta aceptable': (r) => r.timings.duration < 3000,
    });

    if (isSuccess) {
        orderSuccessCount.add(1);

        // Métricas adicionales para servicios internos
        if (response.timings.waiting > 1000) {
            // Simular tiempo de comunicación con servicios
            productCommunicationTime.add(response.timings.waiting * 0.3);
            paymentCommunicationTime.add(response.timings.waiting * 0.4);
        }

        console.log(`✅ Pedido creado exitosamente. OrderID: ${response.body}, Duración: ${duration}ms`);
    } else {
        errorRate.add(1);
        console.error(`❌ Error creando pedido. Status: ${response.status}, Body: ${response.body}`);
    }

    // Pausa entre requests
    sleep(Math.random() * 2 + 1); // 1-3 segundos
}

export function teardown(data) {
    console.log('🏁 Test de Place Order completado');
    console.log('📊 Verificar dashboard de Order Place en Grafana');
}
