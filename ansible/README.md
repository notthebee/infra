# notthebee/infra/ansible 

An Ansible playbook that sets up an Ubuntu/Debian-based home media server/NAS with reasonable security, auto-updates and dynamic DNS.

The playbook is mostly being developed for personal use, so stuff is going to be constantly changing and breaking. Use at your own risk and don't expect any help in setting it up on your machine.

## Services included:
#### Media
* [https://hub.docker.com/r/linuxserver/plex](Plex) (A media server)
* [https://hub.docker.com/r/linuxserver/radarr](Radarr) (A movie tracker/downloader)
* [https://hub.docker.com/r/linuxserver/jackett](Jackett) (A torrent/NZB indexer)
* [https://hub.docker.com/r/linuxserver/sonarr](Sonarr) (A TV show tracker/downloader)
* [https://hub.docker.com/r/binhex/arch-delugevpn](Arch-DelugeVPN) (An Arch Linux container running Deluge and an Wireguard/OpenVPN client with a kill switch)

#### Services
* [https://hub.docker.com/r/b4bz/homer](Homer) (A static home page)
* [https://hub.docker.com/r/linuxserver/nextcloud](Nextcloud) (A self-hosted cloud platform)
* [https://hub.docker.com/r/linuxserver/mariadb](MariaDB) (A database server for Nextcloud)
* [https://hub.docker.com/r/vaultwarden/server](Vaultwarden) (A FOSS Bitwarden fork written in Rust)
* [https://hub.docker.com/r/linuxserver/wireguard](Wireguard) (A VPN server)

#### Misc
* [https://hub.docker.com/r/containrrr/watchtower](Watchtower) (An automated updater for Docker images)
* [https://hub.docker.com/r/linuxserver/duckdns/](DuckDNS) (A dynamic DNS client for DuckDNS)
* [https://hub.docker.com/r/linuxserver/swag](SWAG) (A reverse proxy with built-in support for dynamic DNS, Certbot and fail2ban)

#### Home Automation
* [https://hub.docker.com/r/homeassistant/home-assistant](Home Assistant) (A FOSS smart home hub)
* [https://hub.docker.com/r/marthoc/deconz](Phoscon-GW) (A Zigbee gateway)


Other features:
* MergerFS with Snapraid
* Samba
* Netatalk (AFS) for Time Machine
