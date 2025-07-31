# Service Registry

Servidor de registro y descubrimiento de servicios usando Netflix Eureka.

## 🚀 Tecnologías utilizadas

### Core
- **Java:** 21 (LTS)
- **Spring Boot:** 3.5.4
- **Spring Cloud:** 2025.0.0
- **Maven:** 3.13.0

### Service Discovery
- **Netflix Eureka Server:** Servidor de registro de servicios
- **Spring Cloud Starter:** Utilidades base de Spring Cloud

### Development Tools
- **Lombok:** 1.18.30 - Reducción de código boilerplate
- **Spring Boot Test:** Framework de testing

## Descripción

Este microservicio implementa el patrón Service Registry usando Netflix Eureka Server. Funcionalidades principales:

- **Registro automático** de microservicios
- **Descubrimiento de servicios** para comunicación inter-servicio
- **Health monitoring** de servicios registrados
- **Load balancing** entre instancias de servicios
- **Dashboard web** para visualizar servicios registrados

## Puerto
**8761**

## Características
- Auto-registro de servicios al arrancar
- Heartbeat automático para health checking
- Balanceador de carga integrado
- Interfaz web de administración
- Tolerancia a fallos en la red
- Clustering de servidores Eureka (configurable)

## Dashboard
Accede a la interfaz web en: `http://localhost:8761`

## Servicios Registrados
Los siguientes servicios se registran automáticamente:
- **CONFIG-SERVER** (puerto 9296)
- **CLOUD-GATEWAY** (puerto 9090) 
- **ORDER-SERVICE** (puerto 8082)
- **PAYMENT-SERVICE**
- **PRODUCT-SERVICE**

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
- Dashboard Eureka disponible en: `http://localhost:8761`
- Health check: `http://localhost:8761/actuator/health`

## Configuración

Configura los parámetros de Eureka en `src/main/resources/application.yml`.
