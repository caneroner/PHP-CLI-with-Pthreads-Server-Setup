#!/bin/sh -

# uncomment this 5 lines to auto add swap for Digital Ocean servers
#sudo fallocate -l 1G /swapfile
#sudo chmod 600 /swapfile
#sudo mkswap /swapfile
#sudo swapon /swapfile
#echo '/swapfile   none    swap    sw    0   0' >> /etc/fstab


php_version="5.6.15"
pthread_version="2.0.10"

apt-get -q -y update
apt-get -q -y install build-essential zlib1g-dev libreadline-dev libbz2-dev libxml2-dev libssl-dev \
	libcurl4-openssl-dev libmcrypt-dev autoconf

wget http://php.net/get/php-"$php_version".tar.xz/from/this/mirror -O /var/tmp/php.tar.xz
wget http://php.net/get/php-"$php_version".tar.xz.asc/from/this/mirror -O /var/tmp/php.tar.xz.asc

if gpg --verify /var/tmp/php.tar.xz.asc | egrep -v '(33CFC8B3|90D90EC1)'; then
	# Bad GPG signature
	exit "GPG signature is incorrect, package cannot be trusted!"
fi

tar -xJf /var/tmp/php.tar.xz -C /var/tmp
cd /var/tmp/php-"$php_version"
./configure --prefix=/usr/local --with-config-file-path=/etc --enable-maintainer-zts --with-readline \
	--with-mcrypt --with-zlib --enable-mbstring --with-curl --with-bz2 --enable-zip --enable-sockets \
	--enable-sysvsem --with-mhash --with-pcre-regex --with-gettext --enable-bcmath --enable-libxml \
	--enable-json --with-openssl --enable-pcntl

make -j8
make install
cp ./php.ini-development /etc/php.ini

pecl install channel://pecl.php.net/pthreads-"$pthread_version"
echo extension=/usr/local/lib/php/extensions/no-debug-zts-20131226/pthreads.so >> /etc/php.ini
