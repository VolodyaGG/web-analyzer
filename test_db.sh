#!/bin/bash

DB_HOST="127.0.0.1"
DB_PORT="5432"
DB_USER="pinger_user"
DB_NAME="pinger_base"

echo "Insert passsword for user $DB_USER: "
read -s PASSWORD
echo ""
export PGPASSWORD="$PASSWORD"

echo "CHECK NETWORK AVAILABILITY OF POSTGRES..."

if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" > /dev/null 2>&1; then
    echo "- Database is available!"
else
    echo "- Database is not available!"
    exit 1
fi

echo "TESTING WITH SELECT AND INSERT..."

TEST_URL="https://ya.ru"
INSERT_CMD="INSERT INTO targets (url) VALUES ('$TEST_URL') RETURNING id;"

NEW_ID=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -A -c "$INSERT_CMD" 2>/dev/null)

if [ -n "$NEW_ID" ]; then
    echo "- Success! Test insert executed! Recieved ID: $NEW_ID"

    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "DELETE FROM targets WHERE id = $NEW_ID;" > /dev/null 2>&1
    echo "- Test data removed!"
else
    echo "- Error! INSERT did not executed"
    exit 1
fi