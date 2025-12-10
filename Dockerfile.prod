# Use Alpine as the base image for a lightweight container.
FROM liquibase:4.30-alpine

# Set environment variables for Liquibase and database connection.
ENV CONTEXTS=local
ENV DB_URL=jdbc:mariadb://evocelot-mariadb:3306/sample
ENV DB_USERNAME=root
ENV DB_PASSWORD=admin
ENV DB_DRIVER=org.mariadb.jdbc.Driver

# Create necessary directories.
RUN mkdir -p /liquibase/changelog

# Add your Liquibase changelog files into the container.
COPY ./changelog /liquibase/changelog

# Set the working directory.
WORKDIR /liquibase

# Start Liquibase container with parameters.
ENTRYPOINT ["sh", "-c", "liquibase --contexts=${CONTEXTS} --url=${DB_URL} --username=${DB_USERNAME} --password=${DB_PASSWORD} --changelog-file=/changelog/changelog.xml --driver=${DB_DRIVER} update"]

# Expose necessary ports.
EXPOSE 3306
