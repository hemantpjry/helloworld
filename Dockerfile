FROM tomcat:9.0.82-jdk21-temurin
LABEL maintainer="hemanthpoojary27@gmail.com"
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY target/helloworld-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
RUN useradd -m hello-world && \
    chown -R hello-world:hello-world /usr/local/tomcat
USER hello-world
EXPOSE 8080
CMD ["catalina.sh", "run"]