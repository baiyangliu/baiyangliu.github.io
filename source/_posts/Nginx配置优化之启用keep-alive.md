title: Nginx配置优化之启用keep-alive
author: baiyangliu
date: 2016-12-26 14:56:16
tags:
- Nginx
categories:
-Nginx配置
---
###### 默认配置时
```
GET / HTTP/1.1
Host: baiyangliu.com
X-Real-IP: 192.168.1.1
X-Forwarded-For: 192.168.1.1
X-Forwarded-Proto: https
X-Forwarded-Port: 443
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Connection: close
```
###### 修改配置
``` shell
proxy_http_version    1.1;

upstream backends {
    server 192.168.1.129;
    keepalive 128;
}

locatioin / {
    proxy_set_header  Connection "keep-alive";
    proxy_pass        http://backends;
}
```
###### 再次请求
```
GET / HTTP/1.1
Host: baiyangliu.com
X-Real-IP: 192.168.1.1
X-Forwarded-For: 192.168.1.1
X-Forwarded-Proto: https
X-Forwarded-Port: 443
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Connection: keep-alive
```

可以发现`HTTP/1.0`变成`HTTP/1.1`，`Connection: close`变成`Connection: keep-alive`。