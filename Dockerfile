# Multi-stage Dockerfile for building and running the Spring Boot gateway
# Builder stage: use Gradle image to build the fat jar
FROM gradle:7.6-jdk17 AS builder
WORKDIR /home/gradle/project
COPY --chown=gradle:gradle . .
# Build the boot jar (skip tests to speed up builds; remove -x test if you want tests)
RUN gradle bootJar --no-daemon -x test

# Runtime stage: use a slim JRE image
FROM eclipse-temurin:17-jre
WORKDIR /app
# Copy the jar produced by the builder stage
ARG JAR_FILE=build/libs/*.jar
COPY --from=builder /home/gradle/project/${JAR_FILE} app.jar

# Use the same port as configured in application.properties
EXPOSE 8100

# Allow passing extra JVM options at runtime
ENV JAVA_OPTS="-Xms256m -Xmx512m"

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]
