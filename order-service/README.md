# Order Service

Servicio de órdenes desarrollado con Spring Boot.

## Tecnologías utilizadas

- Java 11
- Spring Boot 2.7.3
- Spring Data JPA
- Spring Web
- Spring Cloud (Eureka Client, Config, Sleuth, Zipkin, OpenFeign, LoadBalancer, CircuitBreaker Resilience4j)
- MySQL, H2 (runtime)
- Lombok
- Spring Security, OAuth2 Client, Okta
- WireMock (tests)
- Jacoco (coverage)
- Maven

## Descripción

Este microservicio gestiona las órdenes y se comunica con otros servicios usando Feign y Eureka. Incluye balanceo de carga, tolerancia a fallos y seguridad OAuth2.

## Ejecución

```
mvn clean install
mvn spring-boot:run
```

## Configuración

Configura la base de datos y endpoints en `src/main/resources/application.properties` o `application.yml`.
