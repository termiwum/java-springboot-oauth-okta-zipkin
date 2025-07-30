# Product Service

Servicio de productos desarrollado con Spring Boot.

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

Este microservicio gestiona la información de productos y se integra con otros servicios mediante Eureka y Spring Cloud Config. Incluye trazabilidad con Sleuth y Zipkin, y seguridad con Okta.

## Ejecución

```
mvn clean install
mvn spring-boot:run
```

## Configuración

Configura la conexión a la base de datos en `src/main/resources/application.properties` o `application.yml`.
