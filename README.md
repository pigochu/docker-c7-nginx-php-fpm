Nginx + PHP-FPM base on CentOS7
===============================

請注意，這個 container 只適合開發用途，不適合做為正式環境，因為有開啟 systemd，所以有安全性問題


## 特色 ##

* base on CentOS 7(https://hub.docker.com/r/centos)
* systemd enabled
* php from remi repo and installed packages:
  * php-fpm : enabled
  * php-opcache : enabled
  * php-pdo & pdo-mysql: enabled
  * composer installed
* nginx enabled
* 不使用大量環境變數，而利用 VOLUME 方式取代 container 內檔案可方便做到非常有彈性的服務設定

## 建立 docker image ##

```bash
docker build -t "pigochu/c7-nginx-php-fpm" -f Dockerfile-xxx .
```
其中 Dockerfile-xxx 請參考目錄中所提供的各種版本

## 啟動說明 (務必看清楚) ##

1. 如果在 Kitematic UI 要正常啟動，必須勾選 Settings/Advanced/Privileged Mode，命令列模式則要加上參數 --privileged
2. 預設啟動時，nginx 會依照環境變數 NGINX_DEFAULT_ROOT 作為網頁根目錄，因此啟動後看到的網頁是 nginx 官方的，而本 container 有開 VOLUME /var/www/html，因此可將 NGINX_DEFAULT_ROOT 設定為 /var/www/html 後並且將 VOLUME 也掛上，就能使用自己的 APP 了。


## VOLUME 說明 ##

* /var/www/html : 預設應用程式可以放此處
* /var/www : 建議若有 virtual host 需求，可以在此目錄建立各 site , 並且於 VOLUME /root/.replace-files 建立 etc/nginx/conf.d 及設定檔
* /root/.composer : 因為 PHP 應用常常使用到 composer，所以將 composer 快取也設定成 VOLUME 才能永久保存，例如 Windows 環境可以設定為。
* /root/.replace-files : 這個目錄是用作container啟動後尚未執行 nginx , php-fpm , crond 前，將任意檔案取代原有 container 內的檔案，使用上必須建立與 container 內目錄結構一模一樣，例如想要取代 /etc/nginx/nginx.conf，就必須在 VOLUME /root/.replace-files 內建立 etc/nginx/nginx.conf，這樣啟動 container 時，會先取代掉原本的 nginx.conf，取代時則會保留 container 原本的 owner/group/permission。如此可以有非常大的彈性來設定 nginx 或 php 或 crontab。
* /root/.template-files: 這個目錄類似 /root/.replace-files ，但是裏頭的檔案是會利用環境變數以 envsubst 取代內容後再取代 container 內的檔案。
* /root/.bootscript-files : 這個目錄可以放任何 script 進去，會於 container 啟動之後執行該目錄下所有的檔案


> 目前本 container 只有 /etc/nginx/nginx.conf 是使用 gettext 的 envsubst 命令可將環境變數設定 nginx 的 default root，可以參考 build-files/opt/pigochu/templates/nginx.conf 的內容怎麼寫的，若有其他需求，可以利用 VOLUME 的 /root/.template-files 如法炮製置放設定檔，當 container 啟動時，可再搭配環境變數取代原有的設定檔，然後才會真正啟動 nginx php-fpm crond，這樣是不是更方便了呢 ?

## 環境變數介紹 ##

### PHP Environment  ###

- PHPRC : 可自行設定 php.ini 位置 , 預設是 /etc , 因此會讀取 /etc/php.ini , 若設定此值非 /etc，則必須另外準備 php.ini 讓 php 能讀取
- PHP_INI_SCAN_DIR : 除了 /etc/php.d 之外，亦可再額外加入自訂目錄讓 php 載入其他 ini，例如 PHP_INI_SCAN_DIR=:/root/php.d，則代表除了 /etc/php.d 之外，也會掃 /root/php.d，這種做法則要再搭配 VOLUME /root/.replace-files 或 /root/.template-files 來置放設定檔才有辦法讀到

### NGINX Environment ###

- NGINX_DEFAULT_ROOT : 預設 Web 的根目錄
- NGINX_DEFAULT_SERVER_NAME : 預設 web 的 host name


## Docker for Windows 的建議 ##

1. 善用 Docker for Windows 推薦的 Kitematic 以 UI 來設定 VOLUME 做到檔案共享
2. Windows 中可設定 COMPOSER_HOME 變數，
   讓 composer 的快取能夠放在 SHARE DRIVE 內，
   然後可以再設定 container 的 VOLUME /root/.composer，
   這樣所有專案關於 composer cache 不論在 Windows Host 或 Container 都共用了。



## Maintainer ##

Pigo Chu
pigochu@gmail.com