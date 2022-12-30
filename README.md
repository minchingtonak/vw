
# vw

Ready-to-go Vaultwarden deployment using Docker Compose.

## Features

* Vaultwarden instance behind HTTPS-only reverse proxy with Caddy
* Brute-force attack protection with fail2ban
* Block IPs from specific countries with countryblock
* Optionally host at arbitrary subpath
* Log rotation for all services
* Sensible, secure default settings

## Usage

After completing the required setup below, run `./init.sh`.

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

Edit the settings in `vaultwarden/vaultwarden.env` to your liking. The defaults should be good for most deployments. See https://github.com/dani-garcia/vaultwarden/wiki/Configuration-overview

Note: account creation is disabled by default. To add new users, use the admin panel to invite a user by email and have them sign up normally using that email. You can allow anyone to create an account by setting `SIGNUPS_ALLOWED=true`, but this isn't recommended for security reasons.

#### Admin Panel

To enable the admin panel, generate a random token (`openssl rand -base64 48`) and add it to `vaultwarden/vaultwarden.env`:
```
ADMIN_TOKEN=<output of openssl rand -base64 48>
```

### Countryblock

Adapted from https://github.com/dadatuputi/bitwarden_gcloud. Credit: https://github.com/dadatuputi

By default, IPs from all countries except America are blocked. Update `COUNTRIES` in `countryblock/countryblock.env` as needed.

## Optional Setup

### Host at subpath

For additional security, you can host your Vaultwarden instance at a subpath of your domain.

1. Add a value for `DOMAIN_SUBPATH` to `caddy/caddy.env`:

```
DOMAIN_SUBPATH=/example-path # must start with a '/' and not end with a '/'
```

2. Add a value for `DOMAIN` to `vaultwarden/vaultwarden.env`. The value should be the full URL you want to host the Vaultwarden instance at, including the subpath:

```
DOMAIN=https://vw.example.com/example-path # must not end with '/'
```

3. Comment out the following lines in `caddy/Caddyfile`:

```
# Notifications redirected to the WebSocket server
reverse_proxy /notifications/hub vaultwarden:3012

# Proxy everything else to Rocket
reverse_proxy vaultwarden:8989 {
    # Send the true remote IP to Rocket, so that vaultwarden can put this in the
    # log, so that fail2ban can ban the correct IP.
    header_up X-Real-IP {remote_host}
}
```

4. Uncomment the following block in `caddy/Caddyfile`:

```
redir {$DOMAIN_SUBPATH} {$DOMAIN_SUBPATH}/ permanent

handle {$DOMAIN_SUBPATH}/* {
    # Notifications redirected to the WebSocket server
    reverse_proxy /notifications/hub vaultwarden:3012

    # Proxy everything else to Rocket
    reverse_proxy vaultwarden:8989 {
        # Send the true remote IP to Rocket, so that vaultwarden can put this in the
        # log, so that fail2ban can ban the correct IP.
        header_up X-Real-IP {remote_host}
    }
}

handle {
    respond "Access Denied" 403 {
      close
    }
}
```

## Security Tips

I'm working to add security mechanisms based on the recommendations on the [Vaultwarden wiki](https://github.com/dani-garcia/vaultwarden/wiki), plus some extras. That being said, there are also steps that you should take to secure your host:

* If you're using a VPS to host, make sure you set up access via SSH key instead of a password
* Use [`ufw`](https://wiki.ubuntu.com/UncomplicatedFirewall) to block all ports except the ones required by your application
* Use a **strong** master password. This is the last line of defense against an attacker who has stolen your encrypted password database.

## Disclaimer

I make no guarantees about the security of your data when using this project. I'm a software engineer by trade and have a reasonable understanding of computer security, but I'm by no means an expert. Please understand that I'm trying to provide as secure of an experience as possible, but there's always inherent risk when self-hosting.

I would not recommend self-hosting something as sensitive as your passwords if you don't have previous experience with devops & security.

## TODO

* Vault backups
* SMTP config for user invites
* Intrusion attempt notifications
* WAF with Coraza Caddy plugin. https://caddyserver.com/docs/modules/http.handlers.waf (requires custom docker image that builds caddy with plugin)
* VPN connection
* Optionally host at specified port for obscurity
