FROM hachque/systemd-none

# Install requirements
RUN zypper --non-interactive in git nginx php-fpm php5-mbstring php5-mysql php5-curl php5-pcntl php5-gd php5-openssl php5-ldap php5-fileinfo php5-posix php5-json php5-iconv php5-mcrypt php5-zlib ca-certificates ca-certificates-mozilla ca-certificates-cacert sudo

# Force reinstall cronie
RUN zypper --non-interactive install -f cronie

# Re-patch anything that's needed
RUN zypper --non-interactive patch || true
RUN zypper --non-interactive patch || true

# Install Memcache support in PHP
RUN zypper --non-interactive ref
RUN zypper --non-interactive in php5-pear libmemcached libmemcached-devel php5-devel gcc-c++ make
RUN echo "/usr" | pecl install memcached
RUN zypper --non-interactive rm -u php5-pear libmemcached-devel php5-devel gcc-c++ make

# Clone Let's Encrypt
RUN git clone https://github.com/letsencrypt/letsencrypt /srv/letsencrypt

# Install letsencrypt
WORKDIR /srv/letsencrypt
RUN ./letsencrypt-auto --help
WORKDIR /

# Expose Nginx on port 80 and 443
EXPOSE 80
EXPOSE 443

# Remove preconfigured Nginx files
RUN rm -Rv /etc/nginx
RUN mkdir /etc/nginx

# Remove existing web files
RUN rm -Rv /srv/www

# Create nginx user and group
RUN echo "nginx:x:497:495:user for nginx:/var/lib/nginx:/bin/false" >> /etc/passwd
RUN echo "nginx:!:495:" >> /etc/group

# Set correct permissions for storage
RUN chown nginx:nginx /var/lib/php5

# Add files
ADD nginx.conf /etc/nginx/nginx.conf
ADD mime.types /etc/nginx/mime.types
ADD fastcgi.conf /etc/nginx/fastcgi.conf
ADD 25-servers /etc/init.simple/25-servers
ADD 25-php-fpm /etc/init.simple/25-php-fpm
ADD 20-postfix /etc/init.simple/20-postfix
ADD 10-boot-conf /etc/init.simple/10-boot-conf
ADD 00-hosts /etc/init.simple/00-hosts
ADD 50-cronie /etc/init.simple/50-cronie
ADD php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD php.ini /etc/php5/fpm/php.ini
ADD error.conf /etc/nginx/error.conf
ADD *.htm /srv/error-pages/
RUN chown -R nginx:nginx /srv/error-pages

# Set /init as the default
CMD ["/init"]

# Require /certs volume mounts
VOLUME ["/certs"]

# Install the Memcache configuration (you should add this to your baked image's Dockerfile if you want Memcache sessions)
#ADD memcached.ini /etc/php5/conf.d/memcached.ini


