# Config Server

Servidor de configuración centralizada con Spring Cloud Config.

## Tecnologías utilizadas

- Java 17
- Spring Boot 3.5.1-SNAPSHOT
- Spring Cloud Config Server
- Spring Cloud Netflix Eureka Client
- Micrometer Tracing (Brave)
- Zipkin Reporter
- Maven

## Descripción

Este proyecto provee configuración centralizada para los microservicios, con integración a Eureka y trazabilidad con Zipkin.

## Ejecución

```
mvn clean install
mvn spring-boot:run
```

## Configuración

Configura los repositorios de configuración en `src/main/resources/application.properties` o `application.yml`.
