#!/usr/bin/env sh
Green='\033[0;32m'
NC='\033[0m'

sudo su
yum install socat -y
curl https://get.acme.sh | sh


read -p "Please input domain name: " domain
read -p "Please input Godaddy API Key: " Key
read -p "Please input Godaddy API Secret: " Secret

export GD_Key="$Key"
export GD_Secret="$Secret"

./acme.sh -ecc --dnssleep 30 -k ec-384 --issue --dns dns_gd -d $domain -d "*.$domain"

echo copying files

cd /etc/strongswan/ipsec.d/certs
ln -s /root/.acme.sh/$domain_ecc/fullchain.cer fullchain.cer
cd /etc/strongswan/ipsec.d/private
ln -s /root/.acme.sh/$domain_ecc/$domain.key $domain.key
cd /etc/strongswan/ipsec.d/cacerts
ln -s /root/.acme.sh/$domain_ecc/ca.cer ca.cer

cat > /etc/strongswan/ipsec.d/cacerts/dst_root_ca_x3.cer <<EOF
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----
EOF

echo configuring /etc/strongswan/ipsec.conf

cat > /etc/strongswan/ipsec.conf <<EOF
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
    leftcert=fullchain.cer
    rightsourceip=10.0.18.0/24

	
conn ike2-eap
    also=IKE-BASE
    keyexchange=ikev2
    ike=aes256-sha256-modp2048,3des-sha1-modp2048,aes256-sha1-modp2048,aes256-sha1-modp1024!
    esp=aes256-sha256,3des-sha1,aes256-sha1!
    leftsendcert=always
    leftid=vpn.$domain
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
EOF

echo configuring /etc/strongswan/strongswan.conf

echo > /etc/strongswan/strongswan.conf <<EOF
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
EOF

printf "${Green}OK,We are almost succeeded.${NC}\n"
printf "${Green}Let's create a user account right now.${NC}\n"

read -p "Please input username: " username
read -p "Please input password: " password

echo > /etc/strongswan/ipsec.secrets <<EOF
#/etc/strongswan/ipsec.secrets

: RSA $domain.key

${username} : EAP "${password}"
EOF


echo configuring firewall

firewall-cmd --permanent --add-rich-rule='rule protocol value="esp" accept'
firewall-cmd --permanent --add-rich-rule='rule protocol value="ah" accept'
firewall-cmd --permanent --add-service="ipsec"
firewall-cmd --permanent --add-port=500/udp
firewall-cmd --permanent --add-port=4500/udp
firewall-cmd --permanent --add-masquerade
firewall-cmd --reload

echo configuring ip forward

sysctl -w net.ipv4.ip_forward = 1
sysctl -w net.ipv4.conf.all.accept_redirects = 0
sysctl -w net.ipv4.conf.all.send_redirects = 0


sysctl -p
systemctl enable strongswan
strongswan restart

printf "${Green}Seccedd.${NC}\n"
