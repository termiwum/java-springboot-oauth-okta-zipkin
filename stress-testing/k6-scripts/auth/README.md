# 🔐 Configuración de Autenticación K6

> 📖 **Contexto**: Este archivo es parte del sistema de stress testing.  
> 👉 **[Ver Documentación Completa](../../README.md)** | **[Proyecto Principal](../../../README.md)**

## 📋 Instrucciones de Configuración

### 1. Copiar el archivo de ejemplo
```bash
cd stress-testing/k6-scripts/auth/
cp oauth2-auth.js.example oauth2-auth.js
```

### 2. Configurar credenciales reales

Edita el archivo `oauth2-auth.js` y reemplaza los siguientes valores:

```javascript
export const AUTH0_CONFIG = {
    domain: 'TU_DOMINIO_AUTH0.auth0.com',           // ej: dev-abc123.us.auth0.com
    clientId: 'TU_CLIENT_ID',                       // ej: IfzN1wCb4tSWDMZPYGBcAzBCN35HQEAY
    clientSecret: 'TU_CLIENT_SECRET',               // ej: Tu_secreto_seguro
    audience: 'https://TU_DOMINIO_AUTH0.auth0.com/api/v2/',
    tokenEndpoint: 'https://TU_DOMINIO_AUTH0.auth0.com/oauth/token',
    // ... resto de configuración igual
};
```

### 3. Verificar que funciona

Ejecuta un test para verificar la configuración:

```bash
cd ../../../
docker run --rm -v ${PWD}/stress-testing:/scripts -v ${PWD}:/workspace --network host grafana/k6:latest run /scripts/k6-scripts/gateway-auth-test.js
```

## 🔒 Seguridad

- ✅ El archivo `oauth2-auth.js` está en `.gitignore` y NO se subirá al repositorio
- ✅ Solo el archivo `.example` se incluye en el repo como plantilla
- ✅ Tus credenciales reales permanecen seguras en tu máquina local

## 📁 Estructura de Archivos

```
stress-testing/k6-scripts/auth/
├── oauth2-auth.js.example    # ✅ Plantilla (en repo)
├── oauth2-auth.js           # ❌ Con credenciales reales (NO en repo)
└── README.md               # ✅ Documentación (en repo)
```

## 🚨 IMPORTANTE

**NUNCA** commites el archivo `oauth2-auth.js` con credenciales reales al repositorio. Solo usa el archivo `.example` como referencia.
