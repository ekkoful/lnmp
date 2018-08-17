#! /bin/bash
#
# Auto add 163 repo and epel
#
# SystemVersion: Centos6
#
# Author: beechoing@126.com
#
# Github: https://github.com/beechoing
#
echo "自动配置yum源脚本准备执行,请确保网络连通^_^"

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/bin:/usr/sbin
clear

cd 

mv /etc/yum.repos.d/CentOS-Base.repo{,.bak}

wget http://mirrors.163.com/.help/CentOS6-Base-163.repo 

mv CentOS6-Base-163.repo /etc/yum.repos.d/

yum clean all

yum makecache

yum install epel-release -y 


