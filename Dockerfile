# Docker CentOS7 + Nginx + PHP-FPM 


# FROM pigochu/c7-supervisor
FROM pigochu/c7-supervisor:supervisor3.x

LABEL	maintainer="Pigo Chu <pigochu@gmail.com>" \
		description="php 7.2 and nginx on centos 7"

# Environment for set Supervisord and nginx
ENV SUPERVISOR_AUTOSTART_CROND=true \
	SUPERVISOR_AUTORESTART_CROND=true \
	SUPERVISOR_AUTOSTART_NGINX=true \
	SUPERVISOR_AUTORESTART_NGINX=true \
	SUPERVISOR_AUTOSTART_PHPFPM=true \
	SUPERVISOR_AUTORESTART_PHPFPM=true \
	NGINX_DEFAULT_SERVER_NAME="_" \
	NGINX_DEFAULT_ROOT="/var/www/html" \
	NGINX_STDOUT_LOGFILE="/dev/stdout" \
	NGINX_STDERR_LOGFILE="/dev/stderr"
	
# install packages

RUN yum upgrade -y;\
	rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
	yum-config-manager --enable remi remi-php72 && \
	yum install -y net-tools crontabs logrotate unzip nginx php-cli php-fpm php-opcache php-mysql php-pgsql php-pecl-memcache git composer npm && \
	yum clean all && \
	rm -rf /var/cache/yum &&\
	rm -f /var/log/yum.log && \
	# Requirement folders
	mkdir /etc/nginx/snippets; \
	mkdir /var/run/php-fpm; \
	mkdir -p /var/www/html; \
	mkdir /var/www/sites; \
	mkdir /root/.npm; \
	ln -s /usr/share/nginx/html/index.html /var/www/html/index.html; \
	ln -s /usr/share/nginx/html/nginx-logo.png /var/www/html/nginx-logo.png; \
	ln -s /usr/share/nginx/html/poweredby.png /var/www/html/poweredby.png; \
	ln -s /dev/stdout /var/log/nginx/access.log; \
	ln -s /dev/stderr /var/log/nginx/error.log

# Requirement files
COPY --chown=root:root build-files /

# Permissions

RUN chown -Rf root:nginx /var/lib/php; \
	chmod 755 /etc; \
	chmod 600 /etc/supervisord.d/*;\
	chmod 755 /etc/nginx; \
	chmod -Rf 755 /etc/nginx/conf.d; \
	chmod 600 /etc/nginx/nginx.template;\
	chmod -Rf 755 /etc/nginx/snippets ;\
	chmod -Rf 755 /etc/php-fpm.d; \
	chmod -Rf 700 /opt/c7supervisor; \
	chmod 600 /root/.npm;\
	chmod -Rf 755 /var/www;


# VOLUME
VOLUME ["/var/www/sites" , "/var/www/html" , "/root/.composer" , "/root/.npm"]

EXPOSE 443 80






