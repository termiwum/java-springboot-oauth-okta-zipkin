# Usar una imagen base de Java 21
FROM openjdk:21-jdk-slim

ARG JAR_FILE=target/*.jar

COPY ${JAR_FILE} serviceregistry.jar

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar serviceregistry.jar"]

EXPOSE 8761
