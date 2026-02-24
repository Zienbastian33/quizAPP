#!/bin/bash
set -e

# Create additional databases required by Rails 8 (cache, queue, cable)
# The primary database (quiz_app_production) is created by POSTGRES_DB env var
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE quiz_app_production_cache OWNER $POSTGRES_USER;
    CREATE DATABASE quiz_app_production_queue OWNER $POSTGRES_USER;
    CREATE DATABASE quiz_app_production_cable OWNER $POSTGRES_USER;
EOSQL

echo "=== Additional databases created successfully ==="
