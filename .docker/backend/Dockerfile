FROM php:8.3-fpm-alpine3.20

ENV TIMEZONE 'Europe/Amsterdam'

RUN apk --update --no-cache add linux-headers bash wget gcc g++ make autoconf libsodium-dev openssh rsync git
RUN docker-php-ext-install -j$(nproc) pdo_mysql

RUN pecl install xdebug libsodium && docker-php-ext-enable xdebug opcache
#RUN git config --global user.email "moukafih@live.nl" && git config --global user.name "Ismail Moukafih"

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /usr/local/etc/php/php.ini \
    && sed -i "s|memory_limit =.*|memory_limit = -1|" /usr/local/etc/php/php.ini

RUN echo $'zend_extension=xdebug.so \n\
xdebug.mode=debug \n\
xdebug.start_with_request=trigger \n\
xdebug.client_host=host.docker.internal'\
> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash && mv /root/.symfony5/bin/symfony /usr/bin/symfony

### Codeception
RUN wget http://codeception.com/codecept.phar -O /usr/bin/codecept && chmod a+x /usr/bin/codecept
#source <(codecept _completion --generate-hook --program codecept)
### PHPBench
#RUN wget https://phpbench.github.io/phpbench/phpbench.phar -O /usr/bin/phpbench && chmod a+x /usr/bin/phpbench
#RUN wget https://phpbench.github.io/phpbench/phpbench.phar.pubkey -O /usr/bin/phpbench.pubkey

RUN addgroup _www && adduser -S -H --ingroup _www _www

WORKDIR /var/www

ADD install.sh /home/
RUN chmod +x /home/install.sh

ADD docker-init.sh /home/
RUN chmod +x /home/docker-init.sh
CMD bash /home/docker-init.sh

