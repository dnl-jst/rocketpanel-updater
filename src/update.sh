#!/bin/bash

# check if ftp configuration exists, otherwise install it
if [ ! -f /opt/rocketpanel/etc/proftpd.conf ]; then

    echo create proftpd configuration file

    # copy proftpd configuration
    cp /app/proftpd.conf /opt/rocketpanel/etc/proftpd.conf

    # replace mysql root password
    sed -i -e 's/%%rocketpanel-root-password%%/`cat /opt/rocketpanel/.rocketpanel-mysql-root-password`/g' /opt/rocketpanel/etc/proftpd.conf
fi

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

# stop and remove old rocketpanel-caddy container
docker stop rocketpanel-caddy
docker rm rocketpanel-caddy

# stop and remove old rocketpanel-ftp container
docker stop rocketpanel-ftp
docker rm rocketpanel-ftp

# create main mysql container
docker run -d \
	--name rocketpanel-mysql \
	-e "MYSQL_ROOT_PASSWORD=`cat /opt/rocketpanel/.rocketpanel-mysql-root-password`" \
	-e "MYSQL_DATABASE=rocketpanel" \
	-v /opt/rocketpanel/mysql/data/:/var/lib/mysql \
	--restart always \
	mysql:5.7

# create rocketpanel control container
docker run -d \
	--name rocketpanel-control \
	--link rocketpanel-mysql:mysql \
	-e "WEB_DOCUMENT_ROOT=/app/web" \
	-v /opt/rocketpanel/:/opt/rocketpanel \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-p 8444:443 \
	--restart always \
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
    --restart always \
    abiosoft/caddy

# install proftpd as ftp server
docker run -d \
    --name rocketpanel-ftp \
    -v /opt/rocketpanel/etc/proftpd.conf:/usr/local/etc/proftpd.conf \
    -v /opt/rocketpanel/vhosts:/opt/rocketpanel/vhosts \
    -p 21:21 \
    -p 60000-60100:60000-60100 \
    --restart always \
    pockost/proftpd