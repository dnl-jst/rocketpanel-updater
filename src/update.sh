#!/bin/bash

# fetch updates
docker pull mysql:5.7
docker pull dnljst/rocketpanel-control

# stop and remove old rocketpanel-control container
docker stop rocketpanel-control
docker rm rocketpanel-control

# stop and remove old rocketpanel-mysql container
docker stop rocketpanel-mysql
docker rm rocketpanel-mysql

# create main mysql container
docker run -d \
	--name rocketpanel-mysql \
	-e "MYSQL_ROOT_PASSWORD=rootpass" \
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