#!/bin/bash
set -e
# Extract environment variables
GOLANG_DB_USER="${GOLANG_DB_USER:-golang_user}"
GOLANG_DB_PASSWORD="${GOLANG_DB_PASSWORD:-golang123}"
PHP_DB_USER="${PHP_DB_USER:-php_user}"
PHP_DB_PASSWORD="${PHP_DB_PASSWORD:-php123}"

echo "Golang user: $GOLANG_DB_USER"
echo "PHP user: $PHP_DB_USER"

execute_sql() {
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        $1
EOSQL
}

# Create users
execute_sql "
    -- Create user for golang application
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$GOLANG_DB_USER') THEN
            CREATE USER $GOLANG_DB_USER WITH PASSWORD '$GOLANG_DB_PASSWORD';
        END IF;
    END
    \$\$;
"

execute_sql "
    -- Create user for php application
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$PHP_DB_USER') THEN
            CREATE USER $PHP_DB_USER WITH PASSWORD '$PHP_DB_PASSWORD';
        END IF;
    END
    \$\$;
"

# Create databases
execute_sql "
    -- Create golang database
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'app_golang') THEN
            CREATE DATABASE app_golang WITH OWNER $GOLANG_DB_USER;
        END IF;
    END
    \$\$;
"

execute_sql "
    -- Create php database
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'app_php') THEN
            CREATE DATABASE app_php WITH OWNER $PHP_DB_USER;
        END IF;
    END
    \$\$;
"

# Set up permissions Golang database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname="app_golang" <<-EOSQL
    GRANT ALL PRIVILEGES ON DATABASE app_golang TO $GOLANG_DB_USER;
    GRANT ALL ON SCHEMA public TO $GOLANG_DB_USER;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $GOLANG_DB_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $GOLANG_DB_USER;

    -- Allow future objects to be owned by the application user
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $GOLANG_DB_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $GOLANG_DB_USER;
EOSQL

# Set up permissions PHP database
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname="app_php" <<-EOSQL
    GRANT ALL PRIVILEGES ON DATABASE app_php TO $PHP_DB_USER;
    GRANT ALL ON SCHEMA public TO $PHP_DB_USER;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $PHP_DB_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $PHP_DB_USER;

    -- Allow future objects to be owned by the application user
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $PHP_DB_USER;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $PHP_DB_USER;
EOSQL
