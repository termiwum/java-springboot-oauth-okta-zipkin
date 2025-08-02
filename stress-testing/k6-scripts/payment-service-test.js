import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { getGatewayToken } from './auth/oauth2-auth.js';

// Métricas personalizadas para Payment Service
export const errorRate = new Rate('payment_errors');
export const paymentProcessTime = new Trend('payment_process_duration');
export const paymentSuccessCount = new Counter('payment_success');
export const paymentRetrievalTime = new Trend('payment_retrieval_duration');

export const options = {
    stages: [
        { duration: '1m', target: 12 },   // Warm up
        { duration: '3m', target: 25 },   // Load test
        { duration: '1m', target: 45 },   // Spike test
        { duration: '2m', target: 25 },   // Back to normal
        { duration: '1m', target: 0 },    // Cool down
    ],
    thresholds: {
        http_req_duration: ['p(95)<2500'],
        payment_errors: ['rate<0.08'],
        'payment_process_duration': ['p(95)<2000'],
    },
    tags: {
        test_type: 'payment_service',
        service: 'payment-service',
        endpoint: '/payments'
    }
};

export function setup() {
    console.log('🚀 Iniciando test de Payment Service - Procesamiento y consulta de pagos');
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

    // 70% procesar pagos, 30% consultar pagos
    const action = Math.random() < 0.7 ? 'process' : 'query';

    if (action === 'process') {
        // Test de procesamiento de pago
        const paymentPayload = JSON.stringify({
            orderId: Math.floor(Math.random() * 100) + 1,
            amount: (Math.random() * 500 + 50).toFixed(2),
            paymentMode: ['CASH', 'CREDIT_CARD', 'DEBIT_CARD'][Math.floor(Math.random() * 3)]
        });

        const startTime = Date.now();

        const response = http.post(
            'http://localhost:9090/payments',
            paymentPayload,
            {
                ...params,
                tags: {
                    endpoint: 'process_payment',
                    method: 'POST'
                }
            }
        );

        const duration = Date.now() - startTime;
        paymentProcessTime.add(duration);

        const isSuccess = check(response, {
            'Status es 201 Created': (r) => r.status === 201,
            'Response contiene paymentId': (r) => r.body && !isNaN(parseInt(r.body)),
            'Tiempo de procesamiento aceptable': (r) => r.timings.duration < 2500,
        });

        if (isSuccess) {
            paymentSuccessCount.add(1);
            console.log(`✅ Pago procesado exitosamente. PaymentID: ${response.body}, Duración: ${duration}ms`);
        } else {
            errorRate.add(1);
            console.error(`❌ Error procesando pago. Status: ${response.status}`);
        }

    } else {
        // Test de consulta de pago por orderId
        const orderId = Math.floor(Math.random() * 50) + 1;
        const startTime = Date.now();

        const response = http.get(
            `http://localhost:9090/payments/order/${orderId}`,
            {
                ...params,
                tags: {
                    endpoint: 'get_payment_by_order',
                    method: 'GET'
                }
            }
        );

        const duration = Date.now() - startTime;
        paymentRetrievalTime.add(duration);

        const isSuccess = check(response, {
            'Status es 200 OK o 404 Not Found': (r) => r.status === 200 || r.status === 404,
            'Si 200: Response contiene payment details': (r) => {
                if (r.status === 200) {
                    try {
                        const body = JSON.parse(r.body);
                        return body.paymentId && body.amount && body.paymentMode;
                    } catch (e) {
                        return false;
                    }
                }
                return true;
            },
            'Tiempo de consulta aceptable': (r) => r.timings.duration < 1500,
        });

        if (isSuccess && response.status === 200) {
            console.log(`✅ Detalles de pago obtenidos. OrderID: ${orderId}, Duración: ${duration}ms`);
        } else if (response.status === 404) {
            console.log(`📋 Pago para orden ${orderId} no encontrado (esperado)`);
        } else {
            errorRate.add(1);
            console.error(`❌ Error consultando pago. Status: ${response.status}, OrderID: ${orderId}`);
        }
    }

    // Pausa entre requests
    sleep(Math.random() * 2 + 0.5); // 0.5-2.5 segundos
}

export function teardown(data) {
    console.log('🏁 Test de Payment Service completado');
    console.log('📊 Verificar dashboard de Payment Service en Grafana');
}
