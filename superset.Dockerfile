FROM apache/superset:latest

# Switch to root to install packages
USER root

# Install psycopg2-binary using 'uv' targeting the specific virtual environment python
# Note: We use --python to explicitly tell uv where to install the package
RUN uv pip install --python /app/.venv/bin/python psycopg2-binary clickhouse-connect

# Switch back to the superset user
USER superset
