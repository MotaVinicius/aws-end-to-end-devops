#!/bin/bash
yum update -y || dnf update -y

yum install -y nginx || dnf install -y nginx

systemctl enable nginx

cat <<EOF > /etc/nginx/nginx.conf
events {}

http {
    upstream backend {
        server ${app1_ip}:80;
        server ${app2_ip}:80;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend;
        }
    }
}
EOF

systemctl restart nginx

