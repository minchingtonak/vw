#/usr/bin/env bash

mkdir -p vw-data
mkdir -p caddy-data
mkdir -p caddy-config
mkdir -p fail2ban-data

docker compose up -d
