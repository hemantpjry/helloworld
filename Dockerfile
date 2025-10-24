FROM tomcat:9.0.82-jdk21-temurin
LABEL maintainer="hemanthpoojary27@gmail.com"
RUN rm -rf /usr/local/tomcat/webapps/ROOT
RUN useradd -m hello-world
COPY ./target/helloworld*.war  /usr/local/tomcat/webapps/
EXPOSE 8080
USER hello-world
CMD ["catalina.sh","run"]