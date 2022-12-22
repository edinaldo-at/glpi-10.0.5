FROM ubuntu:latest

RUN apt-get update
RUN apt-get -y install tzdata vim
RUN apt-get -y install \
		bzip2 \
		apache2 \
		php \
		libapache2-mod-php \
		php-mysql \
		php-common \
		php-cli \
		php-gd \
		php-mysqlnd \
		php-json \
		php-mbstring \
		php-mysqli \
		php-gd \
		php-dom \
		php-curl \
		php-imap \
		php-ldap \
		php-opcache \
		php-apcu \
		php-xml \
		php-xmlrpc \
		php-intl \
		php-bz2 \
		php-zip

WORKDIR /var/www/html

RUN mkdir -p /tmp/glpi/config
RUN mkdir -p /var/lib/glpi
RUN mkdir -p /var/log/glpi

ADD apache/apache2.conf /etc/apache2/apache2.conf
ADD apache/php.ini /etc/php/8.1/apache2/php.ini
ADD apache/dir.conf /etc/apache2/mods-enabled/dir.conf
ADD scripts/glpi-entrypoint.sh /

COPY html /var/www/html/

RUN chmod 755 /glpi-entrypoint.sh

EXPOSE 80

CMD ["/glpi-entrypoint.sh"]
 