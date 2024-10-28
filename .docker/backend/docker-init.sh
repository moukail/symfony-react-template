#!/usr/bin/env bash

if ! [ -d "./src" ]; then
  . /home/install.sh
fi

symfony check:requirements
symfony security:check

echo "-------------------------------------------------------------------"
echo "-                          composer                               -"
echo "-------------------------------------------------------------------"
symfony composer -n check-platform-reqs
symfony composer install --no-interaction

echo "-------------------------------------------------------------------"
echo "-                        waiting for DB                           -"
echo "-------------------------------------------------------------------"
while ! nc -z $DATABASE_HOST $DATABASE_PORT; do sleep 1; done
echo "-------------------------------------------------------------------"
echo "-                        prepare the DB                           -"
echo "-------------------------------------------------------------------"
symfony console doctrine:database:create --if-not-exists
symfony console doctrine:migrations:migrate --no-interaction
symfony console doctrine:fixtures:load --no-interaction -vvv

echo "-------------------------------------------------------------------"
echo "-                        php-cs-fixer                             -"
echo "-------------------------------------------------------------------"
symfony composer phpcsfixer-fix

echo "-------------------------------------------------------------------"
echo "-                        phpstan                                  -"
echo "-------------------------------------------------------------------"
symfony composer phpstan

echo "-------------------------------------------------------------------"
echo "-                        psalm                                    -"
echo "-------------------------------------------------------------------"
vendor/bin/psalm-plugin
symfony composer psalm

echo "-------------------------------------------------------------------"
echo "-                    phpinsights                                  -"
echo "-------------------------------------------------------------------"
symfony composer phpinsights --no-interaction

echo "-------------------------------------------------------------------"
echo "-                        phpcpd                                   -"
echo "-------------------------------------------------------------------"
#symfony composer phpcpd

echo "-------------------------------------------------------------------"
echo "-                        PHPMD                                    -"
echo "-------------------------------------------------------------------"
symfony composer phpmd

echo "-------------------------------------------------------------------"
echo "-                        website is ready                         -"
echo "-------------------------------------------------------------------"
chmod -R a+rw ./
symfony local:server:start --allow-all-ip --daemon

echo "-------------------------------------------------------------------"
echo "-                        testing                                  -"
echo "-------------------------------------------------------------------"
codecept clean
codecept run --steps --debug -vvv --coverage --coverage-xml --coverage-html

tail -f /dev/null