#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
wait_for_postgres() {
    echo "Waiting for PostgreSQL to be ready..."
    while ! nc -z postgresql 5432; do
        sleep 1
    done
    echo "PostgreSQL is ready!"
}

# Initialize schema for metastore (only run once)
init_schema() {
    echo "Checking if schema needs to be initialized..."

    # Try to initialize schema - schematool will fail gracefully if already done
    if /opt/hive/bin/schematool -dbType postgres -initSchema -verbose 2>&1; then
        echo "Schema initialized successfully"
    else
        echo "Schema might already exist, continuing..."
    fi
}

# Main logic based on SERVICE_NAME
case "$SERVICE_NAME" in
    metastore)
        wait_for_postgres
        init_schema
        echo "Starting Hive Metastore..."
        exec /opt/hive/bin/hive --service metastore
        ;;
    hiveserver2)
        echo "Starting HiveServer2..."
        exec /opt/hive/bin/hive --service hiveserver2
        ;;
    *)
        echo "Unknown SERVICE_NAME: $SERVICE_NAME"
        echo "Set SERVICE_NAME to 'metastore' or 'hiveserver2'"
        exit 1
        ;;
esac
