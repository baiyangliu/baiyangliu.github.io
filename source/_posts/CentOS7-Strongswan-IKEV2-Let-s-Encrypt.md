title: CentOS7 Strongswan IKEV2 Let's Encrypt
author: baiyangliu
date: 2015-12-15 15:37:08
tags:
- Strongswan
categories:
- 科学上网
---
前面介绍了如入用自签名证书，请参见[CentOS7 Strongswan IKEV2 架设梯子](/CentOS7-Strongswan-IKEV2-架设梯子.html)，这里介绍如何利用Let's Encrypt签发证书省去导入的麻烦。
<!--more-->
关于证书签发，请参见[acme.sh](https://github.com/Neilpang/acme.sh)，由于本站的域名已转移至[Godaddy](https://godaddy.com/)，利用acme.sh可以实现全自动证书签发。

例如：为0xa.in域名签发证书，签发完后，证书位于`/root/.acme.sh/0xa.in`目录下。
接下来，执行以下命令
```bash
cd /etc/strongswan/ipsec.d/certs
ln -s /root/.acme.sh/0xa.in/fullchain.cer fullchain.cer
cd /etc/strongswan/ipsec.d/private
ln -s /root/.acme.sh/0xa.in/0xa.in.key 0xa.in.key
cd /etc/strongswan/ipsec.d/cacerts
ln -s /root/.acme.sh/0xa.in/ca.cer ca.cer
```

到这里，很多人会忘记配置根证书，从而出现错误“13801:IKE身份验证凭证不可接受”。解决办法是把`DST ROOT CA X3`给导入进来。

```bash
curl -o /etc/strongswan/ipsec.d/cacerts/dst_root_ca_x3.cer https://baiyangliu.github.io/dst_root_ca_x3.cer
```

修改 /etc/strongswan/ipsec.conf，` leftcert=fullchain.cer`


修改 /etc/strongswan/ipsec.secrets，`: RSA 0xa.in.key`

重启服务，`strongswan restart`。

客户端连接的时候就不需要导入证书了。。。
