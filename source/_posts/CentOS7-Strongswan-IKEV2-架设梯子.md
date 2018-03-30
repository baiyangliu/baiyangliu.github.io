title: CentOS7 Strongswan IKEV2 架设梯子
author: baiyangliu
tags:
- Strongswan
categories:
- 科学上网
date: 2015-12-15 15:34:00
---
![长城防火墙](/imgs/firewall.jpg)
<!--more-->
参考：  
1.[https://linsir.org/post/how_to_install_IPSec_IKEV2_base_on_strongswan_with_CentOS7](https://linsir.org/post/how_to_install_IPSec_IKEV2_base_on_strongswan_with_CentOS7)
2.[https://raymii.org/s/tutorials/IPSEC_vpn_with_CentOS_7.html](https://raymii.org/s/tutorials/IPSEC_vpn_with_CentOS_7.html)

###### strongswan.sh
``` bash
#!/bin/sh
#strongswan.sh

yum install strongswan -y

yum install haveged -y
systemctl enable haveged
systemctl start haveged


cd /etc/strongswan
strongswan pki --gen --type rsa --size 4096 --outform der > ipsec.d/private/ca.key.der
chmod 600 ipsec.d/private/ca.key.der


strongswan pki --self --ca --lifetime 7300 --in ipsec.d/private/ca.key.der --type rsa --dn "C=CN, O=VPN, CN=StrongSwan Root CA" --outform der > ipsec.d/cacerts/ca.crt.der


strongswan pki --print --in ipsec.d/cacerts/ca.crt.der
strongswan pki --gen --type rsa --size 4096 --outform der > ipsec.d/private/vpn.key.der
openssl x509 -inform DER -in ipsec.d/cacerts/ca.crt.der -out ipsec.d/cacerts/ca.crt.pem -outform PEM
chmod 600 ipsec.d/private/vpn.key.der


strongswan pki --pub --in ipsec.d/private/vpn.key.der --type rsa | strongswan pki --issue --lifetime 7300 --cacert ipsec.d/cacerts/ca.crt.der --cakey ipsec.d/private/ca.key.der --dn "C=CN, O=VPN, CN=vpn.0xa.in" --san vpn.0xa.in --san 163.44.166.55  --san @163.44.166.55 --flag serverAuth --flag ikeIntermediate --outform der > ipsec.d/certs/vpn.crt.der
strongswan pki --print --in ipsec.d/certs/vpn.crt.der
openssl x509 -inform DER -in ipsec.d/certs/vpn.crt.der -noout -text


strongswan pki --gen --type rsa --size 4096 --outform der > ipsec.d/private/baiyangliu.key.der
chmod 600 ipsec.d/private/baiyangliu.key.der
strongswan pki --pub --in ipsec.d/private/baiyangliu.key.der --type rsa | strongswan pki --issue --lifetime 7300 --cacert ipsec.d/cacerts/ca.crt.der --cakey ipsec.d/private/ca.key.der --dn "C=CN, O=VPN, CN=vpn.0xa.in" --san "lc@baiyangliu.com" --outform der > ipsec.d/certs/baiyangliu.crt.der
openssl rsa -inform DER -in ipsec.d/private/baiyangliu.key.der -out ipsec.d/private/baiyangliu.key.pem -outform PEM
openssl x509 -inform DER -in ipsec.d/certs/baiyangliu.crt.der -out ipsec.d/certs/baiyangliu.crt.pem -outform PEM
openssl pkcs12 -export  -inkey ipsec.d/private/baiyangliu.key.pem -in ipsec.d/certs/baiyangliu.crt.pem -name "Baiyangliu VPN Certificate"  -certfile ipsec.d/cacerts/ca.crt.pem -caname "StrongSwan Root CA" -out baiyangliu.vpn.p12
```

###### /etc/strongswan/ipsec.conf
``` bash
#/etc/strongswan/ipsec.conf

config setup
    uniqueids=never


conn %default
    keyexchange=ike
    left=%any
    leftsubnet=0.0.0.0/0
    right=%any

conn IKE-BASE
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    leftcert=vpn.crt.der
    rightsourceip=10.0.18.0/24

	
conn ike2-eap
    also=IKE-BASE
    keyexchange=ikev2
    ike=aes256-sha256-modp2048,3des-sha1-modp2048,aes256-sha1-modp2048,aes256-sha1-modp1024!
    esp=aes256-sha256,3des-sha1,aes256-sha1!
    leftsendcert=always
    leftid=vpn.0xa.in
    leftauth=pubkey
    leftfirewall=yes
    rightauth=eap-mschapv2
    rightsendcert=never
    eap_identity=%any
    rekey=no
    dpdaction=clear
    fragmentation=yes
    auto=add


conn IPSec-IKEv1-PSK
    also=IKE-BASE
    keyexchange=ikev1
    fragmentation=yes
    leftauth=psk
    rightauth=psk
    rightauth2=xauth
    auto=add


conn IPSec-xauth
    also=IKE-BASE
    leftauth=psk
    leftfirewall=yes
    right=%any
    rightauth=psk
    rightauth2=xauth
    auto=add


```

###### /etc/strongswan/strongswan.conf
``` bash
#/etc/strongswan/strongswan.conf

charon {
    load_modular = yes
    duplicheck.enable = no
    compress = yes
    plugins {
        include strongswan.d/charon/*.conf
    }
    dns1 = 8.8.8.8
    dns2 = 8.8.4.4
	
    nbns1 = 8.8.8.8
    nbns2 = 8.8.4.4
}

include strongswan.d/*.conf
```

###### /etc/strongswan/ipsec.secrets
``` bash
#/etc/strongswan/ipsec.secrets

: RSA vpn.key.der

username1 : EAP "password1"
username2 : EAP "password2"
username3 : EAP "password3"
hipster: XAUTH "tbkiT571KxqpaKy/ap1H4kcWX0SZkogJ"
```

###### /etc/sysctl.conf
``` bash
net.ipv4.ip_forward = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
```
###### 配置防火墙
``` bash
firewall-cmd --permanent --add-rich-rule='rule protocol value="esp" accept'
firewall-cmd --permanent --add-rich-rule='rule protocol value="ah" accept'
firewall-cmd --permanent --add-service="ipsec"
firewall-cmd --permanent --add-port=500/udp
firewall-cmd --permanent --add-port=4500/udp
firewall-cmd --permanent --add-masquerade
firewall-cmd --reload
```
###### 启动
``` bash
sysctl -p
systemctl enable strongswan
strongswan restart
```
