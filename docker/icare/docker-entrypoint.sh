#!/bin/sh
set -e

pwd

rm -f tmp/pids/*.pid

setup_database()
{
  echo "ENTRYPOINT: Checking database setup is up to date…"
  # Rails will throw an error if no database exists"
  #   PG::ConnectionBad: FATAL:  database "icare_development" does not exist
  if rails db:migrate:status &> /dev/null; then
    echo "ENTRYPOINT: Database found, running db:migrate…"
    rails db:migrate
  else
    echo "ENTRYPOINT: No database found…"

    if [ "$RAILS_ENV" == "production" ]; then
      echo "ENTRYPOINT: Environment is production, doing nothing."
    else
      echo "ENTRYPOINT: Environment is in non-production, attempting to automatically create the database…"
      echo "ENTRYPOINT: Running db:create db:schema:load…"
      rails db:create db:environment:set db:schema:load
    fi
  fi
  echo "ENTRYPOINT: Finished database setup."
}

if [ -z ${DATABASE_URL+x} ]; then echo "ENTRYPOINT: Skipping database setup due to missing DATABASE_URL"; else setup_database; fi

exec "$@"
