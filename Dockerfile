FROM php:7.1.5-apache

# Setup environment.
ENV DEBIAN_FRONTEND noninteractive

RUN a2enmod rewrite

# Install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql opcache zip

# Installtion.
RUN apt-get update -y && apt-get install -y \
    software-properties-common \
    git \
    wget \
    zip \
    vim \
    ruby-dev \
    rubygems \
    php5-curl \
    php5-cli \
    php5-mysql \
    mysql-server \
    mysql-client \
    default-jdk

# Install stuff to run javascript tests.
RUN apt-get -qq -y install iceweasel > /dev/null \
    && apt-get install xvfb -y \
    && apt-get install openjdk-7-jre-headless -y \
    && Xvfb :99 -ac  \
    && export DISPLAY=:99

RUN wget http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar \
    &&java -jar selenium-server-standalone-2.53.0.jar > /dev/null 2>&1 &

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drush.
RUN export PATH="$HOME/vendor/bin:$PATH" \
  && cd $HOME \
  && composer require drush/drush

# Fake the sending mail in order to avoid errors.
RUN echo 'sendmail_path = /bin/true' >> /etc/php.ini

