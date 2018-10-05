# Docker CentOS7 + Nginx + PHP-FPM 

FROM pigochu/c7-supervisor

MAINTAINER Pigo Chu <pigochu@gmail.com>

# Environment for set Supervisord
ENV SUPERVISOR_AUTOSTART_CROND=true
ENV SUPERVISOR_AUTORESTART_CROND=true
ENV SUPERVISOR_AUTOSTART_NGINX=true
ENV SUPERVISOR_AUTORESTART_NGINX=true
ENV SUPERVISOR_AUTOSTART_PHPFPM=true
ENV SUPERVISOR_AUTORESTART_PHPFPM=true

# Environment for nginx server_name and root
ENV NGINX_DEFAULT_SERVER_NAME="_"
ENV NGINX_DEFAULT_ROOT="/var/www/html"
ENV NGINX_STDOUT_LOGFILE="/dev/stdout"
ENV NGINX_STDERR_LOGFILE="/dev/stderr"

# install packages

RUN yum upgrade -y;\
rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
yum-config-manager --enable remi remi-php72 && \
yum install -y net-tools crontabs logrotate unzip nginx php php-cli php-fpm php-opcache php-mysql composer npm && \
yum clean all



# Requirement folders

RUN mkdir /etc/nginx/snippets;\
mkdir /var/run/php-fpm;\
mkdir /var/www/sites;\
mkdir /root/.npm;\
ln -s /usr/share/nginx/html/index.html /var/www/html/index.html;\
ln -s /usr/share/nginx/html/nginx-logo.png /var/www/html/nginx-logo.png;\
ln -s /usr/share/nginx/html/poweredby.png /var/www/html/poweredby.png;\
ln -s /dev/stdout /var/log/nginx/access.log;\
ln -s /dev/stderr /var/log/nginx/error.log

# Requirement files

COPY build-files/etc/supervisord.d/* /etc/supervisord.d/
COPY build-files/etc/nginx/* /etc/nginx/
COPY build-files/etc/nginx/conf.d/* /etc/nginx/conf.d/
COPY build-files/etc/nginx/snippets/* /etc/nginx/snippets/
COPY build-files/etc/php-fpm.d/* /etc/php-fpm.d/
COPY build-files/opt/c7supervisor/etc/init.d/* /opt/c7supervisor/etc/init.d/


# Permissions

RUN chown root:root /opt/c7supervisor/etc/init.d/c7-nginx-php-fpm-init.sh;\
chmod 700 /opt/c7supervisor/etc/init.d/c7-nginx-php-fpm-init.sh;\
chown root:root /etc/nginx/nginx.template;\
chmod 600 /etc/nginx/nginx.template;\
chown root:root /etc/nginx/snippets/*;\
chmod 600 /etc/nginx/snippets/*;\
chown root:root /etc/php-fpm.d/www.conf;\
chmod 600 /etc/php-fpm.d/www.conf;\
chown root:root /etc/supervisord.d/*;\
chmod 600 /etc/supervisord.d/*;\
chown -Rf root:nginx /var/lib/php/*;\
chmod 644 /etc/php-fpm.d/www.conf;\
chown root:root /etc/php-fpm.d/www.conf;\
chown nginx:root /var/log/php-fpm;\
chown root:root /root/.npm;\
chmod 600 /root/.npm;\
chown root:root /var/www/sites;\
chmod 755 /var/www/sites


# VOLUME
VOLUME ["/var/www/sites" , "/var/www/html" , "/root/.composer" , "/root/.npm"]

EXPOSE 443 80






