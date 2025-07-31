# Order Service

Microservicio de gestión de pedidos con comunicación inter-servicio y seguridad OAuth2.

## 🚀 Tecnologías utilizadas

### Core
- **Java:** 21 (LTS)
- **Spring Boot:** 3.5.4
- **Spring Cloud:** 2025.0.0
- **Maven:** 3.13.0

### Web & API
- **Spring Boot Web:** APIs REST
- **Spring Data JPA:** Persistencia y ORM
- **Spring Cloud LoadBalancer:** Balanceador de carga

### Database
- **MySQL Connector/J:** Conector de base de datos
- **Base de datos:** MySQL (order_db)

### Service Communication
- **Spring Cloud OpenFeign:** Cliente HTTP declarativo
- **Netflix Eureka Client:** Service discovery
- **Spring Cloud Config:** Configuración centralizada

### Security & Authentication
- **Spring Security:** Framework de seguridad
- **OAuth2 Client:** Cliente OAuth2
- **OAuth2 Resource Server:** Validación de tokens JWT

### Resilience & Fault Tolerance
- **Resilience4j Circuit Breaker:** Patrón circuit breaker
- **Resilience4j:** Timeout, retry, bulkhead patterns

### Observability & Monitoring
- **Spring Boot Actuator:** Métricas y health checks
- **Micrometer Tracing Brave:** Trazabilidad distribuida
- **Zipkin Reporter:** Envío de trazas a Zipkin

### Testing & Quality
- **Spring Boot Test:** Framework de testing
- **Jacoco:** Cobertura de código
- **SonarQube:** Análisis de calidad de código
- **WireMock:** Mocking de servicios externos (en tests)

### Development Tools
- **Lombok:** Reducción de código boilerplate

## Descripción

Este microservicio gestiona el ciclo completo de pedidos y coordina la comunicación con otros servicios. Características principales:

- **Gestión de pedidos** con lógica de negocio completa
- **Comunicación con Payment Service** usando Feign Client
- **Comunicación con Product Service** para validación de inventario
- **Autenticación OAuth2** con Auth0
- **Autorización basada en roles** (Customer, Admin)
- **Circuit breaker** para resiliencia ante fallos
- **Trazabilidad completa** de requests

## Puerto
**8082**

## Endpoints principales
- `POST /orders/placeOrder` - Crear pedido (Customer)
- `GET /orders/{orderId}` - Obtener detalles de pedido (Admin/Customer)

## Base de datos
- **Nombre:** order_db
- **Motor:** MySQL
- **Configuración:** Variables de entorno DB_USERNAME y DB_PASSWORD

## Roles y Autorización
- **Customer:** Puede crear y ver sus propios pedidos
- **Admin:** Acceso completo a todos los pedidos
- **SCOPE_internal:** Para comunicación entre servicios

## Ejecución

### Prerrequisitos
1. Java 21 instalado
2. Maven 3.13.0+
3. MySQL Server ejecutándose
4. Base de datos `order_db` creada
5. Variables de entorno configuradas (ver `ENVIRONMENT_SETUP.md`)
6. Config Server ejecutándose (puerto 9296)
7. Service Registry ejecutándose (puerto 8761)

### Comandos
```powershell
# Compilar y empaquetar
mvn clean install

# Ejecutar el servicio
mvn spring-boot:run
```

### Verificación
- Order Service disponible en: `http://localhost:8082`
- Health check: `http://localhost:8082/actuator/health`
- Swagger UI (si configurado): `http://localhost:8082/swagger-ui.html`

## Configuración

Variables de entorno requeridas:
- `DB_USERNAME` y `DB_PASSWORD` - Credenciales de MySQL
- `AUTH0_ISSUER_URI`, `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET` - Auth0 config
