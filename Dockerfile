FROM alpine:edge
MAINTAINER jkevlin<jkevlin@gmail.com>



RUN echo 'http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories\
    && apk add  --update --no-cache \
    bash \
    less \
    vim \
    nginx \
    ca-certificates \
    nano \
    git \
    zip \
    curl \
    musl \
    && update-ca-certificates \
    \
    && apk --update add \
    php7-apcu \
    php7-bcmath \
    php7-bz2 \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-fpm \
    php7-gd \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-ldap \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqli \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-posix \
    php7-phar \
    php7-redis \
    php7-session \
    php7-xsl \
    php7-xml \
    php7-xmlreader \
    php7-zlib \
    #php7-date \
    #php7-libxml \
    #php7-dbg \
    #php7-pcre \
    #php7-simplexml \
    && rm -rf /var/cache/apk/* \
    && rm -fr /tmp/* 

# Install dependencies required for building things (will be removed at the end)
RUN set -xe \
    && BUILD_DEPS=" \
        php7-dev  \
        build-base \
        autoconf \
        gcc \
        openssl-dev \
        " \
    \
    && apk --update add ${BUILD_DEPS} \

    && ln -s /usr/bin/phpize7 /usr/bin/phpize \
    && ln -s /usr/bin/php-config7 /usr/bin/php-config \
    && sed -i -e 's/PHP -C -n -q/PHP -C -q/g' /usr/bin/pecl \
    && pecl install mongodb \
    && echo "extension=mongodb.so" > /etc/php7/conf.d/20_mongodb.ini \

    && yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/lib/php7/modules/ -name xdebug.so)" > /etc/php7/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /etc/php7/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /etc/php7/conf.d/xdebug.ini \

    && cd / \
    && apk del ${BUILD_DEPS} \
    && rm -fr /var/cache/apk/* \
    && rm -fr /tmp/* \
    && rm /usr/bin/phpize \
    && rm /usr/bin/php-config

# composer install
RUN /usr/bin/php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && /usr/bin/php7 -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && /usr/bin/php7 composer-setup.php \
    && /usr/bin/php7 -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer


RUN apk update \
    && apk add ca-certificates openssl \
    && update-ca-certificates  \
    && wget https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /usr/local/bin/phpunit


ENV TERM="xterm" \
    DB_HOST="172.17.0.1" \
    DB_NAME="" \
    DB_USER=""\
    DB_PASS=""


RUN sed -i 's/session.save_handler = files/session.save_handler = redis/g' /etc/php7/php.ini \
    && sed -i 's?;session.save_path = "/tmp"?session.save_path = "tcp://redis:6379"?g' /etc/php7/php.ini \
    && sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 3600/g' /etc/php7/php.ini \
    \
    && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php7/php.ini \
    && sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/bin\/bash/g' /etc/passwd \
    && sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/bin\/bash/g' /etc/passwd- \
    && ln -s /usr/bin/php7 /usr/bin/php \
    && ln -s /sbin/php-fpm7 /sbin/php-fpm \
    \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /var/log/php-fpm/ \
    && touch /var/log/php-fpm/php-fpm.log \
    && ln -sf /dev/stderr /var/log/php-fpm/php-fpm.log \
    && echo "hello2"

    

ADD files/nginx.conf /etc/nginx/
ADD files/php-fpm.conf /etc/php7/
ADD files/run.sh /
RUN chmod +x /run.sh

EXPOSE 80
VOLUME ["/DATA","/root"]

CMD ["/run.sh"]
