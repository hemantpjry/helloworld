FROM eclipse-temurin:21-jdk
LABEL maintainer="hemanthpoojary27@gmail.com"
RUN useradd -m hello-world
WORKDIR /app
COPY target/helloworld*.jar app.jar
RUN chown -R hello-world:hello-world /app
USER hello-world
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]