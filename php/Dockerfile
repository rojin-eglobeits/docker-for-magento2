FROM php:7.1-fpm

ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --enable-intl --enable-opcache --enable-zip

RUN \
   apt-get update && apt-get install --no-install-recommends -y \
  libcurl4-gnutls-dev \
  libxml2-dev \
  libssl-dev \
&& rm -rf /var/lib/apt/lists/*

RUN \
    /usr/local/bin/docker-php-ext-install \
    dom \
    pcntl \
    phar \
    posix 

RUN \
  apt-get update && apt-get install --no-install-recommends -y \
  g++ \
  autoconf \
  libbz2-dev \
  libltdl-dev \
  libpng-dev \
  libjpeg62-turbo-dev \
  libfreetype6-dev \
  libxpm-dev \
  libimlib2-dev \
  libicu-dev \
  libmcrypt-dev \
  libxslt1-dev \
  re2c \
  libpng++-dev \
  libvpx-dev \
  zlib1g-dev \
  libgd-dev \
  libtidy-dev \
  libmagic-dev \
  libexif-dev \
  file \
  libssh2-1-dev \
  libjpeg-dev \
  git \
  curl \
  wget \
  librabbitmq-dev \
  libzip-dev \  
&&  rm -rf /var/lib/apt/lists/*

RUN \
    /usr/local/bin/docker-php-ext-install \
    pdo \
    sockets \
    pdo_mysql \
    mysqli \
    mbstring \
    mcrypt \
    hash \
    simplexml \
    xsl \
    soap \
    intl \
    bcmath \
    json \
    opcache \
    zip \
  &&  rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www/html/*


RUN chown -R www-data:www-data /var/www/
RUN chmod -R g+w /var/www/


RUN mkdir /var/log/php-fpm && \
    touch /var/log/php-fpm/access.log && \
    touch /var/log/php-fpm/error.log && \
    chown -R www-data:www-data /var/log/php-fpm

RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr \
    && docker-php-ext-install gd


RUN cd /tmp/ && git clone https://github.com/xdebug/xdebug.git \
    && cd xdebug && phpize && ./configure --enable-xdebug && make \
    && mkdir /usr/lib/php7/ && cp modules/xdebug.so /usr/lib/php7/xdebug.so \
    && touch /usr/local/etc/php/ext-xdebug.ini \
    && rm -r /tmp/xdebug \
    && apt-get purge -y --auto-remove