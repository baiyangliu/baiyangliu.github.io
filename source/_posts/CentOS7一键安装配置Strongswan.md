title: CentOS7一键安装配置Strongswan
author: baiyangliu
date: 2015-12-15 15:37:08
tags:
- Strongswan
- IKEV2
- CentOS7
- Let's Encrypt
categories:
- 科学上网
---
前面介绍了如入用自签名证书，请参见[CentOS7 Strongswan IKEV2 架设梯子](/CentOS7-Strongswan-IKEV2-架设梯子.html)，这里介绍如何利用Let's Encrypthe和acme.sh DNS API自动签发证书，实现一键安装，同时省去导入证书的麻烦。
<!--more-->

###### 准备工作
1.新建API Key，[域名服务商支持列表](https://github.com/Neilpang/acme.sh#7-automatic-dns-api-integration)，如果你的域名服务商不在此列表中，请移步，或者迁移域名到[acme.sh](https://github.com/Neilpang/acme.sh)所支持的域名服务商；
2.导入API Key，例如：

如果你的域名服务商是GoDaddy，则执行
```bash
export provider=gd
export GD_Key="sdfsdfsdfljlbjkljlkjsdfoiwje"
export GD_Secret="asdfsdafdsfdsfdsfdsfdsafd"
```

如果你的域名服务商是阿里云，则执行
```bash
export provider=ali
export Ali_Key="sdfsdfsdfljlbjkljlkjsdfoiwje"
export Ali_Secret="jlsdflanljkljlfdsaklkjflsa"
```

Key和Secret从你第一步申请得到。

指定域名
```bash
#请换成你自己的域名
export domain=domain.com
```

###### 一键安装

```bash
curl -s https://baiyangliu.github.io/one_key_install_strongswan_with_lets_encrypt_and_godaddy_on_centos7.sh > a
chmod +x a
./a
rm -rf a
```


密码文件：```/etc/strongswan/ipsec.secrets```
