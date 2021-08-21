# notthebee/infra/ansible 

An Ansible playbook that sets up an Ubuntu/Debian-based home media server/NAS with reasonable security, auto-updates and dynamic DNS.

The playbook is mostly being developed for personal use, so stuff is going to be constantly changing and breaking. Use at your own risk and don't expect any help in setting it up on your machine.

## Services included:
#### Media
* [Plex](https://hub.docker.com/r/linuxserver/plex) (A media server)
* [Radarr](https://hub.docker.com/r/linuxserver/radarr) (A movie tracker/downloader)
* [Jackett](https://hub.docker.com/r/linuxserver/jackett) (A torrent/NZB indexer)
* [Sonarr](https://hub.docker.com/r/linuxserver/sonarr) (A TV show tracker/downloader)
* [Arch-DelugeVPN](https://hub.docker.com/r/binhex/arch-delugevpn) (An Arch Linux container running Deluge and an Wireguard/OpenVPN client with a kill switch)

#### Services
* [Homer](https://hub.docker.com/r/b4bz/homer) (A static home page)
* [Nextcloud](https://hub.docker.com/r/linuxserver/nextcloud) (A self-hosted cloud platform)
* [MariaDB](https://hub.docker.com/r/linuxserver/mariadb) (A database server for Nextcloud)
* [Vaultwarden](https://hub.docker.com/r/vaultwarden/server) (A FOSS Bitwarden fork written in Rust)
* [Wireguard](https://hub.docker.com/r/linuxserver/wireguard) (A VPN server)

#### Misc
* [Watchtower](https://hub.docker.com/r/containrrr/watchtower) (An automated updater for Docker images)
* [DuckDNS](https://hub.docker.com/r/linuxserver/duckdns/) (A dynamic DNS client for DuckDNS)
* [SWAG](https://hub.docker.com/r/linuxserver/swag) (A reverse proxy with built-in support for dynamic DNS, Certbot and fail2ban)

#### Home Automation
* [Home Assistant](https://hub.docker.com/r/homeassistant/home-assistant) (A FOSS smart home hub)
* [Phoscon-GW](https://hub.docker.com/r/marthoc/deconz) (A Zigbee gateway)

## Other features:
* MergerFS with Snapraid
* Samba
* Netatalk (AFP) for Time Machine

## Usage
Install Ansible (macOS):
```
brew install ansible
```

Clone the repository:
```
git clone https://github.com/notthebee/infra
```

Copy the sample inventory and adjust the variables in `vars.yml`:
```
cd infra/ansible
cp -r group_vars/sample group_vars/YOUR_HOSTNAME
vi group_vars/YOUR_HOSTNAME/vars.yml
```

Create a Keychain item for your Ansible Vault password (on macOS):
```
security add-generic-password \
               -a YOUR_USERNAME \
               -s ansible-vault-password \
               -w
```

The `pass.sh` script will extract the Ansible Vault password from your Keychain automatically each time Ansible requests it.

Encrypt the `secret.yml` file and adjust the variables:
```
ansible-vault encrypt group_vars/YOUR_HOSTNAME/secret.yml
ansible-vault edit group_vars/YOUR_HOSTNAME/secret.yml
```

Add your custom inventory file to `hosts`:
```
cp hosts_example hosts
vi hosts
```

Install the dependencies:
```
ansible-galaxy install -r requirements.yml
```

Finally, run the playbook:
```
ansible-playbook run.yml
```

For consecutive runs, if you only want to update the Docker containers, you can run the playbook like this:
```
ansible-playbook run.yml --tags="port,containers"
```
