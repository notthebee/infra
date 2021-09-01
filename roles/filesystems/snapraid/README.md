# ansible-role-snapraid

An ansible role to install and configure [snapraid](https://www.snapraid.it/) and (optionally) [snapraid-runner](https://github.com/Chronial/snapraid-runner).

## Features

- Installation and configuration of `snapraid-runner` to aid scrubbing (optional)
- Automated creation of `sync` and `scrub` jobs
- [Healthchecks.io](https://healthchecks.io/) integration for cron jobs (optional)

## Configuration

This role has [many](./defaults/main.yml) variables which can be configured.

### Example

```yaml
snapraid_install: false
snapraid_runner: false

snapraid_data_disks:
  - path: /mnt/disk1
    content: true
  - path: /mnt/disk2
    content: true

snapraid_parity_disks:
  - path: /mnt/parity1
    content: true

snapraid_content_files:
  - /mnt/other-drive/snapraid.content
  - /var/snapraid.content

snapraid_config_excludes:
  - "*.unrecoverable"
  - /lost+found/
  - "*.!sync"
  - /tmp/

snapraid_scrub_schedule:
  hour: 5
  weekday: 4
```
