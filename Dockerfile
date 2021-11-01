FROM tomcat:9.0-alpine
LABEL version = "1.1.3"
COPY target/spring-petclinic*.jar /usr/local/tomcat/webapps/petclinic.jar