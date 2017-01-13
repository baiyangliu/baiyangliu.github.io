title: Nginx反向代理，tomcat request.getScheme() 总是返回http
author: baiyangliu
tags:
- Nginx
- Tomcat
categories:
- Nginx配置
date: 2015-12-15 15:32:00
---
错误如下：
```java
request.getScheme()  //总是 http，而不是实际的http或https  
request.isSecure()  //总是false（因为总是http）  
request.getRemoteAddr()  //总是 nginx 请求的 IP，而不是用户的IP  
request.getRequestURL()  //总是 nginx 请求的URL 而不是用户实际请求的 URL  
response.sendRedirect( 相对url )  //总是重定向到 http 上 （因为认为当前是 http 请求）
```
<!--more-->
解决办法：
修改nginx配置：
```shell
 proxy_set_header  Host $host;
 proxy_set_header  X-Real-IP  $remote_addr;
 proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
 proxy_set_header  X-Forwarded-Proto  $scheme;
 proxy_pass        http://backends;
```
修改tomcat（conf/server.xml），在Engine节点添加
```xml
<Valve className="org.apache.catalina.valves.RemoteIpValve"
              remoteIpHeader="X-Forwarded-For"
              protocolHeader="X-Forwarded-Proto"
              protocolHeaderHttpsValue="https"/>
```
重启服务即可。