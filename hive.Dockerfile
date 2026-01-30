FROM apache/hive:3.1.3

USER root

# Download PostgreSQL JDBC driver
ADD --chmod=644 https://jdbc.postgresql.org/download/postgresql-42.7.1.jar /opt/hive/lib/postgresql-42.7.1.jar

# Install netcat for healthcheck
RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

# Create scratch directories with correct permissions
RUN mkdir -p /tmp/hive/local && chmod -R 777 /tmp/hive

# Copy entrypoint script
COPY --chmod=755 hive-entrypoint.sh /opt/hive/hive-entrypoint.sh

USER hive

ENTRYPOINT ["/opt/hive/hive-entrypoint.sh"]
