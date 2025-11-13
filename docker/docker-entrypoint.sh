#!/bin/bash

# Check if STORAGE_DIR is set
if [ -z "$STORAGE_DIR" ]; then
    echo "================================================================"
    echo "⚠️  ⚠️  ⚠️  WARNING: STORAGE_DIR environment variable is not set! ⚠️  ⚠️  ⚠️"
    echo ""
    echo "Not setting this will result in data loss on container restart since"
    echo "the application will not have a persistent storage location."
    echo "It can also result in weird errors in various parts of the application."
    echo ""
    echo "Please run the container with the official docker command at"
    echo "https://docs.anythingllm.com/installation-docker/quickstart"
    echo ""
    echo "⚠️  ⚠️  ⚠️  WARNING: STORAGE_DIR environment variable is not set! ⚠️  ⚠️  ⚠️"
    echo "================================================================"
fi

{
  cd /app/server/ &&
    npx prisma generate --schema=./prisma/schema.prisma &&
    if [ -d "./prisma/migrations" ] && [ "$(ls -A ./prisma/migrations)" ]; then
      echo "Migrations found, deploying..."
      npx prisma migrate deploy --schema=./prisma/schema.prisma
    else
      echo "No migrations found, pushing schema to database..."
      npx prisma db push --schema=./prisma/schema.prisma --accept-data-loss
    fi &&
    node /app/server/index.js
} &
{ node /app/collector/index.js; } &
wait -n
exit $?