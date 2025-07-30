# Payment Service

Servicio de pagos desarrollado con Spring Boot.

## Tecnologías utilizadas

- Java 11
- Spring Boot 2.7.3
- Spring Data JPA
- Spring Web
- Spring Cloud (Eureka Client, Config, Sleuth, Zipkin)
- MySQL
- Lombok
- Spring Security
- Okta (OAuth2)
- Maven

## Descripción

Este microservicio gestiona los pagos y se integra con otros servicios mediante Eureka y Spring Cloud Config. Incluye trazabilidad y seguridad OAuth2.

## Ejecución

```
mvn clean install
mvn spring-boot:run
```

## Configuración

Configura la base de datos y endpoints en `src/main/resources/application.properties` o `application.yml`.
