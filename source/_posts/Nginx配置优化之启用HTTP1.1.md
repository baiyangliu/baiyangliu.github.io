title: Nginx配置优化之启用HTTP1.1
author: baiyangliu
date: 2016-12-26 14:15:32
tags:
- Nginx
categories:
- Nginx
---
###### 默认配置时
```
GET / HTTP/1.0
Host: baiyangliu.com
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
```
###### 修改配置
``` shell
proxy_http_version    1.1;
```
###### 再次请求
```
GET / HTTP/1.1
Host: baiyangliu.com
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
```

可以发现`HTTP/1.0`变成`HTTP/1.1`。