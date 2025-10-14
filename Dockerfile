FROM tomcat:11.0-jdk17

# Copy the WAR file
COPY target/taskmanager-webapp.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]