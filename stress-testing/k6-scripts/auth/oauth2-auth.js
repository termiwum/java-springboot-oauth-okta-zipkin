import http from 'k6/http';
import { check } from 'k6';
import exec from 'k6/execution';

// Configuración Auth0 para stress testing
// IMPORTANTE: Reemplaza con tus credenciales reales antes de ejecutar tests
export const AUTH0_CONFIG = {
    domain: 'YOUR_AUTH0_DOMAIN.auth0.com',
    clientId: 'YOUR_CLIENT_ID',
    clientSecret: 'YOUR_CLIENT_SECRET',
    audience: 'https://YOUR_AUTH0_DOMAIN.auth0.com/api/v2/',
    scope: 'read:users',
    tokenEndpoint: 'https://YOUR_AUTH0_DOMAIN.auth0.com/oauth/token',
    // Endpoint custom del gateway para obtener token
    gatewayTokenEndpoint: 'http://localhost:9090/token/client-credentials'
};

// Cache de tokens
let cachedToken = null;
let tokenExpiry = 0;

/**
 * Gets authentication token from the gateway endpoint
 */
export function getGatewayToken() {
    const now = Date.now();

    // Return cached token if still valid (with 30 second buffer)
    if (cachedToken && now < (tokenExpiry - 30000)) {
        return cachedToken;
    }

    console.log('🔐 Requesting new token from gateway...');

    const payload = {
        clientId: AUTH0_CONFIG.clientId,
        clientSecret: AUTH0_CONFIG.clientSecret,
        audience: AUTH0_CONFIG.audience,
        grantType: 'client_credentials'
    };

    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
        timeout: '30s'
    };

    try {
        const response = http.post(AUTH0_CONFIG.gatewayTokenEndpoint, JSON.stringify(payload), params);

        console.log(`🔐 Token request response: ${response.status}`);

        if (response.status === 200) {
            const result = JSON.parse(response.body);

            if (result.accesToken) {
                cachedToken = result.accesToken;

                // Set expiry based on expiresAt from response
                if (result.expiresAt) {
                    tokenExpiry = result.expiresAt;
                } else {
                    // Default 1 hour if not provided
                    tokenExpiry = now + (3600 * 1000);
                }

                console.log(`✅ Token obtained successfully from gateway`);
                return cachedToken;
            } else {
                console.error('❌ No access token in response:', response.body);
                return null;
            }
        } else {
            console.error(`❌ Authentication failed with status ${response.status}:`, response.body);
            console.error('🛑 ABORTANDO PRUEBA - Error de autenticación crítico');
            exec.test.abort('Authentication failed - aborting test');
            return null;
        }
    } catch (error) {
        console.error('❌ Error during authentication:', error);
        console.error('🛑 ABORTANDO PRUEBA - Error de conexión crítico');
        exec.test.abort('Authentication connection error - aborting test');
        return null;
    }
}

/**
 * Obtiene un token directamente de Auth0 usando Client Credentials flow
 */
export function getAuth0Token() {
    const tokenUrl = AUTH0_CONFIG.tokenEndpoint;

    const payload = {
        grant_type: 'client_credentials',
        client_id: AUTH0_CONFIG.clientId,
        client_secret: AUTH0_CONFIG.clientSecret,
        audience: AUTH0_CONFIG.audience,
        scope: AUTH0_CONFIG.scope
    };

    const params = {
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
    };

    console.log(`🔐 Obteniendo token OAuth2 de Auth0...`);

    const response = http.post(tokenUrl, Object.keys(payload)
        .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(payload[key])}`)
        .join('&'), params);

    const success = check(response, {
        'Auth0 token request successful': (r) => r.status === 200,
        'Auth0 response has access_token': (r) => {
            try {
                const json = JSON.parse(r.body);
                return json.access_token !== undefined;
            } catch (e) {
                return false;
            }
        },
    });

    if (!success) {
        console.error(`❌ Error obteniendo token Auth0: ${response.status} - ${response.body}`);
        console.error('🛑 ABORTANDO PRUEBA - Error Auth0 crítico');
        exec.test.abort('Auth0 token request failed - aborting test');
        return null;
    }

    const tokenData = JSON.parse(response.body);
    console.log(`✅ Token Auth0 obtenido exitosamente`);
    return tokenData.access_token;
}

/**
 * Crea headers de autorización con el token Bearer
 */
export function createAuthHeaders(token) {
    if (!token) {
        console.warn('⚠️  No se proporcionó token para autorización');
        return {};
    }

    return {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    };
}

/**
 * Hace una petición HTTP autenticada usando el token del gateway
 */
export function authenticatedRequest(method, url, body = null, additionalHeaders = {}) {
    const token = getGatewayToken();

    if (!token) {
        console.error('❌ No se pudo obtener token del gateway');
        console.error('🛑 ABORTANDO PRUEBA - Sin token de autenticación');
        exec.test.abort('No authentication token available - aborting test');
        return { status: 401, body: 'Authentication failed' };
    }

    const authHeaders = createAuthHeaders(token);
    const headers = Object.assign({}, authHeaders, additionalHeaders);

    const params = { headers };

    switch (method.toUpperCase()) {
        case 'GET':
            return http.get(url, params);
        case 'POST':
            return http.post(url, body, params);
        case 'PUT':
            return http.put(url, body, params);
        case 'DELETE':
            return http.del(url, params);
        default:
            throw new Error(`Método HTTP no soportado: ${method}`);
    }
}
