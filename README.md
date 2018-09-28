Nginx + PHP-FPM base on CentOS7
===============================


## Fetures ##

- OS base on CentOS 7(https://hub.docker.com/r/centos)
- php 7.2 from remi repo and installed packages:
  - php-fpm : enabled
  - php-opcache : enabled
  - php-pdo : enabled
- nginx from official and default enabled


## PHP Environment  ##

- PHPRC : 可自行設定 php.ini 位置 , 預設是 /etc , 因此會讀取 /etc/php.ini , 若設定此值非 /etc，則必須另外準備 php.ini 讓 php 能讀取
- PHP_INI_SCAN_DIR : 除了 /etc/php.d 之外，可再額外加入自訂目錄讓 php 載入 ini

## Maintainer ##

Pigo Chu <pigochu@gmail.com>