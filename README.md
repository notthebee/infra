# notthebee/infra

An Ansible playbook that sets up an Ubuntu-based home media server/NAS with reasonable security, auto-updates, e-mail notifications for S.M.A.R.T. and Snapraid errors and dynamic DNS. 

It assumes a fresh Ubuntu Server 20.04 install, access to a non-root user with sudo privileges and a public SSH key. This can be configured during the installation process.

The playbook is mostly being developed for personal use, so stuff is going to be constantly changing and breaking. Use at your own risk and don't expect any help in setting it up on your machine.

## Special thanks
* David Stephens for his [Ansible NAS](https://github.com/davestephens/ansible-nas) project. This is where I got the idea and "borrowed" a lot of concepts and implementations from.
* Jeff Geerling for his book, [Ansible for DevOps](https://www.ansiblefordevops.com/) and his [Ansible 101 series](https://www.youtube.com/watch?v=goclfp6a2IQ&list=PL2_OBreMn7FqZkvMYt6ATmgC0KAGGJNAN) on YouTube.
* Jonathan Hanson for his [SSH port juggling](https://gist.github.com/triplepoint/1ad6c6060c0f12112403d98180bcf0b4) implementation.
* Alex Kretzschmar and Chris Fisher from [Self Hosted Show](https://selfhosted.show/) for introducing me to the idea of Infrastracture as Code
* TylerAlterio for the [mergerfs](https://github.com/tyalt1/mediaserver/tree/master/roles/mergerfs) role
* Jake Howard and Alex Kretzschmar for the [snapraid](https://github.com/RealOrangeOne/ansible-role-snapraid/commits?author=IronicBadger) role

## Services included:
#### Media
* [Plex](https://hub.docker.com/r/linuxserver/plex) (A media server)
* [Jellyfin](https://hub.docker.com/r/linuxserver/jellyfin) (Yet another media server)
* [Radarr](https://hub.docker.com/r/linuxserver/radarr) (A movie tracker/downloader)
* [Jackett](https://hub.docker.com/r/linuxserver/jackett) (A torrent/NZB indexer)
* [Booksonic](https://hub.docker.com/r/linuxserver/booksonic) (An audiobook server)
* [Sonarr](https://hub.docker.com/r/linuxserver/sonarr) (A TV show tracker/downloader)
* [arch-delugevpn](https://hub.docker.com/r/binhex/arch-delugevpn) (An Arch Linux container running Deluge and an Wireguard/OpenVPN client with a kill switch)

#### Services
* [Authelia](https://hub.docker.com/r/authelia/authelia) (An authentication provider)
* [cloudflare-ddns](https://hub.docker.com/r/oznu/cloudflare-ddns) (A dynamic DNS updater for Cloudflare)
* [UniFi Controller](https://hub.docker.com/r/linuxserver/unifi-controller) (A controller for UniFi devices)
* [Homer](https://hub.docker.com/r/b4bz/homer) (A static home page)
* [Flame](https://github.com/pawelmalak/flame) (Another static home page)
* [Nextcloud](https://hub.docker.com/r/linuxserver/nextcloud) (A self-hosted cloud platform)
* [PhotoPrism](https://hub.docker.com/r/linuxserver/photoprism) (A photo library)
* [PiHole + Unbound](https://github.com/chriscrowe/docker-pihole-unbound) (An all-in-one DNS solution with built-in ad-blocking)
* [MariaDB](https://hub.docker.com/r/linuxserver/mariadb) (A database server for Nextcloud)
* [Vaultwarden](https://hub.docker.com/r/vaultwarden/server) (A FOSS Bitwarden fork written in Rust)
* [Wireguard](https://hub.docker.com/r/linuxserver/wireguard) (A VPN server)
* [IKEv2](https://hub.docker.com/r/notthebee/ikev2) (An IKEv2 VPN server for Apple devices)

#### Misc
* [Watchtower](https://hub.docker.com/r/containrrr/watchtower) (An automated updater for Docker images)
* [DuckDNS](https://hub.docker.com/r/linuxserver/duckdns/) (A dynamic DNS client for DuckDNS)
* [SWAG](https://hub.docker.com/r/linuxserver/swag) (A reverse proxy with built-in support for dynamic DNS, Certbot and fail2ban)
* [bunkerized-nginx](https://github.com/bunkerity/bunkerized-nginx) (A NGINX-based web server focused on security)

#### Home Automation
* [Home Assistant](https://hub.docker.com/r/homeassistant/home-assistant) (A FOSS smart home hub)
* [Phoscon-GW](https://hub.docker.com/r/marthoc/deconz) (A Zigbee gateway)

## Other features:
* MergerFS with Snapraid
* Samba
* Fail2Ban for Nextcloud, Vaultwarden and endlessh with Cloudflare support
* CrowdSec with the iptables bouncer
* endlessh

## Usage
Install Ansible (macOS):
```
brew install ansible
```

Clone the repository:
```
git clone https://github.com/notthebee/infra
```

Create a host varialbe file and adjust the variables:
```
cd infra/ansible
mkdir -p host_vars/YOUR_HOSTNAME
vi host_vars/YOUR_HOSTNAME/vars.yml
```

Create a Keychain item for your Ansible Vault password (on macOS):
```
security add-generic-password \
               -a YOUR_USERNAME \
               -s ansible-vault-password \
               -w
```

The `pass.sh` script will extract the Ansible Vault password from your Keychain automatically each time Ansible requests it.

Create an encrypted `secret.yml` file and adjust the variables:
```
touch host_vars/YOUR_HOSTNAME/secret.yml
ansible-vault encrypt host_vars/YOUR_HOSTNAME/secret.yml
ansible-vault edit host_vars/YOUR_HOSTNAME/secret.yml
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
ansible-playbook run.yml -l your-host-here -K
```
The "-K" parameter is only necessary for the first run, since the playbook configures passwordless sudo for the main login user

For consecutive runs, if you only want to update the Docker containers, you can run the playbook like this:
```
ansible-playbook run.yml --tags="port,containers"
```


