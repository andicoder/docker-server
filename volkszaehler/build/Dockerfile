FROM debian:stretch-slim

MAINTAINER Andreas Körner <andreas@***REMOVED***.de>

ARG PHP_VER=7.0

ENV DEBIAN_FRONTEND noninteractive

# install runtime environment

RUN apt-get -q update
RUN apt-get -qy --no-install-recommends install \
	php${PHP_VER}-cli \
	php${PHP_VER}-mysql \
	php${PHP_VER}-xml \
	php${PHP_VER}-zip \
	php${PHP_VER}-mbstring \
	git \
	ca-certificates

# composer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
