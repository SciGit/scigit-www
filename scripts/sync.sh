#!/bin/sh
# This is a script to autoupdate a server. It should be run as part of a cron
# job.
(
platform=`uname`
echo 'Updating' $platform 'server'
if [[ $platform == 'Linux' ]]; then
  cd /var/www/html_scigit
elif [[ $platform == 'Darwin' ]]; then
  cd /Library/WebServer/Documents
else
  cd /var/www/html_scigit
fi

git pull

echo 'Migrating to newest DB'
php index.php migrate
)
