#!/bin/bash

SUPERUSER=code
USER=$1

docker exec -i postgres psql -U ${SUPERUSER} <<EOF
-- Terminate connections to the database
REVOKE CONNECT ON DATABASE $USER FROM public, $USER;
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$USER';
-- Drop the database if it exists
DROP DATABASE IF EXISTS $USER;
-- Drop the user if it exists
DROP USER IF EXISTS $USER;
EOF

echo "User $USER and database $USER removed (if they existed)"
