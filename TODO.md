# Future Goals

## Better DNS failover
Keep using adguardhome on docker swarm.
Run blocky on komodo & nas vms.
Maybe switch to blocky if its more stable.

## TLS everywhere
Use dns-01 certs for each device:
- *.laptop.dellhp.party
- *.node-1.dellhp.party
- etc.

Setup reverse proxy (nginx, maybe caddy or haproxy) to use cert for services:
- Adguard
  - Also try to use cert for dns-over-https
- Beszel
- Cockpit
- Syncthing

Limit access with mkFirewallRules with lan only access.