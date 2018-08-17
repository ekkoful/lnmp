#! /bin/bash
# 
# The Script For Configure LNMP
#
# SystemVersion: CentOS 6.5
#
# SoftWareVersion: Nginx1.12.2 MySQL5.5.32 PHP5.5.38
#
# Author: beechoing@126.com
#
# GitHub: https://github.com/beechoing/lnmpauto.git
#

##编写Nginx服务启动脚本

if [ -x /etc/rc.d/init.d/nginx ];then 
	echo "nginx启动脚本已经存在"
else
touch /etc/rc.d/init.d/nginx
chmod +x /etc/rc.d/init.d/nginx

cat <<"EOF">/etc/rc.d/init.d/nginx
#!/bin/sh 
# 
# nginx - this script starts and stops the nginx daemin 
# 
# chkconfig: - 85 15 
# description: Nginx is an HTTP(S) server, HTTP(S) reverse \ 
# proxy and IMAP/POP3 proxy server 
# processname: nginx 
#
# config: /etc/nginx/nginx.conf 
# pidfile: /usr/local/nginx/logs/nginx.pid 

# Source function library. 
. /etc/rc.d/init.d/functions 

# Source networking configuration. 
. /etc/sysconfig/network 

# Check that networking is up. 
[ "$NETWORKING" = "no"  ] && exit 0 

nginx="/usr/local/nginx/sbin/nginx"
prog=$(basename $nginx)

NGINX_CONF_FILE="/etc/nginx/nginx.conf" 

lockfile=/var/lock/subsys/nginx 

start() { 
	[ -x $nginx  ] || exit 5 
	[ -f $NGINX_CONF_FILE  ] || exit 6 
	echo -n $"Starting $prog: " 
	daemon $nginx -c $NGINX_CONF_FILE 
	retval=$? 
	echo 
	[ $retval -eq 0  ] && touch $lockfile 
	return $retval 
} 

stop() { 
	echo -n $"Stopping $prog: " 
	killproc $prog -QUIT 
	retval=$? 
	echo 
	[ $retval -eq 0  ] && rm -f $lockfile 
	return $retval 
} 

restart() { 
	configtest || return $? 
	stop 
	start 
} 

reload() { 
	configtest || return $? 
	echo -n $"Reloading $prog: " 
	killproc $nginx -HUP 
	RETVAL=$? 
	echo 
} 

force_reload() { 
	restart 
} 

configtest() { 
	$nginx -t -c $NGINX_CONF_FILE 
} 

rh_status() { 
	status $prog 
} 

rh_status_q() { 
	rh_status >/dev/null 2>&1 
} 


case "$1" in 
	start) 
		rh_status_q && exit 0 
		$1 
		;;

		stop) 
		rh_status_q || exit 0 
		$1 
		;;

		restart|configtest) 
		$1 
		;;

		reload) 
		rh_status_q || exit 7 
		$1 
		;;

		force-reload) 
		force_reload 
		;;

		status) 
		rh_status 
		;;

		condrestart|try-restart) 
		rh_status_q || exit 0 
		;;

		*) 
		echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload|configtest}" 
		exit 2 
		;;
esac 
EOF
fi

##修改mysql配置文件
#增加mysql的数据目录,后才能正常启动
cp /etc/my.cnf{,.bak}
sed -i '/^\[mysqld\]/a datadir=/data/mysql' /etc/my.cnf

##修改mysql密码
source /etc/profile.d/lnmp.sh
service mysqld restart 

 mysqladmin -uroot password "123456"

##修改nginx配置文件
#
if [ -d /www/nginx ];then
	echo "nginx工作目录已经存在"
else
	mkdir /www/nginx -pv
fi

cp /etc/nginx/nginx.conf{,.bak}
sed -i '/^#pid/a pid   /var/run/nginx/nginx.pid;' /etc/nginx/nginx.conf
sed -i '/#error_page/a location ~ \.php$ {\n            root           /www/nginx;\n            fastcgi_pass   127.0.0.1:9000;\n            fastcgi_index  index.php;\n            fastcgi_param  SCRIPT_FILENAME  /www/nginx/$fastcgi_script_name;\n            include        fastcgi_params;\n        }' /etc/nginx/nginx.conf

sed -i 's#^location ~ \.php$ {#        location ~ \.php$ {#' /etc/nginx/nginx.conf

sed -i 's/index.html/index.php index.html/' /etc/nginx/nginx.conf
sed -i 's#root   html#root   /www/nginx#' /etc/nginx/nginx.conf

##修改php-fpm配置文件
cp /usr/local/php/etc/php-fpm.conf{,.bak}

sed -i 's#pm.max_children = 5#pm.max_children = 150#' /usr/local/php/etc/php-fpm.conf
sed -i 's#pm.start_servers = 2#pm.start_servers = 8#' /usr/local/php/etc/php-fpm.conf
sed -i 's#pm.min_spare_servers = 1#pm.min_spare_servers = 5#' /usr/local/php/etc/php-fpm.conf
sed -i 's#pm.max_spare_servers = 3#pm.max_spare_servers = 10#' /usr/local/php/etc/php-fpm.conf

##创建测试文件

touch /www/nginx/index.php
cat <<"EOF">/www/nginx/index.php
<?php
    $link = mysql_connect('127.0.0.1','root','123456');
	if ($link)
		echo "Success...";
	else
		echo "Failure...";
	mysql_close();
?>
EOF


service php-fpm start 
service nginx start

curl 127.0.0.1 --silent > test.txt
cat test.txt | grep Success
if [ $? == 0  ];then
		echo "LNMP环境配置完成"
	else
			echo "对不起,LNMP环境配置失败"
		fi
