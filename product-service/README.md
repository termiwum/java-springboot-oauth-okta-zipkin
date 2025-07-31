# Product Service

Microservicio de gestión de catálogo de productos con seguridad OAuth2 y trazabilidad distribuida.

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
- **Lombok:** Reducción de código boilerplate
- **Spring Boot Test:** Framework de testing

## Descripción

Este microservicio gestiona el catálogo completo de productos y su información asociada. Características principales:

- **Gestión de productos** con CRUD completo
- **Validación de inventario** para otros servicios
- **Autenticación OAuth2** con tokens JWT
- **Autorización basada en roles** y scopes
- **Trazabilidad completa** con Zipkin
- **APIs RESTful** para operaciones de productos

## Funcionalidades
- Gestión de catálogo de productos
- Control de inventario y stock
- Búsqueda y filtrado de productos
- Gestión de categorías y atributos
- Validación de disponibilidad para pedidos

## Security & Authorization
- **Customer:** Puede consultar productos disponibles
- **Admin:** Gestión completa del catálogo
- **SCOPE_internal:** Para validaciones desde otros servicios

## Base de datos
- **Motor:** MySQL
- **Configuración:** Variables de entorno DB_USERNAME y DB_PASSWORD

## APIs principales
- `GET /products` - Listar productos
- `GET /products/{id}` - Obtener producto específico
- `POST /products` - Crear producto (Admin)
- `PUT /products/{id}` - Actualizar producto (Admin)
- `DELETE /products/{id}` - Eliminar producto (Admin)
- `GET /products/{id}/availability` - Verificar disponibilidad

## Observabilidad
- **Trazas distribuidas:** Enviadas a Zipkin para monitoreo
- **Health checks:** Estado del servicio y conexiones
- **Métricas:** Disponibles via endpoints de Actuator

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
- Product Service registrado en Eureka
- Health check: `http://localhost:{puerto}/actuator/health`

## Configuración

Variables de entorno requeridas:
- `DB_USERNAME` y `DB_PASSWORD` - Credenciales de MySQL
- `AUTH0_ISSUER_URI` - Configuración de Auth0
