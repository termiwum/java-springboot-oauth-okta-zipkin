# Usar una imagen base de Java 21
FROM openjdk:21-jdk-slim

ARG JAR_FILE=target/*.jar

COPY ${JAR_FILE} orderservice.jar

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar orderservice.jar"]

EXPOSE 8082
