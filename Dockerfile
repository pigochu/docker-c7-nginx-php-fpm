FROM centos:7
ENV container docker
MAINTAINER Pigo Chu <pigochu@gmail.com>

WORKDIR /root

# enable systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

ENV NGINX_DEFAULT_ROOT="/usr/share/nginx/html"
ENV PHP_RC="/etc"
ENV PHP_INI_SCAN_DIR=:"/data/php.d"

# install packages
RUN yum upgrade -y
RUN yum install -y epel-release
RUN rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN yum-config-manager --enable remi remi-php72
RUN yum install -y net-tools crontabs logrotate gettext
RUN yum install -y nginx php php-cli php-fpm php-opcache php-mysql composer


# enable service
RUN systemctl enable crond
RUN systemctl enable php-fpm
RUN systemctl enable nginx



EXPOSE 443 80

# configure file can share
VOLUME ["/etc/php-fpm.d"]
VOLUME ["/etc/nginx/default.d"]
VOLUME ["/etc/nginx/conf.d"]



