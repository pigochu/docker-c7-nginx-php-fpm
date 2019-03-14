Nginx + PHP-FPM base on CentOS7
===============================

請注意，這個 container 只適合開發或測試用途，千萬別拿來當正式環境，
搞這東西主要是為了減少命令行操作，就是懶，
習慣用 Kitematic 的人幾乎可以靠 UI 操作就能部屬很多專案。


# 特色 #

* base on pigochu/c7-supervisor (CentOS 7 base) : https://github.com/pigochu/docker-c7-supervisor
* php 使用 remi repo 且另外安裝的模組如下 :
  * php-fpm : enabled
  * php-opcache : enabled
  * php-pdo & pdo-mysql: enabled
  * php-pgsql enabled
  * composer installed
  * 詳細所有載入的模組請參考本文件下方以 php -m 列出的模組清單
* nginx enabled
* nodejs and npm installed
* git installed
* 不使用大量環境變數，而利用 VOLUME 方式取代 container 內檔案可方便做到非常有彈性的服務設定
* VOLUME 可以做到
  * container 啟動後將自己寫的設定檔覆蓋 container 內的相同結構檔案，如 cron , nginx , php 等等的設定然後才會啟動服務
  * container 啟動後先執行自己寫的 shell 做一些初始化動作

# 建立 docker image #


```bash
docker build -t "pigochu/c7-nginx-php-fpm" -f Dockerfile .
```


# 啟動說明 (務必看清楚) #

預設啟動時，nginx 會依照環境變數 NGINX_DEFAULT_ROOT 作為網頁根目錄，因此啟動後看到的網頁是 nginx 官方的，而本 container 有開 VOLUME /var/www/html，因此可將 NGINX_DEFAULT_ROOT 設定為 /var/www/html 後並且將 VOLUME 也掛上，就能使用自己的 APP 了。


# VOLUME 說明 #

* /docker-settings: 可以讓你放任何檔案於 container 啟動時，覆蓋或執行，詳情請看 https://github.com/pigochu/docker-c7-supervisor
* /var/www/html : 預設應用程式可以放此處
* /var/www/sites : 建議若有 virtual host 需求，可以在此目錄建立各 site , 並寫設定檔於 /docker-settings/replace-files/etc/nginx/conf.d 之下。
* /root/.composer : 因為 PHP 應用常常使用到 composer，所以將 composer 快取也設定成 VOLUME 才能永久保存，例如 Windows 環境可以設定為。
* /root/.npm : 某些 php framework 也會用到 npm , 所以這個也可以設定 VOLUME 來永久保存相關檔案

# 環境變數介紹 #

## SUPERVISORD ##

以下是 supervisor 預設啟動/自動重新啟動的服務，若不想啟動請自行修改為 false

* SUPERVISOR_AUTOSTART_CRON=true
* SUPERVISOR_AUTORESTART_CRON=true
* SUPERVISOR_AUTOSTART_NGINX=true
* SUPERVISOR_AUTORESTART_NGINX=true
* SUPERVISOR_AUTOSTART_PHPFPM=true
* SUPERVISOR_AUTORESTART_PHPFPM=true


## PHP Environment  ##

- PHPRC : 可自行設定 php.ini 位置 , 預設是 /etc , 因此會讀取 /etc/php.ini , 若設定此值非 /etc，則必須另外準備 php.ini 讓 php 能讀取
- PHP_INI_SCAN_DIR : 除了 /etc/php.d 之外，亦可再額外加入自訂目錄讓 php 載入其他 ini，例如 PHP_INI_SCAN_DIR=:/root/php.d，則代表除了 /etc/php.d 之外，也會掃 /root/php.d，這種做法則要再搭配 VOLUME /docker-settings/replace-files 或 /docker-settings/template-files 來置放設定檔才有辦法讀到

## NGINX Environment ##

- NGINX_DEFAULT_ROOT : 預設 Web 的根目錄
- NGINX_DEFAULT_SERVER_NAME : 預設 web 的 host name
- NGINX_STDOUT_LOGFILE : 預設正常訊息會導到 /dev/stdout，所以可以由 docker logs 查詢，若不想導 log , 可設定為 /dev/null
- NGINX_STDERR_LOGFILE : 預設錯誤訊息會導到 /dev/stderr，所以可以由 docker logs 查詢，若不想導 log , 可設定為 /dev/null


# Docker for Windows 的建議 #

1. 善用 Docker for Windows 推薦的 Kitematic 以 UI 來設定 VOLUME /docker-settings 做到啟動時，自動覆蓋設定檔，這樣子下次到別的地方用也不需要 Build 自己的 Image
2. Windows Host 中可設定 COMPOSER_HOME 變數，使之能與 container 的 VOLUME /root/.composer 共用，這樣所有專案關於 composer repo , cache 等不論在 Windows Host 或 Container 內操作 composer 都會用同一份快取了。

#PHP 專案開發的建議 #

在 PHP 專案中建立一個 .docker 目錄，結構可能如下(請依照 CentOS 原本結構建立相對應目錄)

~~~
replace-files/	
				etc/
					/cron.d
					/nginx
							/conf.d
							/default.d
~~~

因為這個 images 有個特異功能，會處理  VOLUME /docker-settings 下 replace-files 的檔案，將其內容覆蓋到 container ，然後才會啟動服務。

如果，想要搭配自訂環境變數來啟動 container ，可以將 replace-files 改成 template-files ，而檔案內容要使用環境變數範例如下
~~~
server {
    root ${NGINX_DEFAULT_SERVER_ROOT};
	# ...
}
~~~

當你準備好上述的目錄結構，及您所建立要覆蓋的設定檔後，請將 VOLUME /docker-settings 掛載到你專案中的 .docker，然後啟動 container 就行了。

這樣都不用使用 compose，僅使用 Kitematic 就可以完成所有設定。

如果你還想要做到 container 啟動後執行你的 shell 做一些初始化動作 ，請在 .docker 下建立 after-supervisord.d 或 before-supervisord.d，然後將你的 shell 放入。

這些處理過程可以參考 https://github.com/pigochu/docker-c7-supervisor 這個上層 Image 的做法。

# php -m 列出載入的模組 #

~~~
[PHP Modules]
bz2
calendar
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gettext
hash
iconv
intl
json
libxml
mbstring
memcache
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_pgsql
pdo_sqlite
pgsql
Phar
posix
readline
Reflection
session
shmop
SimpleXML
sockets
SPL
sqlite3
standard
sysvmsg
sysvsem
sysvshm
tokenizer
wddx
xml
xmlreader
xmlwriter
xsl
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
~~~

# PHP Framework 最小需求通過測試 #

* Laravel >= 5.1
* Yii >= 2.0

# Maintainer #

Pigo Chu <pigochu@gmail.com>
