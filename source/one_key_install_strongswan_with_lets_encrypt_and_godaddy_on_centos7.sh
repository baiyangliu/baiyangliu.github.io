#!/usr/bin/env sh


Green='\033[0;32m'
NC='\033[0m'

cd ~

echo Installing files
echo

sudo yum install epel-release -q -y
sudo yum install socat strongswan -q -y
curl -s https://get.acme.sh | sh

read -p "Please input domain: " domain
read -p "Please input provider(Defaut:gd): " provider
provider=${provider:-gd}

sh ~/.acme.sh/acme.sh --ecc --dnssleep 30 -k ec-384 --issue --dns dns_${provider} -d ${domain} -d "*.${domain}"

echo
echo Copying files
echo

sudo cd /etc/strongswan/ipsec.d/certs
sudo ln -f -s /root/.acme.sh/${domain}_ecc/fullchain.cer fullchain.cer
sudo cd /etc/strongswan/ipsec.d/private
sudo ln -f -s /root/.acme.sh/${domain}_ecc/${domain}.key ${domain}.key
sudo cd /etc/strongswan/ipsec.d/cacerts
sudo ln -f -s /root/.acme.sh/${domain}_ecc/ca.cer ca.cer

sudo bash -c 'cat > /etc/strongswan/ipsec.d/cacerts/dst_root_ca_x3.cer' <<EOF
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

echo Configuring /etc/strongswan/ipsec.conf

sudo bash -c 'cat > /etc/strongswan/ipsec.conf' <<EOF
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
    leftid=vpn.${domain}
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

echo Configuring /etc/strongswan/strongswan.conf

sudo bash -c 'cat > /etc/strongswan/strongswan.conf' <<EOF
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

echo
echo
printf "${Green}OK,We are almost succeeded.${NC}\n"
printf "${Green}Let's create a user account right now.${NC}\n"
echo
echo

read -p "Please input username: " username

read -p "Please input password: " password

sudo bash -c 'cat > /etc/strongswan/ipsec.secrets' <<EOF
#/etc/strongswan/ipsec.secrets
: RSA ${domain}.key
${username} : EAP "${password}"
EOF


echo Configuring firewall

sudo firewall-cmd --permanent --add-rich-rule='rule protocol value="esp" accept'
sudo firewall-cmd --permanent --add-rich-rule='rule protocol value="ah" accept'
sudo firewall-cmd --permanent --add-service="ipsec"
sudo firewall-cmd --permanent --add-port=500/udp
sudo firewall-cmd --permanent --add-port=4500/udp
sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --reload

echo
echo Configuring ip forward
echo

sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
sudo sysctl -w net.ipv4.conf.all.send_redirects=0


sudo sysctl -p
sudo systemctl enable strongswan
sudo strongswan restart

echo
echo
printf "${Green}Seccedd.${NC}\n"
echo

