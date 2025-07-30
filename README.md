# Java SpringBoot OAuth Okta Zipkin - Microservices Architecture

Este workspace contiene una arquitectura completa de microservicios construida con Spring Boot, implementando autenticación OAuth2 con Okta y monitoreo distribuido con Zipkin.

## 📋 Resumen de Proyectos

### 🌐 Cloud Gateway (`cloud-gateway`)
**Puerto:** 9090  
**Propósito:** API Gateway principal que actúa como punto de entrada único para todos los microservicios.

**Características principales:**
- **Tecnología:** Spring Cloud Gateway con WebFlux
- **Autenticación:** OAuth2 con Okta
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
- **Seguridad:** OAuth2 Resource Server con Okta
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
- **Seguridad:** OAuth2 Resource Server con Okta
- **Autorización:** Acceso para Customer, Admin y SCOPE_internal
- **Monitoreo:** Zipkin sleuth integration
- **Comunicación:** Eureka client para service discovery

### 🛍️ Product Service (`product-service`)
**Puerto:** No especificado  
**Propósito:** Gestión del catálogo de productos.

**Características principales:**
- **Base de datos:** MySQL
- **Seguridad:** OAuth2 Resource Server con Okta
- **Autorización:** Basada en roles y scopes
- **API:** RESTful endpoints para gestión de productos
- **Monitoreo:** Integración con Zipkin

### 📁 Spring Boot Config (`spring-boot-config`)
**Propósito:** Archivos de configuración compartidos para todos los servicios.

**Configuraciones incluidas:**
- **Eureka Client:** Configuración para service discovery
- **Zipkin:** Configuración de tracing distribuido (100% sampling)
- **OAuth2:** Configuración de Okta issuer y audience
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

### OAuth2 con Okta
- **Issuer:** `https://dev-02439493.okta.com/oauth2/default`
- **Audience:** `api://default`
- **Grant Types:** Authorization Code, Client Credentials
- **Scopes:** internal, custom scopes

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

- **Framework:** Spring Boot 2.7.3 / 3.5.1-SNAPSHOT
- **Java:** 11 / 17
- **Spring Cloud:** 2021.0.3 / 2025.0.0
- **Base de datos:** MySQL
- **Service Discovery:** Netflix Eureka
- **API Gateway:** Spring Cloud Gateway
- **Autenticación:** OAuth2 + Okta
- **Monitoreo:** Zipkin + Spring Cloud Sleuth
- **Build Tool:** Maven
- **Testing:** JUnit + Jacoco + SonarQube

## 🛠️ Configuración y Ejecución

### Prerrequisitos
1. Java 11/17
2. MySQL Server
3. Zipkin Server (puerto 9411)
4. Cuenta de Okta configurada

### Orden de inicio recomendado
1. **Config Server** (puerto 9296)
2. **Service Registry** (puerto 8761)
3. **Zipkin Server** (puerto 9411)
4. **Microservicios** (Order, Payment, Product)
5. **Cloud Gateway** (puerto 9090)

### Base de datos
Crear las siguientes bases de datos en MySQL:
- `order_db` - Para Order Service
- Bases de datos adicionales para Payment y Product Services

## 📝 Notas Adicionales

- Los microservicios utilizan configuración centralizada desde el Config Server
- Implementación de Circuit Breaker para mayor resiliencia
- Rate Limiting configurado en el API Gateway
- Trazabilidad completa de requests a través de Zipkin
- Autenticación y autorización robusta con OAuth2 y Okta
- Arquitectura preparada para escalabilidad horizontal

## 🔧 Configuración de Desarrollo

Todas las configuraciones específicas se encuentran en el directorio `spring-boot-config` y son distribuidas automáticamente por el Config Server a todos los microservicios registrados.
