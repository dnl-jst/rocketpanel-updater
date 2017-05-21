#!/bin/bash

# fetch latest images
docker pull mysql:5.7
docker pull dnljst/rocketpanel-control
docker pull abiosoft/caddy

# stop and remove old rocketpanel-control container
docker stop rocketpanel-control
docker rm rocketpanel-control

# stop and remove old rocketpanel-mysql container
docker stop rocketpanel-mysql
docker rm rocketpanel-mysql

docker stop rocketpanel-caddy
docker rm rocketpanel-caddy

# create main mysql container
docker run -d \
	--name rocketpanel-mysql \
	-e "MYSQL_ROOT_PASSWORD=`cat /opt/rocketpanel/.rocketpanel-mysql-root-password`" \
	-e "MYSQL_DATABASE=rocketpanel" \
	-v /opt/rocketpanel/mysql/data/:/var/lib/mysql \
	mysql:5.7

# create rocketpanel control container
docker run -d \
	--name rocketpanel-control \
	--link rocketpanel-mysql:mysql \
	-e "WEB_DOCUMENT_ROOT=/app/web" \
	-v /opt/rocketpanel/:/opt/rocketpanel \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-p 8444:443 \
	dnljst/rocketpanel-control

# create caddycerts directory
mkdir -p /opt/rocketpanel/etc/caddycerts
touch /opt/rocketpanel/etc/Caddyfile

# install caddy as frontend reverse-proxy
docker run -d \
    --name rocketpanel-caddy \
    -e "CADDYPATH=/opt/rocketpanel/etc/caddycerts" \
    -v /opt/rocketpanel/etc/caddycerts:/opt/rocketpanel/etc/caddycerts \
    -v /opt/rocketpanel/etc/Caddyfile:/etc/Caddyfile \
    -p 80:80 -p 443:443 \
    abiosoft/caddy