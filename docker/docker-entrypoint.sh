#!/bin/sh
set -eo pipefail
echo "Start service $PROJECT_NAME"

case $1 in
  start)
    bundle check || bundle install --quiet --jobs 2 --without development test capistrano staging --full-index
    rails assets:precompile
    #bundle exec rake resque:work QUEUE=*
    [ -f Passengerfile.json ] && rm Passengerfile.json

    ln -s config/passenger/$PASSENGER_APP_ENV.json Passengerfile.json
    exec passenger start --log-file $PROJECT_DIR/log/passenger.log
    ;;
  *)
	exec "$@"
	;;
esac
