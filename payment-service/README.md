# Payment Service

Microservicio de procesamiento de pagos con seguridad OAuth2 y monitoreo distribuido.

## 🚀 Tecnologías utilizadas

### Core
- **Java:** 21 (LTS)
- **Spring Boot:** 3.5.4
- **Spring Cloud:** 2025.0.0
- **Maven:** 3.13.0

### Web & API
- **Spring Boot Web:** APIs REST
- **Spring Data JPA:** Persistencia y ORM

### Database
- **MySQL Connector/J:** Conector de base de datos
- **Base de datos:** MySQL

### Service Integration
- **Netflix Eureka Client:** Service discovery
- **Spring Cloud Config:** Configuración centralizada
- **Spring Cloud Starter:** Utilidades base de Spring Cloud

### Security & Authentication
- **Spring Security:** Framework de seguridad
- **OAuth2 Resource Server:** Validación de tokens JWT

### Observability & Monitoring
- **Micrometer Tracing Brave:** Trazabilidad distribuida
- **Zipkin Reporter:** Envío de trazas a Zipkin

### Development Tools
- **Lombok:** 1.18.30 - Reducción de código boilerplate
- **Spring Boot Test:** Framework de testing

## Descripción

Este microservicio se encarga del procesamiento seguro de pagos y transacciones financieras. Características principales:

- **Procesamiento de pagos** con validación de transacciones
- **Integración con Order Service** para completar pedidos
- **Autenticación OAuth2** con validación de tokens JWT
- **Autorización multi-scope** (Customer, Admin, SCOPE_internal)
- **Trazabilidad completa** con Zipkin
- **Health monitoring** con Actuator

## Funcionalidades
- Procesamiento de transacciones de pago
- Validación de métodos de pago
- Integración con servicios externos de pago
- Gestión de estados de transacción
- Logs auditables de todas las transacciones

## Security & Authorization
- **Customer:** Puede procesar sus propios pagos
- **Admin:** Acceso completo a todas las transacciones
- **SCOPE_internal:** Para comunicación con otros microservicios

## Base de datos
- **Motor:** MySQL
- **Configuración:** Variables de entorno DB_USERNAME y DB_PASSWORD

## Observabilidad
- **Trazas distribuidas:** Enviadas a Zipkin
- **Métricas:** Disponibles via Actuator endpoints
- **Health checks:** Estado del servicio y dependencias

## Ejecución

### Prerrequisitos
1. Java 21 instalado
2. Maven 3.13.0+
3. MySQL Server ejecutándose
4. Variables de entorno configuradas (ver `ENVIRONMENT_SETUP.md`)
5. Config Server ejecutándose (puerto 9296)
6. Service Registry ejecutándose (puerto 8761)

### Comandos
```powershell
# Compilar y empaquetar
mvn clean install

# Ejecutar el servicio
mvn spring-boot:run
```

### Verificación
- Payment Service registrado en Eureka
- Health check: `http://localhost:{puerto}/actuator/health`

## Configuración

Variables de entorno requeridas:
- `DB_USERNAME` y `DB_PASSWORD` - Credenciales de MySQL
- `AUTH0_ISSUER_URI` - Configuración de Auth0
