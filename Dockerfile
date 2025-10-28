FROM tomcat:9.0.82-jdk21-temurin
LABEL maintainer="hemanthpoojary27@gmail.com"
RUN rm -rf /usr/local/tomcat/webapps/ROOT
RUN useradd -m hello-world
COPY ./target/helloworld*.war /usr/local/tomcat/webapps/
RUN chown -R hello-world:hello-world /usr/local/tomcat
USER hello-world
EXPOSE 8080
CMD ["catalina.sh", "run"]