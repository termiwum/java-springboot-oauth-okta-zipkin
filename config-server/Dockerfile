# Usar una imagen base de Java 21
FROM openjdk:21-jdk-slim

ARG JAR_FILE=target/*.jar

COPY ${JAR_FILE} configserver.jar

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar configserver.jar"]

EXPOSE 9296
