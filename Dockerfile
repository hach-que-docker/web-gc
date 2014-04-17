FROM hachque/systemd-boot

# Install Nginx and PHP-FPM
RUN zypper --non-interactive in nginx php-fpm

# Link services into the default target
RUN ln -s /usr/lib/systemd/system/nginx.service /usr/lib/systemd/system/default.target.wants/nginx.service
RUN ln -s /usr/lib/systemd/system/php-fpm.socket /usr/lib/systemd/system/default.target.wants/php-fpm.socket

# Add systemd service files.
ADD nginx.service /etc/systemd/system/nginx.service

# Expose Nginx on port 80 and 443
EXPOSE 80
EXPOSE 443

