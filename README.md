# Java Spring Boot OAuth Auth0 Zipkin - Microservices Architecture

**🏗️ Desarrollado por:** [termiwum](https://github.com/termiwum)

Este workspace contiene una arquitectura completa de microservicios construida con Spring Boot, implementando autenticación OAuth2 con Auth0 y monitoreo distribuido con Zipkin.

## 🚀 Inicio Rápido con Docker

### Opción 1: Makefile (Recomendado)
```bash
# Ver todos los comandos disponibles
make help

# Construir y levantar todo el ecosistema
make up-build

# Ver estado de los servicios
make status

# Ver logs en tiempo real
make logs

# Detener todo
make down
```

### Opción 2: Docker Compose
```bash
# Construir y levantar todos los servicios
docker-compose up -d --build

# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f

# Detener todo
docker-compose down
```

### Opción 3: Automatización con Scripts
```powershell
# Windows PowerShell
.\start-ecosystem.ps1

# Linux/macOS Bash
./start-ecosystem.sh
```

### Opción 4: Manual
Seguir la guía completa en [DOCKER_SETUP.md](./DOCKER_SETUP.md) OAuth Auth0 Zipkin - Microservices Architecture

Este workspace contiene una arquitectura completa de microservicios construida con Spring Boot, implementando autenticación OAuth2 con Auth0 y monitoreo distribuido con Zipkin.

## � Inicio Rápido con Docker

### Opción 1: Automatización Completa
```powershell
# Windows PowerShell
.\start-ecosystem.ps1

# Linux/macOS Bash
./start-ecosystem.sh
```

### Opción 2: Manual
Seguir la guía completa en [DOCKER_SETUP.md](./DOCKER_SETUP.md)

## �📋 Resumen de Proyectos

### 🌐 Cloud Gateway (`cloud-gateway`)
**Puerto:** 9090  
**Propósito:** API Gateway principal que actúa como punto de entrada único para todos los microservicios.

**Características principales:**
- **Tecnología:** Spring Cloud Gateway con WebFlux
- **Autenticación:** OAuth2 con Auth0
- **Balanceador de carga:** Integrado con Eureka Service Discovery
- **Circuit Breaker:** Implementado para resiliencia
- **Rate Limiting:** Control de tráfico con Redis
- **Monitoreo:** Integración con Zipkin para trazabilidad distribuida

**Rutas configuradas:**
- `/orders/**` → ORDER-SERVICE
- `/payments/**` → PAYMENT-SERVICE  
- `/products/**` → PRODUCT-SERVICE

### ⚙️ Config Server (`config-server`)
**Puerto:** 9296  
**Propósito:** Servidor de configuración centralizada para todos los microservicios.

**Características principales:**
- **Tecnología:** Spring Cloud Config Server
- **Monitoreo:** Actuator + Zipkin tracing
- **Configuración:** Gestión centralizada de propiedades
- **Health Check:** Endpoints de salud disponibles

### 🔍 Service Registry (`service-registry`)
**Puerto:** 8761  
**Propósito:** Registro y descubrimiento de servicios usando Netflix Eureka.

**Características principales:**
- **Tecnología:** Netflix Eureka Server
- **Service Discovery:** Registro automático de microservicios
- **Load Balancing:** Distribución de carga entre instancias
- **Health Monitoring:** Monitoreo de salud de servicios

### 📦 Order Service (`order-service`)
**Puerto:** 8082  
**Propósito:** Gestión de pedidos y lógica de negocio principal.

**Características principales:**
- **Base de datos:** MySQL (order_db)
- **Seguridad:** OAuth2 Resource Server con Auth0
- **Autorización:** Role-based access control (Customer, Admin)
- **Comunicación:** Feign Client para llamadas a otros servicios
- **Monitoreo:** Zipkin tracing integrado
- **Testing:** Configuración de testing con Jacoco y SonarQube

**Endpoints principales:**
- `POST /orders/placeOrder` - Crear pedido (Customer)
- `GET /orders/{orderId}` - Obtener detalles de pedido (Admin/Customer)

### 💳 Payment Service (`payment-service`)
**Puerto:** No especificado  
**Propósito:** Procesamiento de pagos y transacciones financieras.

**Características principales:**
- **Base de datos:** MySQL
- **Seguridad:** OAuth2 Resource Server con Auth0
- **Autorización:** Acceso para Customer, Admin y SCOPE_internal
- **Monitoreo:** Zipkin sleuth integration
- **Comunicación:** Eureka client para service discovery

### 🛍️ Product Service (`product-service`)
**Puerto:** No especificado  
**Propósito:** Gestión del catálogo de productos.

**Características principales:**
- **Base de datos:** MySQL
- **Seguridad:** OAuth2 Resource Server con Auth0
- **Autorización:** Basada en roles y scopes
- **API:** RESTful endpoints para gestión de productos
- **Monitoreo:** Integración con Zipkin

### 📁 Spring Boot Config (`spring-boot-config`)
**Propósito:** Archivos de configuración compartidos para todos los servicios.

**Configuraciones incluidas:**
- **Eureka Client:** Configuración para service discovery
- **Zipkin:** Configuración de tracing distribuido (100% sampling)
- **OAuth2:** Configuración de Auth0 issuer y audience
- **Logging:** Configuración de logs para debugging

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cloud Gateway │    │  Config Server  │    │ Service Registry│
│     :9090       │    │     :9296       │    │     :8761       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Order Service  │    │ Payment Service │    │ Product Service │
│     :8082       │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │     Zipkin      │
                    │     :9411       │
                    └─────────────────┘
```

## 🔐 Seguridad y Autenticación

### OAuth2 con Auth0
- **Issuer:** `https://dev-knq5qdss5uzcsuyw.us.auth0.com/`
- **Audience:** `https://dev-knq5qdss5uzcsuyw.us.auth0.com/api/v2/`
- **Grant Types:** Authorization Code, Client Credentials
- **Scopes:** openid, email, profile, offline_access, Customer, Admin

### Roles y Autorización
- **Customer:** Acceso a operaciones básicas (crear pedidos, ver propios pedidos)
- **Admin:** Acceso completo a todos los recursos
- **SCOPE_internal:** Para comunicación entre servicios

## 📊 Monitoreo y Observabilidad

### Zipkin Distributed Tracing
- **URL:** `http://localhost:9411`
- **Sampling:** 100% de las trazas
- **Servicios monitoreados:** Todos los microservicios

### Actuator Endpoints
Todos los servicios incluyen Spring Boot Actuator para:
- Health checks
- Metrics
- Application info
- Environment properties

## 🚀 Tecnologías Utilizadas

### Core Technologies
- **Java:** 21 (LTS)
- **Spring Boot:** 3.5.4
- **Spring Cloud:** 2025.0.0
- **Maven:** 3.13.0
- **Lombok:** 1.18.30

### Infrastructure & Service Discovery
- **Service Registry:** Netflix Eureka Server
- **API Gateway:** Spring Cloud Gateway (WebFlux)
- **Configuration:** Spring Cloud Config Server
- **Load Balancing:** Spring Cloud LoadBalancer

### Database & Persistence
- **Base de datos:** MySQL 
- **ORM:** Spring Data JPA
- **Connector:** MySQL Connector/J

### Security & Authentication
- **OAuth2:** Spring Security OAuth2 Resource Server
- **OAuth2 Client:** Spring Security OAuth2 Client
- **Identity Provider:** Auth0 (configurado para dev-knq5qdss5uzcsuyw.us.auth0.com)
- **Authorization:** Role-based access control (RBAC)

### Monitoring & Observability
- **Distributed Tracing:** Micrometer Tracing with Brave
- **Tracing Backend:** Zipkin Reporter
- **Metrics:** Spring Boot Actuator
- **Health Checks:** Actuator Health Endpoints

### Resilience & Fault Tolerance
- **Circuit Breaker:** Resilience4j
- **Rate Limiting:** Redis (Reactive)
- **Timeout & Retry:** Resilience4j patterns

### Communication
- **HTTP Client:** OpenFeign
- **Reactive Programming:** Spring WebFlux
- **Service-to-Service:** Eureka Client Discovery

### Development & Testing
- **Build Tool:** Maven
- **Testing Framework:** Spring Boot Test
- **Code Coverage:** Jacoco
- **Code Quality:** SonarQube integration
- **Mock Testing:** WireMock (en Order Service)

### Additional Libraries
- **Reactive Redis:** Spring Data Redis Reactive
- **Jakarta Servlet:** Jakarta Servlet API
- **JSON Processing:** Incluido en Spring Boot

## 🛠️ Configuración y Ejecución

### 🐳 Docker (Recomendado)

#### Comandos Makefile Útiles
```bash
# 📋 Ver todos los comandos disponibles
make help

# 🚀 Construir y levantar todo
make up-build

# 📊 Ver estado de servicios
make status

# 🏥 Verificar salud de servicios
make health

# 📋 Ver logs en tiempo real
make logs

# 🔄 Reiniciar un servicio específico
make restart-service SERVICE=product-service

# 🌐 Abrir URLs en el navegador
make open-urls

# 🛑 Detener todo
make down

# 🧹 Limpieza completa (CUIDADO: Borra datos)
make clean
```

#### Docker Compose Directo
```bash
# Construir y levantar todos los servicios
docker-compose up -d --build

# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f

# Detener todo
docker-compose down
```

#### Scripts de Automatización
```powershell
# Windows PowerShell - Inicia todo el ecosistema
.\start-ecosystem.ps1

# Limpieza completa del entorno
.\start-ecosystem.ps1 cleanup
```

```bash
# Linux/macOS Bash - Inicia todo el ecosistema
./start-ecosystem.sh

# Limpieza completa del entorno  
./start-ecosystem.sh cleanup
```

#### URLs de Acceso (Docker)
| Servicio | URL | Descripción |
|----------|-----|-------------|
| **API Gateway** | http://localhost:9090 | Punto de entrada principal |
| **Eureka Dashboard** | http://localhost:8761 | Registry de servicios |
| **Config Server** | http://localhost:9296 | Servidor de configuración |
| **Zipkin UI** | http://localhost:9411 | Trazas distribuidas |

📋 **Para configuración manual completa, consulta:** [DOCKER_SETUP.md](./DOCKER_SETUP.md)

### 💻 Ejecución Local (Alternativa)

#### Prerrequisitos
1. Java 21
2. MySQL Server
3. Zipkin Server (puerto 9411)
4. Cuenta de Auth0 configurada

#### ⚙️ Configuración de Variables de Entorno
Antes de ejecutar los servicios, debes configurar las variables de entorno necesarias. 

**📋 Consulta el archivo `ENVIRONMENT_SETUP.md` para instrucciones detalladas.**

Variables principales requeridas:
- `DB_USERNAME` y `DB_PASSWORD` - Credenciales de MySQL
- `AUTH0_ISSUER_URI` - URI del emisor de Auth0
- `AUTH0_CLIENT_ID` y `AUTH0_CLIENT_SECRET` - Credenciales de la aplicación Auth0

#### Orden de inicio recomendado
1. **Config Server** (puerto 9296)
2. **Service Registry** (puerto 8761)
3. **Zipkin Server** (puerto 9411)
4. **Microservicios** (Order, Payment, Product)
5. **Cloud Gateway** (puerto 9090)

#### Base de datos
Crear las siguientes bases de datos en MySQL:
- `order_db` - Para Order Service
- `payment_db` - Para Payment Service
- `product_db` - Para Product Service

## � Stress Testing & Monitoreo

Una vez que tengas el ecosistema funcionando, puedes ejecutar **pruebas de carga y monitoreo en tiempo real**:

### 🚀 Inicio Rápido de Pruebas
```bash
# 1. Levantar el stack principal (requisito)
docker-compose up -d

# 2. Configurar y ejecutar stress testing
cd stress-testing/
# Seguir las instrucciones en el README de stress testing
```

### 📊 **¿Qué incluye el sistema de testing?**
- **K6**: Pruebas de carga con autenticación OAuth2
- **Grafana**: Dashboards en tiempo real  
- **InfluxDB**: Almacenamiento de métricas de testing
- **Prometheus**: Métricas de aplicaciones Spring Boot

### 📚 **Documentación Completa**
👉 **[Ver Guía Completa de Stress Testing](./stress-testing/README.md)**

La guía incluye:
- ✅ Setup paso a paso desde cero
- ✅ Configuración segura de credenciales Auth0
- ✅ Comandos listos para usar
- ✅ Troubleshooting detallado
- ✅ Dashboards pre-configurados

## �📝 Notas Adicionales

- Los microservicios utilizan configuración centralizada desde el Config Server
- Implementación de Circuit Breaker para mayor resiliencia
- Rate Limiting configurado en el API Gateway
- Trazabilidad completa de requests a través de Zipkin
- Autenticación y autorización robusta con OAuth2 y Auth0
- Arquitectura preparada para escalabilidad horizontal

## 🔧 Configuración de Desarrollo

Todas las configuraciones específicas se encuentran en el directorio `spring-boot-config` y son distribuidas automáticamente por el Config Server a todos los microservicios registrados.

---

# 🔥 STRESS TESTING & MONITOREO AVANZADO

## 📋 Resumen de lo Desarrollado en Nuestra Rama

En la rama `feature/stress-testing-k6-monitoring` hemos desarrollado una **suite completa de stress testing y monitoreo** que transforma este ecosistema de microservicios en una plataforma de testing robusta y profesional.

### 🎯 ¿Qué Incluye Nuestro Sistema de Testing?

- **🧪 K6 Testing Suite**: Pruebas de carga con autenticación OAuth2 real
- **📊 Grafana Dashboards**: 8 dashboards especializados con métricas en tiempo real
- **💾 InfluxDB**: Base de datos de series temporales para métricas
- **🐳 Docker Stack**: Stack completo de monitoreo containerizado
- **⚡ Scripts de Automatización**: Inicio completo en 130 segundos con dashboards automáticos

## 🚀 Configuración desde Cero - Paso a Paso Completo

### Paso 1: Prerequisitos del Sistema
```powershell
# Verificar Docker y Docker Compose
docker --version                 # Versión mínima: 20.x
docker-compose --version         # Versión mínima: 2.x

# Verificar PowerShell (Windows)
$PSVersionTable.PSVersion        # Versión mínima: 5.x

# Verificar Git
git --version
```

### Paso 2: Clonar y Configurar el Repositorio
```powershell
# Clonar el repositorio
git clone https://github.com/termiwum/java-springboot-oauth-okta-zipkin.git
cd java-springboot-oauth-okta-zipkin

# Cambiar a la rama de stress testing
git checkout feature/stress-testing-k6-monitoring

# Verificar que estamos en la rama correcta
git branch
```

### Paso 3: Configuración de Autenticación Auth0 (CRÍTICO)
```powershell
# Navegar al directorio de stress testing
cd stress-testing

# Copiar template de configuración OAuth2
copy oauth2-auth.js.example oauth2-auth.js

# Editar el archivo oauth2-auth.js con tus credenciales Auth0
notepad oauth2-auth.js
```

**Configurar en `oauth2-auth.js`:**
```javascript
export const auth0Config = {
  domain: 'tu-domain.auth0.com',
  clientId: 'tu-client-id',
  clientSecret: 'tu-client-secret',
  audience: 'tu-audience',
  scope: 'openid profile email Customer Admin'
};
```

### Paso 4: Arranque del Ecosistema Completo
```powershell
# Volver al directorio raíz
cd ..

# Arranque optimizado con dashboards automáticos
.\quick-start.ps1
```

**⏱️ El script ejecutará automáticamente:**
1. ✅ Build paralelo de todas las imágenes Docker (~30s)
2. ✅ Inicio secuencial de infraestructura (MySQL, Redis, Zipkin) (~20s)
3. ✅ Registro de servicios en Eureka (~15s)
4. ✅ Configuración centralizada via Config Server (~10s)
5. ✅ Levantado del API Gateway (~20s)
6. ✅ Stack de monitoreo (Grafana + InfluxDB) (~30s)
7. ✅ Importación automática de 8 dashboards (~5s)
8. ✅ Verificación de salud de todos los servicios

**⏱️ Tiempo total de despliegue:** ~130 segundos

### Paso 5: Verificación del Ecosistema
```powershell
# Ver estado de todos los contenedores
docker-compose ps

# Debe mostrar todos los servicios como "Up" y "healthy"
```

**URLs de Verificación:**
| Servicio | URL | Credenciales | Verificación |
|----------|-----|--------------|--------------|
| **API Gateway** | http://localhost:9090 | - | Debe responder JSON |
| **Eureka Dashboard** | http://localhost:8761 | - | Ver 6 servicios registrados |
| **Zipkin Tracing** | http://localhost:9411 | - | Interface de trazas |
| **Grafana** | http://localhost:3000 | admin/grafana123 | 8 dashboards importados |
| **InfluxDB** | http://localhost:8087 | - | Interface web |

### Paso 6: Poblar Bases de Datos para Testing
```powershell
cd stress-testing

# Poblar con datos de testing
.\populate-databases.ps1

# Verificar que los datos se insertaron correctamente
.\verify-databases.ps1
```

### Paso 7: Ejecutar Tests de Stress
```powershell
# Test individual de cada servicio
.\test-services.ps1 -Service product
.\test-services.ps1 -Service payment  
.\test-services.ps1 -Service order

# Test global del ecosistema (recomendado)
.\test-services.ps1 -Service ecosystem

# Tests automatizados con reportes
.\run-tests-simple.ps1
```

## 📊 Dashboards Disponibles (Auto-importados)

### Dashboards Especializados por Servicio

| Dashboard | Propósito | Métricas Clave | Panel Principal |
|-----------|-----------|----------------|----------------|
| **Ecosystem Global** | Vista general del sistema | Disponibilidad, error rates, response times | Sistema completo |
| **Product Service** | Monitoreo del catálogo | CRUD operations, inventory tracking | Gestión de productos |
| **Payment Service** | Transacciones financieras | Process/query ratio, success rates | Procesamiento de pagos |
| **Order Place** | Flujo de pedidos | Order→Product→Payment chain | Creación de pedidos |
| **Order Details** | Consultas de pedidos | Parallel queries performance | Consulta de detalles |

### Dashboards de Monitoreo K6

| Dashboard | Propósito | Métricas Clave |
|-----------|-----------|----------------|
| **K6 Auto** | Métricas de stress testing | Load test performance, thresholds |
| **K6 Simple** | Testing básico | Simple load metrics |
| **K6 Prometheus** | Métricas avanzadas | Detailed performance analytics |

## 🧪 Suite de Tests Disponibles

### Tests Individuales por Servicio

```powershell
# Test del Product Service
.\test-services.ps1 -Service product
# - 70% GET products, 30% CREATE products
# - Validación de inventory tracking
# - Métricas de CRUD operations

# Test del Payment Service  
.\test-services.ps1 -Service payment
# - 70% process payments, 30% get payment details
# - Validación de transacciones
# - Métricas de success rates

# Test del Order Service
.\test-services.ps1 -Service order
# - Flujo completo Order → Product → Payment
# - Validación de cadena de servicios
# - Métricas de business flow
```

### Test Global del Ecosistema

```powershell
# Test comprehensivo del ecosistema completo
.\test-services.ps1 -Service ecosystem
# - Combina todos los flujos de negocio
# - 40% orders, 30% products, 30% payments
# - Validación de disponibilidad del sistema
# - Métricas globales de rendimiento
```

## 📈 Monitoreo en Tiempo Real

### Métricas Clave Monitoreadas

#### Response Times
- **P50 (Mediana)**: Tiempo de respuesta del 50% de requests
- **P90**: 90% de requests responden en este tiempo o menos
- **P95**: 95% de requests responden en este tiempo o menos
- **P99**: 99% de requests responden en este tiempo o menos

#### Business Metrics
- **Order Success Rate**: % de órdenes completadas exitosamente
- **Payment Processing Time**: Tiempo promedio de procesamiento de pagos
- **Product Availability**: % de productos disponibles en inventario
- **Service Chain Duration**: Tiempo total Order→Product→Payment

#### System Metrics
- **Error Rates**: Por servicio y global
- **Throughput**: Requests por segundo por servicio
- **Availability**: Uptime de cada microservicio
- **Resource Usage**: CPU, memoria, network por contenedor

### Alerting y Umbrales Configurados

```javascript
// Umbrales configurados en K6
checks: {
  'http_req_duration': ['p(95)<2000'],  // 95% < 2s
  'http_req_failed': ['rate<0.05'],     // Error rate < 5%
  'ecosystem_availability': ['rate>0.99'] // Availability > 99%
}
```

## 🛡️ Seguridad en Testing

### Autenticación OAuth2 Real
- **Flujo OAuth2**: Client Credentials Grant
- **Tokens JWT**: Validación real con Auth0
- **Roles y Scopes**: Customer, Admin, internal
- **Rate Limiting**: Validación de límites del API Gateway

### Gestión Segura de Credenciales
```powershell
# Las credenciales se manejan via archivo local
stress-testing/oauth2-auth.js  # No versionado en Git

# Variables de entorno para CI/CD
AUTH0_DOMAIN=tu-domain.auth0.com
AUTH0_CLIENT_ID=tu-client-id
AUTH0_CLIENT_SECRET=tu-client-secret
```

## 🔄 Scripts de Gestión del Ecosistema

### Scripts Principales Desarrollados

| Script | Función | Características | Tiempo Ejecución |
|--------|---------|----------------|------------------|
| `quick-start.ps1` | Arranque completo optimizado | Build paralelo, importación automática dashboards | ~130s |
| `stop-ecosystem.ps1` | Parada limpia del ecosistema | Limpieza opcional de volúmenes | ~10s |
| `test-services.ps1` | Tests individuales de servicios | Por servicio o ecosistema completo | ~60s |
| `populate-databases.ps1` | Datos de testing | Productos, usuarios, configuración | ~5s |
| `import-dashboards-fixed.ps1` | Re-importar dashboards | 8 dashboards con validación | ~10s |

### Ejemplos de Uso

```powershell
# Arranque completo del ecosistema
.\quick-start.ps1

# Verificación de estado
docker-compose ps

# Ejecutar test del ecosistema completo  
cd stress-testing
.\test-services.ps1 -Service ecosystem

# Ver resultados en Grafana
# http://localhost:3000 (admin/grafana123)

# Parar todo el ecosistema con limpieza completa
cd ..
.\stop-ecosystem.ps1 -Force -Volumes
```

## 🔄 Automatización de CI/CD

### Workflow de Testing Automatizado

```powershell
# 1. Limpieza completa del entorno
.\stop-ecosystem.ps1 -Force -Volumes

# 2. Arranque completo automatizado
.\quick-start.ps1

# 3. Validación automática post-deploy
cd stress-testing
.\verify-databases.ps1
.\populate-databases.ps1

# 4. Ejecución de tests
.\test-services.ps1 -Service ecosystem

# 5. Reporte de resultados (en dashboards Grafana)
```

### Integración con CI/CD

El ecosistema está preparado para integrarse con pipelines de CI/CD:
- **Docker Compose**: Toda la infraestructura en contenedores
- **Health Checks**: Validación automática de servicios
- **Exit Codes**: Scripts retornan códigos de error apropiados
- **Métricas**: Reportes en formato JSON para análisis automático

## 🎯 Resultados Esperados Después del Setup

Después de completar todos los pasos deberías tener:

### ✅ Servicios Funcionando (8 Contenedores)
- Spring Boot Microservices: cloud-gateway, order-service, payment-service, product-service
- Infrastructure: service-registry, config-server, zipkin, mysql, redis
- Monitoring Stack: grafana, influxdb

### ✅ Dashboards Importados (8 Dashboards)
- Ecosystem Global Dashboard
- Product Service Dashboard  
- Payment Service Dashboard
- Order Place Dashboard
- Order Details Dashboard
- K6 Auto Dashboard
- K6 Simple Dashboard
- K6 Prometheus Dashboard

### ✅ Tests de Stress Listos
- Tests individuales por servicio
- Test global del ecosistema
- Autenticación OAuth2 funcionando
- Métricas en tiempo real

### ✅ Monitoreo Completo
- Trazabilidad distribuida con Zipkin
- Métricas de negocio en Grafana
- Alerting configurado
- Resource monitoring

## 📚 Documentación Detallada Adicional

- **[Guía Completa de Stress Testing](./stress-testing/TESTING_GUIDE.md)** - Setup detallado y troubleshooting
- **[Configuración de Monitoreo](./stress-testing/README.md)** - Dashboards y métricas
- **[Setup de Docker](./DOCKER_SETUP.md)** - Configuración de contenedores
- **[Variables de Entorno](./ENVIRONMENT_SETUP.md)** - Configuración de credenciales

## 🚨 Troubleshooting Común

### Problema: Dashboards no se importan automáticamente
```powershell
# Solución: Re-importar manualmente
cd stress-testing
.\import-dashboards-fixed.ps1
```

### Problema: Tests fallan por autenticación
```powershell
# Verificar configuración OAuth2
notepad stress-testing\oauth2-auth.js
# Asegurar credenciales Auth0 correctas
```

### Problema: Servicios no se registran en Eureka
```powershell
# Verificar orden de inicio
.\stop-ecosystem.ps1 -Force
.\quick-start.ps1
# El script maneja el orden correcto automáticamente
```

---

Este ecosistema representa una implementación completa y profesional de testing de microservicios con monitoreo en tiempo real, listo para entornos de producción y perfectamente integrado con metodologías DevOps modernas.
