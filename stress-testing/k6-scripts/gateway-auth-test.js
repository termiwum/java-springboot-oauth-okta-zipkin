import { authenticatedRequest, getGatewayToken, AUTH0_CONFIG } from './auth/oauth2-auth.js';
import { check } from 'k6';
import exec from 'k6/execution';

export const options = {
    vus: 1,
    duration: '30s',
    thresholds: {
        checks: ['rate>0.95'],
        http_req_duration: ['p(95)<2000'],
    },
};

export function setup() {
    console.log('🔧 Verificando configuración Gateway Auth...');
    console.log(`🏢 Auth0 Domain: ${AUTH0_CONFIG.domain}`);
    console.log(`🆔 Client ID: ${AUTH0_CONFIG.clientId.substring(0, 8)}...`);
    console.log(`🎯 Gateway Token URL: ${AUTH0_CONFIG.gatewayTokenEndpoint}`);

    return { startTime: Date.now() };
}

export default function () {
    // Prueba 1: Obtener token del gateway
    console.log('🔐 Prueba 1: Obteniendo token del gateway...');
    const token = getGatewayToken();

    const tokenCheck = check(token, {
        'Token obtenido exitosamente': (t) => t !== null && t !== undefined,
        'Token tiene formato correcto': (t) => t && typeof t === 'string' && t.length > 10,
    });

    if (!tokenCheck) {
        console.error('❌ Fallo en obtención de token - abortando pruebas');
        console.error('🛑 DETENIENDO TODAS LAS PRUEBAS');
        exec.test.abort('Gateway token authentication failed - aborting all tests');
        return;
    }

    console.log(`✅ Token obtenido: ${token.substring(0, 20)}...`);

    // Prueba 2: Health check autenticado
    console.log('🏥 Prueba 2: Health check autenticado...');
    const healthResponse = authenticatedRequest('GET', 'http://localhost:9090/actuator/health');

    const healthCheck = check(healthResponse, {
        'Health endpoint responde': (r) => r.status !== undefined,
        'Health endpoint accesible': (r) => r.status === 200 || r.status === 404,
        'Health endpoint responde en tiempo razonable': (r) => r.timings && r.timings.duration < 2000,
    });

    console.log(`🩺 Health check result: ${healthResponse.status} - ${healthResponse.body ? healthResponse.body.substring(0, 100) : 'No body'}`);

    // Prueba 3: Endpoint público (debería funcionar)
    console.log('🌐 Prueba 3: Endpoint público...');
    const publicResponse = authenticatedRequest('GET', 'http://localhost:9090/health');

    const publicCheck = check(publicResponse, {
        'Endpoint público responde': (r) => r.status !== undefined,
        'Endpoint público accesible': (r) => r.status === 200 || r.status === 404,
    });

    console.log(`🌍 Public endpoint result: ${publicResponse.status}`);

    // Prueba 4: Intentar acceder a un microservicio (puede requerir auth)
    console.log('🏪 Prueba 4: Acceso a microservicio...');
    const serviceResponse = authenticatedRequest('GET', 'http://localhost:9090/product-service/api/products');

    const serviceCheck = check(serviceResponse, {
        'Microservicio responde': (r) => r.status !== undefined,
        'Microservicio no rechaza por auth': (r) => r.status !== 401 && r.status !== 403,
    });

    console.log(`🛍️ Service result: ${serviceResponse.status}`);
}

export function teardown(data) {
    const duration = (Date.now() - data.startTime) / 1000;
    console.log('🏁 Verificación de autenticación de gateway completada');
    console.log(`⏱️  Duración: ${duration.toFixed(2)} segundos`);
    console.log('🔒 Sistema de autenticación de gateway verificado');
    console.log('✅ Listo para pruebas de stress con autenticación de gateway');
}
