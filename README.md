# Cloud Gateway

Gateway API para microservicios.

## Tecnologías utilizadas

- Java 17
- Spring Boot 2.7.3
- Spring Cloud Gateway
- Spring Cloud (Eureka Client, Config, Sleuth, Zipkin, CircuitBreaker Resilience4j)
- Spring WebFlux
- Spring Data Redis Reactive
- Lombok
- Spring Security
- Okta (OAuth2)
- Maven

## Descripción

Este proyecto implementa un gateway reactivo para enrutar y proteger los microservicios, con balanceo, resiliencia y trazabilidad.

## Ejecución

```
mvn clean install
mvn spring-boot:run
```

## Configuración

Configura las rutas y seguridad en `src/main/resources/application.properties` o `application.yml`.
