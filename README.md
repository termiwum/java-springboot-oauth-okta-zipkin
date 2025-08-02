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
