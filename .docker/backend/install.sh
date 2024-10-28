#git config --global user.email "i.moukafih@gmail.com"
#git config --global user.name "Ismail Moukafih"

rm -rf ./*

echo "-------------------------------------------------------------------"
echo "-                create symfony project                           -"
echo "-------------------------------------------------------------------"
symfony self:version

symfony new my_project --no-git --version=6.4 --php=8.3 --docker=false

cd ./my_project
symfony composer config extra.symfony.allow-contrib false
echo "-------------------------------------------------------------------"
echo "-                   require packages                              -"
echo "-------------------------------------------------------------------"
symfony composer require php:^8.3.0
symfony composer require --no-interaction symfony/serializer-pack symfony/uid symfony/validator \
  doctrine/doctrine-migrations-bundle doctrine/orm gesdinet/jwt-refresh-token-bundle nelmio/cors-bundle

mkdir -p config/secrets
#openssl genpkey -out config/secrets/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096
#openssl pkey -in config/secrets/private.pem -out config/secrets/public.pem -pubout
openssl req -x509 -newkey rsa:2048 -keyout config/secrets/private.pem -out config/secrets/public.pem -days 365 -nodes -subj "/CN=app.localhost"

echo "-------------------------------------------------------------------"
echo "-               require dev packages                              -"
echo "-------------------------------------------------------------------"
symfony composer require --dev --no-interaction symfony/maker-bundle symfony/web-profiler-bundle doctrine/doctrine-fixtures-bundle

# Unit Testing
symfony composer require --dev --no-interaction codeception/module-symfony codeception/module-doctrine2 \
codeception/module-rest codeception/module-datafactory codeception/module-phpbrowser codeception/module-asserts \
codeception/specify codeception/verify league/factory-muffin league/factory-muffin-faker

composer config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
composer config --no-plugins allow-plugins.phpstan/extension-installer true

# Clean code tools
symfony composer require --dev --no-interaction friendsofphp/php-cs-fixer phpmd/phpmd \
nunomaduro/phpinsights phpstan/extension-installer phpstan/phpstan-doctrine phpstan/phpstan-symfony phpmetrics/phpmetrics

composer require --dev --no-interaction psalm/plugin-symfony:^5.2 nikic/php-parser:^4.19

symfony composer config scripts.phpcsfixer "./vendor/bin/php-cs-fixer fix ./src --rules=@Symfony,@PHP82Migration --dry-run --diff"
symfony composer config scripts.phpcsfixer-fix "./vendor/bin/php-cs-fixer fix ./src --rules=@Symfony,@PHP82Migration"
symfony composer config scripts.phpmd "./vendor/bin/phpmd ./src text cleancode,codesize,design,naming,controversial"
symfony composer config scripts.phpmd-baseline "./vendor/bin/phpmd ./src text cleancode,codesize,design,naming,controversial --generate-baseline --baseline-file phpmd.baseline.xml"
symfony composer config scripts.phpcpd "phpcpd --fuzzy --min-lines 4 --min-tokens 20 ./src --exclude ./src/Entity"

symfony composer config scripts.phpstan "./vendor/bin/phpstan analyse ./src"
symfony composer config scripts.phpstan-baseline "./vendor/bin/phpstan analyse ./src --generate-baseline"
symfony composer config scripts.psalm "./vendor/bin/psalm"
symfony composer config scripts.phpinsights "./vendor/bin/phpinsights analyse ./src"
symfony composer config scripts.phpinsights-fix "./vendor/bin/phpinsights analyse ./src --fix"

symfony composer config scripts.phpmetrics "./vendor/bin/phpmetrics ./src"
symfony composer config scripts.phpmetrics-report "./vendor/bin/phpmetrics --report-html=.phpmetrics ./src"

symfony composer psalm -- --init
vendor/bin/psalm-plugin enable psalm/plugin-symfony
cp vendor/nunomaduro/phpinsights/stubs/symfony.php phpinsights.php

echo "-------------------------------------------------------------------"
echo "-                   Init Codeception                              -"
echo "-------------------------------------------------------------------"
codecept bootstrap --namespace App\\Tests
codecept generate:suite api

echo "-------------------------------------------------------------------"
echo "-                        waiting for DB                           -"
echo "-------------------------------------------------------------------"
while ! nc -z $DATABASE_HOST $DATABASE_PORT; do sleep 1; done

echo "-------------------------------------------------------------------"
echo "-                          Ready                                  -"
echo "-------------------------------------------------------------------"
symfony console doctrine:migrations:diff --no-interaction

rm -rf .git compose*.yaml
cd ..

chmod -R a+rw my_project
rsync -a my_project/ ./
rm -rf my_project
