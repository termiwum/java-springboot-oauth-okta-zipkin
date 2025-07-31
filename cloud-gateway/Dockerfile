# Usar una imagen base de Java 21
FROM openjdk:21-jdk-slim

ARG JAR_FILE=target/*.jar

COPY ${JAR_FILE} cloudgateway.jar

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar cloudgateway.jar"]

EXPOSE 9090
