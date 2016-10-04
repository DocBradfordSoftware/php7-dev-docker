# Install dependencies required for building things (will be removed at the end)
BUILD_DEPS="
    php7-dev 
    build-base
    autoconf
    gcc
    libc-dev
    file
    binutils
    bison
    readline-dev
    libxml2-dev
    curl-dev
    openssl-dev
    db-dev
    enchant-dev
    expat-dev
    freetds-dev
    gdbm-dev
    gettext-dev
    libevent-dev
    libgcrypt-dev
    libxslt-dev
    unixodbc-dev
    zlib-dev
    krb5-dev
    libical-dev
    libxpm-dev
    cyrus-sasl 

"

apk --update add ${BUILD_DEPS}

ln -s /usr/bin/phpize7 /usr/bin/phpize
ln -s /usr/bin/php-config7 /usr/bin/php-config

 sed -i -e 's/PHP -C -n -q/PHP -C -q/g' /usr/bin/pecl 

# install mongodb
pecl install mongodb
echo "extension=mongodb.so" > /etc/php7/conf.d/20_mongodb.ini
#enable_ext mongodb


# clean up
#cd /
#apk del ${BUILD_DEPS}
#rm -fr /var/cache/apk/*
#rm -fr /tmp/*