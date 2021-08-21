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

Other features:
* MergerFS with Snapraid
* Samba
* Netatalk (AFS) for Time Machine
