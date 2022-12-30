#/usr/bin/env bash

for dir in 'vw-data' 'caddy-data' 'caddy-config' 'fail2ban-data' 'countryblock-data'; do
    mkdir -p data/"$dir"
done

docker compose up -d

echo "Vaultwarden instance started!"
