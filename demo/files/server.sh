#!/usr/bin/env bash
set -euo pipefail

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Install dependencies

apt-get update
apt-get install -y git

curl -fsSL get.docker.com | sh -

curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Application
mkdir -p /opt/comicchat

cd /opt/comicchat
git clone ${url} ./
git checkout ${branch}

docker-compose up -d server
