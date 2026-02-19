#!/bin/bash
set -euxo pipefail

dnf install -y docker
systemctl enable docker
systemctl start docker

dnf install -y awscli

aws ecr get-login-password --region us-east-2 | \
docker login --username AWS --password-stdin <Registry URI>

docker pull <Image URI>

docker run -d \
  --name app \
  -p 80:80 \
  --restart always \
  <Image URI>


