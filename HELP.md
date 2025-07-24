# Service Registry

Este proyecto es un servidor Eureka para el registro y descubrimiento de microservicios en un entorno Spring Cloud.

## Estructura principal
- `src/main/java/com/termiwum/service_registry/ServiceRegistryApplication.java`: Clase principal Spring Boot.
- `src/main/resources/application.yml`: Configuración de Eureka Server.
- `src/test/java/com/termiwum/service_registry/ServiceRegistryApplicationTests.java`: Prueba básica de contexto.
- `pom.xml`: Dependencias y configuración de Maven.

## Uso
1. Ejecuta el proyecto con Maven o tu IDE favorito.
2. Accede a la consola Eureka en `http://localhost:8761`.

## Notas
- Asegúrate de tener Java 11+ y Maven instalados.
- Este proyecto es solo para fines de desarrollo y pruebas.

---

# Read Me First
La siguiente información fue generada automáticamente por Spring Initializr y Maven.

* El nombre de paquete original 'com.termiwum.service-registry' es inválido; se usa 'com.termiwum.service_registry'.
* Consulta la documentación oficial de Spring Boot y Maven para más detalles.

# Getting Started

### Reference Documentation
For further reference, please consider the following sections:

* [Official Apache Maven documentation](https://maven.apache.org/guides/index.html)
* [Spring Boot Maven Plugin Reference Guide](https://docs.spring.io/spring-boot/4.0.0-SNAPSHOT/maven-plugin)
* [Create an OCI image](https://docs.spring.io/spring-boot/4.0.0-SNAPSHOT/maven-plugin/build-image.html)

### Maven Parent overrides

Due to Maven's design, elements are inherited from the parent POM to the project POM.
While most of the inheritance is fine, it also inherits unwanted elements like `<license>` and `<developers>` from the parent.
To prevent this, the project POM contains empty overrides for these elements.
If you manually switch to a different parent and actually want the inheritance, you need to remove those overrides.

