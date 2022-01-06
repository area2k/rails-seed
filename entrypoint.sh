#!/bin/sh
set -e

echo "Running pre-deployment steps..."

echo "----- RUNNING MIGRATIONS -----"
bundle exec rake db:migrate

echo "----- STARTING APPLICATION -----"

# exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
