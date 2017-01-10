title: 使用rsync进行增量代码部署
author: baiyangliu
tags:
  - rsync
categories:
  - 工具
date: 2016-12-28 17:21:39
---
##### 问题来源
做过Java开发的都知道，Java有着丰富的类库，你所想要的功能，几乎都有开源实现。但问题是，依赖库的递归依赖，使得编译出的文件非常庞大。再者，每次重新部署，其实都只做了“相当少”的代码更新。如果是在公网环境，情况会更加糟糕。。。
>rsync是类unix系统下的数据镜像备份工具——remote sync。一款快速增量备份工具 Remote Sync，远程同步 支持本地复制，或者与其他SSH、rsync主机同步。

<!--more-->
##### 解决方案
如上所述，既然每次都做了大量的无用功，能不能避免呢？当然可以，rsync就可以做到。本文以Spring Boot程序为例，对于静态文件、PHP、NodeJS等都适用。服务端使用CentOS7.2，客户端Windows10。

##### 步骤
###### 服务端安装
```
yum install rsync -y
systemctl enable rsyncd.service
```
###### 修改配置文件`vim /etc/rsyncd.conf`
```bash
#认证用户名和密码文件的名称和位置
secrets file = /etc/rsyncd.secrets
#欢迎文件，可自己编辑
motd file = /etc/rsyncd.motd
read>list = yes
uid = root
gid = root
use chroot = no
max connections = 5
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock

[app]
comment = app
path = /opt/deploy
auth users = user1
read only = no
```
###### 生成密码文件
```bash
echo "user1:123456" >> /etc/rsyncd.secrets
chmod 600 /etc/rsyncd.secrets 
```
###### 添加防火墙例外
```bash
firewall-cmd --zone=dmz --add-port=873/tcp --permanent
firewall-cmd --reload
```
###### 启动服务
```bash
systemctl start rsyncd
```
###### 编译脚本（build.bat）
```DOS 
@echo off

set "CURRENT_DIR=%cd%"
svn co https://xxx %TMP%\xxx
svn update "%TMP%\xxx"

cd /D "%TMP%\xxx"

call gradle clean bootRepackage

call unzip -o   xxx/build/libs/*.jar -d xxx/build/libs/xxx

cd xxx/build/libs/xxx

set "src=/cygdrive/%CD::=/%"
set "src=%src:\=/%"

cd /D %CURRENT_DIR%

rem rsync下载地址(http://www.brentnorris.net/rsync.zip)
call rsync -vzrtopg --delete --progress --password-file=./rsyncd.secrets %src% user1@你的服务器地址::app


rem plink下载地址(https://the.earth.li/~sgtatham/putty/latest/x86/plink.exe)
call plink -ssh root@你的服务器地址 systemctl daemon-reload
call plink -ssh root@你的服务器地址 systemctl enable  "xxx.service"
call plink -ssh root@你的服务器地址 systemctl restart "xxx.service"

cd /D %CURRENT_DIR%
```
注意：客户端rsyncd.secrets文件内容为123456。