# Cloud Gateway

Gateway API reactivo para microservicios con autenticación OAuth2 y monitoreo distribuido.

## 🚀 Tecnologías utilizadas

### Core
- **Java:** 21 (LTS)
- **Spring Boot:** 3.5.4
- **Spring Cloud:** 2025.0.0
- **Maven:** 3.13.0

### Gateway & Reactive Programming
- **Spring Cloud Gateway:** Routing y filtros
- **Spring WebFlux:** Programación reactiva
- **Spring Cloud LoadBalancer:** Balanceador de carga

### Security & Authentication
- **Spring Security:** Framework de seguridad
- **Auth0:** Identity Provider configurado
- **OAuth2 Client:** Autenticación OAuth2
- **OAuth2 Resource Server:** Validación de tokens

### Service Integration
- **Netflix Eureka Client:** Service discovery
- **Spring Cloud Config:** Configuración centralizada
- **Spring Cloud Starter:** Utilidades de Spring Cloud

### Resilience & Performance
- **Resilience4j:** Circuit breaker
- **Spring Data Redis Reactive:** Rate limiting y cache
- **Spring Boot Actuator:** Monitoreo y métricas

### Observability
- **Micrometer Tracing Brave:** Trazabilidad distribuida
- **Zipkin Reporter:** Envío de trazas a Zipkin

### Development Tools
- **Lombok:** 1.18.30 - Reducción de código boilerplate
- **Spring Boot Test:** Testing framework
- **Reactor Test:** Testing reactivo

## Descripción

Este proyecto implementa un gateway reactivo que actúa como punto de entrada único para todos los microservicios. Proporciona:

- **Enrutamiento inteligente** hacia microservicios
- **Autenticación y autorización** con OAuth2 + Auth0
- **Balanceador de carga** integrado con Eureka
- **Circuit breaker** para resiliencia
- **Rate limiting** con Redis
- **Monitoreo distribuido** con Zipkin

## Puerto
**9090**

## Rutas configuradas
- `/orders/**` → ORDER-SERVICE
- `/payments/**` → PAYMENT-SERVICE  
- `/products/**` → PRODUCT-SERVICE

## Ejecución

### Prerrequisitos
1. Java 21 instalado
2. Maven 3.13.0+
3. Variables de entorno configuradas (ver `ENVIRONMENT_SETUP.md`)
4. Config Server ejecutándose (puerto 9296)
5. Service Registry ejecutándose (puerto 8761)

### Comandos
```powershell
# Compilar y empaquetar
mvn clean install

# Ejecutar el servicio
mvn spring-boot:run
```

### Verificación
- Gateway disponible en: `http://localhost:9090`
- Health check: `http://localhost:9090/actuator/health`
- Rutas configuradas disponibles tras autenticación OAuth2

## Configuración

Las configuraciones se obtienen automáticamente del Config Server. Variables de entorno requeridas:
- `AUTH0_ISSUER_URI`
- `AUTH0_CLIENT_ID`
- `AUTH0_CLIENT_SECRET`
