import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';
import { getGatewayToken } from './auth/oauth2-auth.js';

// Métricas globales del ecosistema
export const globalErrorRate = new Rate('ecosystem_errors');
export const ecosystemResponseTime = new Trend('ecosystem_response_time');
export const totalOperations = new Counter('total_operations');
export const serviceAvailability = new Rate('service_availability');

// Métricas por servicio
export const orderServiceMetrics = new Trend('order_service_response');
export const paymentServiceMetrics = new Trend('payment_service_response');
export const productServiceMetrics = new Trend('product_service_response');

export const options = {
    scenarios: {
        // Escenario de flujo completo de negocio
        business_flow: {
            executor: 'ramping-vus',
            startVUs: 0,
            stages: [
                { duration: '2m', target: 20 },   // Warm up
                { duration: '5m', target: 40 },   // Load test
                { duration: '2m', target: 80 },   // Spike test
                { duration: '3m', target: 40 },   // Back to normal
                { duration: '2m', target: 0 },    // Cool down
            ],
            tags: { scenario: 'business_flow' }
        },

        // Escenario de alta concurrencia por servicio
        service_stress: {
            executor: 'constant-vus',
            vus: 25,
            duration: '8m',
            startTime: '1m',
            tags: { scenario: 'service_stress' }
        },

        // Escenario de verificación de salud
        health_check: {
            executor: 'constant-arrival-rate',
            rate: 5,
            timeUnit: '1s',
            duration: '14m',
            preAllocatedVUs: 5,
            tags: { scenario: 'health_check' }
        }
    },

    thresholds: {
        http_req_duration: ['p(95)<3000'],
        ecosystem_errors: ['rate<0.1'],
        service_availability: ['rate>0.95'],
        'ecosystem_response_time': ['p(90)<2500'],
    },

    tags: {
        test_type: 'ecosystem_global',
        environment: 'integration'
    }
};

export function setup() {
    console.log('🌐 Iniciando test global del ecosistema de microservicios');
    console.log('🔗 Verificando comunicación entre servicios...');

    const token = getGatewayToken();
    if (!token) {
        throw new Error('No se pudo obtener token de autenticación');
    }

    // Verificar que todos los servicios estén disponibles
    const services = ['orders', 'payments', 'products'];
    const healthChecks = services.map(service => {
        const response = http.get(`http://localhost:9090/${service}/health`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        return { service, available: response.status === 200 };
    });

    console.log('📊 Estado inicial de servicios:', healthChecks);

    return { token, healthChecks };
}

export default function (data) {
    const { token } = data;

    const scenario = __ENV.K6_SCENARIO || 'mixed';

    if (scenario === 'business_flow') {
        executeBusinessFlow(token);
    } else if (scenario === 'service_stress') {
        executeServiceStress(token);
    } else if (scenario === 'health_check') {
        executeHealthCheck(token);
    } else {
        executeMixedScenario(token);
    }
}

function executeBusinessFlow(token) {
    group('Flujo Completo de Negocio', function () {
        const params = {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`,
            }
        };

        // 1. Consultar productos disponibles
        group('1. Consultar Productos', function () {
            const productId = Math.floor(Math.random() * 5) + 1;
            const startTime = Date.now();

            const response = http.get(`http://localhost:9090/products/${productId}`, params);

            const duration = Date.now() - startTime;
            productServiceMetrics.add(duration);
            ecosystemResponseTime.add(duration);
            totalOperations.add(1);

            const success = check(response, {
                'Producto consultado exitosamente': (r) => r.status === 200 || r.status === 404,
            });

            serviceAvailability.add(success ? 1 : 0);
            if (!success) globalErrorRate.add(1);
        });

        // 2. Crear pedido (que internamente reduce inventario y procesa pago)
        group('2. Crear Pedido Completo', function () {
            const orderPayload = JSON.stringify({
                productId: Math.floor(Math.random() * 5) + 1,
                quantity: Math.floor(Math.random() * 3) + 1,
                totalAmount: (Math.random() * 500 + 100).toFixed(2),
                paymentMode: ['CASH', 'CREDIT_CARD', 'DEBIT_CARD'][Math.floor(Math.random() * 3)]
            });

            const startTime = Date.now();

            const response = http.post('http://localhost:9090/orders/placeOrder', orderPayload, params);

            const duration = Date.now() - startTime;
            orderServiceMetrics.add(duration);
            ecosystemResponseTime.add(duration);
            totalOperations.add(1);

            const success = check(response, {
                'Pedido creado exitosamente': (r) => r.status === 200,
                'OrderId generado': (r) => r.body && !isNaN(parseInt(r.body)),
            });

            serviceAvailability.add(success ? 1 : 0);
            if (!success) globalErrorRate.add(1);

            // 3. Si el pedido fue exitoso, consultar sus detalles
            if (success && response.body) {
                group('3. Consultar Detalles del Pedido', function () {
                    const orderId = parseInt(response.body);
                    const startTime = Date.now();

                    const detailsResponse = http.get(`http://localhost:9090/orders/${orderId}`, params);

                    const duration = Date.now() - startTime;
                    orderServiceMetrics.add(duration);
                    ecosystemResponseTime.add(duration);
                    totalOperations.add(1);

                    const detailsSuccess = check(detailsResponse, {
                        'Detalles obtenidos exitosamente': (r) => r.status === 200,
                        'Contiene información completa': (r) => {
                            try {
                                const body = JSON.parse(r.body);
                                return body.productDetails && body.paymentDetails;
                            } catch (e) {
                                return false;
                            }
                        },
                    });

                    serviceAvailability.add(detailsSuccess ? 1 : 0);
                    if (!detailsSuccess) globalErrorRate.add(1);
                });
            }
        });

        sleep(Math.random() * 2 + 1); // 1-3 segundos entre flujos
    });
}

function executeServiceStress(token) {
    // Test de estrés individual por servicio
    const services = ['orders', 'payments', 'products'];
    const service = services[Math.floor(Math.random() * services.length)];

    group(`Stress Test - ${service.toUpperCase()}`, function () {
        testIndividualService(service, token);
    });

    sleep(Math.random() * 1 + 0.5); // 0.5-1.5 segundos
}

function executeHealthCheck(token) {
    group('Health Check del Ecosistema', function () {
        const services = [
            { name: 'gateway', endpoint: '/health' },
            { name: 'orders', endpoint: '/orders/health' },
            { name: 'payments', endpoint: '/payments/health' },
            { name: 'products', endpoint: '/products/health' }
        ];

        services.forEach(service => {
            const response = http.get(`http://localhost:9090${service.endpoint}`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });

            const isHealthy = check(response, {
                [`${service.name} está saludable`]: (r) => r.status === 200,
            });

            serviceAvailability.add(isHealthy ? 1 : 0);
            totalOperations.add(1);
        });
    });

    sleep(5); // Health check cada 5 segundos
}

function executeMixedScenario(token) {
    const scenarios = ['business_flow', 'service_stress'];
    const scenario = scenarios[Math.floor(Math.random() * scenarios.length)];

    if (scenario === 'business_flow') {
        executeBusinessFlow(token);
    } else {
        executeServiceStress(token);
    }
}

function testIndividualService(service, token) {
    const params = {
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
        }
    };

    const startTime = Date.now();
    let response;

    switch (service) {
        case 'orders':
            if (Math.random() < 0.6) {
                // Crear pedido
                const orderPayload = JSON.stringify({
                    productId: Math.floor(Math.random() * 5) + 1,
                    quantity: Math.floor(Math.random() * 3) + 1,
                    totalAmount: (Math.random() * 500 + 100).toFixed(2),
                    paymentMode: ['CASH', 'CREDIT_CARD'][Math.floor(Math.random() * 2)]
                });
                response = http.post('http://localhost:9090/orders/placeOrder', orderPayload, params);
            } else {
                // Consultar pedido
                const orderId = Math.floor(Math.random() * 20) + 1;
                response = http.get(`http://localhost:9090/orders/${orderId}`, params);
            }
            break;

        case 'payments':
            if (Math.random() < 0.7) {
                // Procesar pago
                const paymentPayload = JSON.stringify({
                    orderId: Math.floor(Math.random() * 50) + 1,
                    amount: (Math.random() * 300 + 50).toFixed(2),
                    paymentMode: 'CREDIT_CARD'
                });
                response = http.post('http://localhost:9090/payments', paymentPayload, params);
            } else {
                // Consultar pago
                const orderId = Math.floor(Math.random() * 30) + 1;
                response = http.get(`http://localhost:9090/payments/order/${orderId}`, params);
            }
            break;

        case 'products':
            const action = Math.random();
            if (action < 0.5) {
                // Consultar producto
                const productId = Math.floor(Math.random() * 10) + 1;
                response = http.get(`http://localhost:9090/products/${productId}`, params);
            } else if (action < 0.8) {
                // Reducir cantidad
                const productId = Math.floor(Math.random() * 5) + 1;
                const quantity = Math.floor(Math.random() * 3) + 1;
                response = http.put(`http://localhost:9090/products/reduceQuantity/${productId}?quantity=${quantity}`, null, params);
            } else {
                // Crear producto
                const productPayload = JSON.stringify({
                    name: `Test Product ${Math.floor(Math.random() * 1000)}`,
                    price: (Math.random() * 200 + 10).toFixed(2),
                    quantity: Math.floor(Math.random() * 100) + 10
                });
                response = http.post('http://localhost:9090/products', productPayload, params);
            }
            break;
    }

    const duration = Date.now() - startTime;
    ecosystemResponseTime.add(duration);
    totalOperations.add(1);

    // Registrar métricas por servicio
    switch (service) {
        case 'orders':
            orderServiceMetrics.add(duration);
            break;
        case 'payments':
            paymentServiceMetrics.add(duration);
            break;
        case 'products':
            productServiceMetrics.add(duration);
            break;
    }

    const success = check(response, {
        'Servicio responde correctamente': (r) => r.status >= 200 && r.status < 500,
    });

    serviceAvailability.add(success ? 1 : 0);
    if (!success) globalErrorRate.add(1);
}

export function teardown(data) {
    console.log('🏁 Test global del ecosistema completado');
    console.log('📊 Verificar dashboards individuales y global en Grafana');
    console.log('🔍 Revisar trazas distribuidas en Zipkin');
}
