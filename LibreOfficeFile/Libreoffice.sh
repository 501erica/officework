# LibreOffice Onlineを有効にする
if [[ -n "$LIBREOFFICE_ONLINE_ENABLED" ]]; then
# dockerとdocker-composeのインストール
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io

systemctl start docker
systemctl enable docker

curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# LibreOffice Onlineを展開
cd ~/
git clone https://github.com/smehrbrodt/nextcloud-libreoffice-online.git
cd nextcloud-libreoffice-online/libreoffice-online/
cat << EOF > /root/nextcloud-libreoffice-online/libreoffice-online/.env
NEXTCLOUD_DOMAIN=192/.168/.3/.6
LO_ONLINE_USERNAME=root
LO_ONLINE_PASSWORD=kitaro615
LO_ONLINE_EXTRA_PARAMS=--o:ssl.enable=false
EOF

docker-compose up -d

# Collabora Onlineのインストール設定
sudo -u apache php72 /var/www/html/nextcloud/occ app:install richdocuments
# LibreOffice Onlineのアドレスを指定
sudo -u apache php72 /var/www/html/nextcloud/occ config:app:set richdocuments wopi_url --value=http:\/\/${GLOBAL_IP}:9980
# SSLを使わないため証明書の検証を無効にする
sudo -u apache php72 /var/www/html/nextcloud/occ config:app:set richdocuments disable_certificate_verification --value=yes
sudo -u apache php72 /var/www/html/nextcloud/occ app:enable richdocuments

# Firewall の設定
firewall-cmd --permanent --add-port=9980/tcp
fi
