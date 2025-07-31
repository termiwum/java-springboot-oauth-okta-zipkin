# Config Server

Servidor de configuración centralizada para todos los microservicios de la arquitectura.

## 🚀 Tecnologías utilizadas

### Core
- **Java:** 21 (LTS)
- **Spring Boot:** 3.5.4
- **Spring Cloud:** 2025.0.0
- **Maven:** 3.13.0

### Configuration Management
- **Spring Cloud Config Server:** Servidor de configuración centralizada
- **Spring Cloud Starter:** Utilidades base de Spring Cloud

### Service Integration
- **Netflix Eureka Client:** Service discovery y registro
- **Jakarta Servlet API:** Compatibilidad con servlets

### Observability & Monitoring
- **Spring Boot Actuator:** Métricas y health checks
- **Micrometer Tracing Brave:** Trazabilidad distribuida
- **Zipkin Reporter:** Envío de trazas a Zipkin

### Development Tools
- **Lombok:** 1.18.30 - Reducción de código boilerplate
- **Spring Boot Test:** Framework de testing

## Descripción

Este microservicio provee configuración centralizada para todos los servicios de la arquitectura. Características principales:

- **Gestión centralizada** de propiedades de configuración
- **Integración con Eureka** para service discovery
- **Trazabilidad completa** con Zipkin
- **Health checks** y métricas con Actuator
- **Configuración dinámica** sin reinicio de servicios

## Puerto
**9296**

## Funcionalidades
- Distribución automática de configuraciones
- Versionado de configuraciones
- Refresh de configuración en tiempo real
- Integración con repositorios Git (configurable)
- Perfiles de configuración por ambiente

## Ejecución

### Prerrequisitos
1. Java 21 instalado
2. Maven 3.13.0+

### Comandos
```powershell
# Compilar y empaquetar
mvn clean install

# Ejecutar el servicio
mvn spring-boot:run
```

### Verificación
- Config Server disponible en: `http://localhost:9296`
- Health check: `http://localhost:9296/actuator/health`

## Configuración

Configura los repositorios de configuración en `src/main/resources/application.yml`.
