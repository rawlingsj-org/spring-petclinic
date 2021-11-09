# FROM tomcat:9.0-alpine
# LABEL version = "1.1.3"
# COPY target/spring-petclinic*.jar /usr/local/tomcat/webapps/ROOT/petclinic.jar

FROM openjdk:10

RUN export
WORKDIR /app
COPY target/spring-petclinic*.jar /app/app.jar

CMD java -Dserver.port=${SERVER_PORT:-}\
          -Dserver.context-path=/petclinic/\
          -Dspring.messages.basename=messages/messages\
          -Dlogging.level.org.springframework=${LOG_LEVEL:-INFO}\
          -Dsecurity.ignored=${SECURITY_IGNORED:-/**}\
          -Dbasic.authentication.enabled=${AUTHENTICATION_ENABLED:-false}\
          -Dserver.address=${SERVER_ADDRESS:-0.0.0.0}\
          -jar /app/app.jar