# LNMPAUTO
### 自动搭建LNMP环境脚本
1. 自动安装LNMP
2. 完成日期2017-12-19
3. Version:0.1
4. 此文档编辑日期2017-12-19

### 测试环境 && 软件版本
1. CentOS6.5 64Bit
2. Nginx1.12.2 + MySQL5.5.32 + PHP5.5.38
3. 测试机器配置2H1G

### 相关文件路径
1. Nginx1.12.2安装路径：/usr/local/nginx
2. Mysql5.5.32安装路径：/usr/local/mysql
3. PHP5.5.38安装路径：/usr/local/php
4. Nginx配置文件：/etc/nginx/nginx.conf
5. MySQL配置文件：/etc/my.cnf
6. PHP配置文件：/etc/php.ini
7. php-fpm配置文件：/usr/local/php/etc/php-fpm.conf
8. mysql数据路径：/data/mysql

### 相关配置
1. mysql密码为123456,可自行修改
2. nginx默认页面目录,/www/nginx

### 脚本功能
1. lnmpauto.sh：lnmp自动安装脚本
2. lnmpconf.sh：lnmp环境配置脚本

### 使用方法
```
   cd 
   git clone https://github.com/Beechoing/lnmpauto.git
   cd lnmpauto
   chmod +x *.sh
   ./yumrepo.sh    #如果没有配置epel源执行,否则不执行
   ./lnmpauto.sh
   ./lnmpconf.sh
```

## 注意事项
1. 执行脚本的过程保持网络畅通
2. 请确保已经安装epel源
3. 此脚本仅提供lnmp基本环境配置,nginx高级配置请自行配置


