FROM php:5.6-fpm
# Thanks to Camil Blanaru <camil@edka.io> , derived from work done by him.

MAINTAINER JokeDiaz <jokediaz@gmail.com>

#install laravel requirements and aditional extensions
RUN requirements="libmcrypt-dev g++ libicu-dev libmcrypt4 libicu52 zlib1g-dev git" \
    && apt-get update && apt-get install -y $requirements \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install intl \
    && docker-php-ext-install json \
    && docker-php-ext-install zip \
    && apt-get install libssl-dev -y \
    && apt-get install pkg-config -y \
    && apt-get install build-essential -y \
    && apt-get install chrpath -y \ 
    && apt-get install libxft-dev -y \
    && apt-get install libfreetype6 libfreetype6-dev \
    && apt-get install libfontconfig1 libfontconfig1-dev -y \
    && apt-get install wget -y \
    && requirementsToRemove="libmcrypt-dev g++ libicu-dev zlib1g-dev" \
    && apt-get purge --auto-remove -y $requirementsToRemove \
    && rm -rf /var/lib/apt/lists/*

#installing phantom

RUN cd ~ && export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" \
    && wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 \
    && tar xvjf $PHANTOM_JS.tar.bz2

#install composer globally
RUN curl -sSL https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#replace default php-fpm config
RUN rm -v /usr/local/etc/php-fpm.conf

COPY config/php-fpm.conf /usr/local/etc/

#add custom php.ini
COPY config/php.ini /usr/local/etc/php/

# Setup Volume for php.ini 
VOLUME ["/usr/local/etc/php/"]

# Install mongo
RUN pecl install mongo &&\
    echo "extension=mongodb.so" >> /usr/local/etc/php/php.ini 

# Setup Volume
VOLUME ["/usr/share/nginx/html"]

#Set Workdir
WORKDIR /usr/share/nginx/html

#Change www-data UID
RUN usermod -u 1000 www-data \
    && groupmod -g 1000 www-data

#Add entrypoint
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
