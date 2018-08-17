#!/bin/bash 
#
# This is a script for auto install LNMP
#
# Nginx + Mysql + PHP and PhpMyAdmin and so on
# 
# SystemVersion: CentOS 6.5 
#
# SoftWareVersion: Nginx1.12.2 MySQL5.5.32 PHP5.5.38 
#
# Author: beechoing@126.com
#
# GitHub: https://github.com/beechoing/lnmpauto.git
#
export PATH=/usr/bin:/usr/sbin:/usr/local/bin:/usr/loca/sbin:/bin:/sbin
clear 
#
echo "自动安装脚本已经开始执行,请耐心等待^_^"
echo "部分安装记录存入文件~/.lnmpinstall.log"  

echo 'export PATH=$PATH:/usr/local/nginx/sbin:/usr/local/mysql/bin:/usr/local/php/bin' > /etc/profile.d/lnmp.sh
source /etc/profile.d/lnmp.sh 

cd 

touch ~/.lnmpinstall.log
log=~/.lnmpinstall.log

## 创建目录保存下载的源码包
mkdir /sourcelnmp 
mkdir /makelnmp    #解压后保存的安装包
echo "正在下载源码包..."
wget http://nginx.org/download/nginx-1.12.2.tar.gz -qP /sourcelnmp
wget https://downloads.mysql.com/archives/get/file/mysql-5.5.32.tar.gz -qP /sourcelnmp
wget http://cn2.php.net/get/php-5.5.38.tar.gz/from/this/mirror -qO /sourcelnmp/php-5.5.38.tar.gz

## 安装编译环境
echo "安装开发环境" >> $log
yum -y groupinstall "Development tools" >> $log
yum -y groupinstall "Server Platform Development" >> $log
yum -y install bzip2-devel libmcrypt-devel libxml2-devel >> $log
yum -y install libaio >> $log
yum -y install pcre-devel >> $log
yum -y install cmake >> $log
yum -y install openssl-devel >> $log
yum -y install curl-devel >> $log 

##  准备安装Nginx
echo "创建nginx用户" | tee -a $log
groupadd -r nginx 
useradd -r -g nginx -s /sbin/nologin -M nginx 

echo "准备编译安装Nginx1.12.2^_^" | tee -a $log
cd 
cd /sourcelnmp 
tar xf nginx-1.12.2.tar.gz -C /makelnmp/
cd /makelnmp/nginx-1.12.2
./configure \
	--prefix=/usr/local/nginx \
	--sbin-path=/usr/local/nginx/sbin/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error_log \
	--http-log-path=/var/log/nginx/access_log \
	--pid-path=/var/run/nginx/nginx.pid \
	--lock-path=/var/lock/nginx.lock \
	--user=nginx \
	--group=nginx \
	--with-http_ssl_module \
	--with-http_flv_module \
	--with-http_stub_status_module \
	--with-http_gzip_static_module \
	--http-client-body-temp-path=/var/tmp/nginx/client/ \
	--http-proxy-temp-path=/var/tmp/nginx/proxy/ \
	--http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ \
	--http-uwsgi-temp-path=/var/tmp/nginx/uwsgi/ \
	--http-scgi-temp-path=/var/tmp/nginx/scgi/ \
	--with-pcre 
make 
make install

mkdir -p /var/tmp/nginx/{client,proxy,fcgi,uwsgi,scgi}

## 安装MySQL
echo "创建mysql用户mysql组" | tee -a $log
cd 
mkdir -p /data/mysql 
groupadd -r mysql 
useradd -r -g mysql -s /sbin/nologin -d /data/mysql -M mysql 


echo "正在编译安装MySQL5.5.32^_^......" | tee -a $log
cd 
tar xf /sourcelnmp/mysql-5.5.32.tar.gz -C /makelnmp/
cd /makelnmp/mysql-5.5.32
cmake \
	-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
	-DMYSQL_DATADIR=/data/mysql \
	-DSYSCONFDIR=/etc \
	-DWITH_MYISAM_STORAGE_ENGINE=1 \
	-DWITH_INNOBASE_STORAGE_ENGINE=1 \
	-DWITH_MEMORY_STORAGE_ENGINE=1 \
	-DWITH_READLINE=1 \
	-DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock \
	-DMYSQL_TCP_PORT=3306 \
	-DENABLED_LOCAL_INFILE=1 \
	-DWITH_PARTITION_STORAGE_ENGINE=1 \
	-DEXTRA_CHARSETS=all \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DMYSQL_USER=mysql \
	-DWITH_DEBUG=0 \
	-DWITH_SSL=system 
make
make install 

cd /usr/local/mysql 
chown -R mysql:mysql .
scripts/mysql_install_db --user=mysql --datadir=/data/mysql --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql 
chown -R root .

## 为mysql提供服务文件
cd /usr/local/mysql 
cp support-files/mysql.server /etc/rc.d/init.d/mysqld

chkconfig --add mysqld 

## 为mysql提供配置文件
cd /usr/local/mysql
cp support-files/my-large.cnf /etc/my.cnf


## 增加man文档
echo 'MANPATH /usr/local/mysql/man' >> /etc/man.config

ln -sv /usr/local/mysql/include /usr/include/mysql 
ldconfig 


## 安装php5.5.38
echo "正在编译安装PHP5.5.38^_^......" | tee -a $log 
cd 
tar xf /sourcelnmp/php-5.5.38.tar.gz -C /makelnmp/
cd /makelnmp/php-5.5.38
./configure \
	--prefix=/usr/local/php \
	--with-mysql=/usr/local/mysql \
	--with-openssl \
	--enable-fpm \
	--enable-sockets \
	--enable-sysvshm \
	--with-mysqli=/usr/local/mysql/bin/mysql_config \
	--enable-mbstring \
	--with-freetype-dir \
	--with-jpeg-dir \
	--with-png-dir \
	--with-zlib-dir \
	--with-libxml-dir=/usr \
	--enable-xml \
	--with-mhash \
	--with-mcrypt \
	--with-config-file-path=/etc \
	--with-config-file-scan-dir=/etc/php.d \
	--with-bz2 \
	--with-curl 
make 
make install

echo "为php提供配置文件" | tee -a $log 
cp php.ini-production /etc/php.ini 

echo "为php-fpm提供配置文件和启动脚本" | tee -a $log
cp sapi/fpm/init.d.php-fpm /etc/rc.d/init.d/php-fpm 
chmod +x /etc/rc.d/init.d/php-fpm 
chkconfig --add php-fpm
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf





