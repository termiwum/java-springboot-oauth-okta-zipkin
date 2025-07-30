# Configuración de Variables de Entorno

Este proyecto utiliza variables de entorno para manejar información sensible como credenciales de base de datos y tokens de OAuth2.

## 📋 Variables Requeridas

### Base de Datos MySQL
```bash
DB_USERNAME=admin
DB_PASSWORD=your_secure_password
```

### Configuración de Okta
```bash
OKTA_ISSUER_URI=https://your-okta-domain.okta.com/oauth2/default
OKTA_CLIENT_ID=your_okta_client_id
OKTA_CLIENT_SECRET=your_okta_client_secret
```

## 🚀 Configuración para Desarrollo

### Opción 1: Variables de entorno del sistema
En Windows PowerShell:
```powershell
$env:DB_USERNAME = "admin"
$env:DB_PASSWORD = "admin"
$env:OKTA_ISSUER_URI = "https://dev-12345.okta.com/oauth2/default"
$env:OKTA_CLIENT_ID = "your_client_id"
$env:OKTA_CLIENT_SECRET = "your_client_secret"
```

En Linux/Mac:
```bash
export DB_USERNAME=admin
export DB_PASSWORD=admin
export OKTA_ISSUER_URI=https://dev-12345.okta.com/oauth2/default
export OKTA_CLIENT_ID=your_client_id
export OKTA_CLIENT_SECRET=your_client_secret
```

### Opción 2: Archivo .env (no incluido en git)
Crea un archivo `.env` en la raíz de cada microservicio:
```
DB_USERNAME=admin
DB_PASSWORD=admin
OKTA_ISSUER_URI=https://dev-12345.okta.com/oauth2/default
OKTA_CLIENT_ID=your_client_id
OKTA_CLIENT_SECRET=your_client_secret
```

### Opción 3: IDE Configuration
En tu IDE (IntelliJ IDEA, Eclipse, VS Code), configura las variables de entorno en la configuración de ejecución.

## 🔧 Configuración de Archivos

### Para cada microservicio:
1. Copia el archivo `application.yml.example` a `application.yml`
2. Reemplaza los valores placeholder con tus credenciales reales
3. **NUNCA** commitees el archivo `application.yml` con credenciales reales

### Ejemplo para Order Service:
```bash
cd order-service/src/main/resources/
cp application.yml.example application.yml
# Edita application.yml con tus credenciales
```

## 🛡️ Seguridad

- ✅ Los archivos `application.yml` están en `.gitignore`
- ✅ Usa variables de entorno para credenciales
- ✅ Los archivos `.example` muestran la estructura sin exponer secretos
- ❌ **NUNCA** commitees credenciales reales al repositorio

## 📝 Configuración de Okta

1. Crea una cuenta en [Okta Developer](https://developer.okta.com/)
2. Crea una nueva aplicación
3. Configura los grant types necesarios
4. Obtén el Client ID y Client Secret
5. Configura los grupos y scopes necesarios

Para más detalles, consulta la [documentación de Okta](https://developer.okta.com/docs/).
