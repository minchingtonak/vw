
# vw

Ready-to-go Vaultwarden deployment using Docker Compose.

## Features

* Vaultwarden instance behind HTTPS-only reverse proxy with Caddy
* Brute-force attack protection with fail2ban
* Block IPs from specific countries with countryblock
* Log rotation for all services
* Sensible, secure default settings

## Setup

### Caddy

You must use a custom domain to host the instance for security reasons. Make sure that you create an A record for your domain/subdomain that points to the host machine:

| Name | Type | TTL | Data |
| --- | --- | --- | --- |
| vw.example.com | A | \<up to you\> | \<IP of the host machine\>

Caddy automatically obtains and renews SSL certificates for you. Add the domain that the instance will be hosted on and email to use for automatic SSL certificate registration (via ACME) to `caddy/caddy.env`:
```
DOMAIN=https://vw.example.com # domain must not end with '/'
EMAIL=example@mail.com # The email address to use for ACME registration
```

### Vaultwarden

#### Admin Panel

To enable the admin panel, generate a random token (`openssl rand -base64 48`) and add it to `vaultwarden/vaultwarden.env`:
```
ADMIN_TOKEN=<output of openssl rand -base64 48>
```

Edit the settings in `vaultwarden/vaultwarden.env` to your liking. The defaults should be good for most deployments. See https://github.com/dani-garcia/vaultwarden/wiki/Configuration-overview

Note: account creation is disabled by default. To add new users, use the admin panel to invite a user by email and have them sign up normally using that email. You can allow anyone to create an account by setting `SIGNUPS_ALLOWED=true`, but this isn't recommended for security reasons.

### Countryblock

Adapted from https://github.com/dadatuputi/bitwarden_gcloud. Credit: https://github.com/dadatuputi

By default, IPs from all countries except America are blocked. Update `COUNTRIES` in `countryblock/countryblock.env` as needed.

## TODO

* Vault backups
* WAF with Coraza Caddy plugin. https://caddyserver.com/docs/modules/http.handlers.waf
