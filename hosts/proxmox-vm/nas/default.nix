{
  disko,
  globals,
  lib,
  localLib,
  pkgs,
  ...
}:
let
  hostIPv4 = globals.networking.lan.hosts.nas.ipv4;
in
{
  imports = [
    ../../../configs/nixos/homelab/adguardhome.nix
    ../../../configs/nixos/homelab/attic.nix
    ../../../configs/nixos/homelab/bentopdf.nix
    ../../../configs/nixos/homelab/docker.nix
    ../../../configs/nixos/homelab/forgejo.nix
    ../../../configs/nixos/homelab/gatus.nix
    ../../../configs/nixos/homelab/gotify.nix
    ../../../configs/nixos/homelab/homeassistant.nix
    ../../../configs/nixos/homelab/jellyfin.nix
    ../../../configs/nixos/homelab/mealie.nix
    ../../../configs/nixos/homelab/nfs.nix
    ../../../configs/nixos/homelab/postgresql.nix
    ../../../configs/nixos/homelab/redis.nix
    ../../../configs/nixos/homelab/redlib.nix
    ../../../configs/nixos/homelab/renovate.nix
    ../../../configs/nixos/homelab/rustfs.nix
    ../../../configs/nixos/homelab/samba.nix
    ../../../configs/nixos/homelab/vaultwarden.nix
    ../../../configs/nixos/syncthing.nix
    disko.nixosModules.disko
    (import ../vm-disk-config.nix {
      dataMountpoint = "/mnt/attic";
      dataFormat = "xfs";
      extraDisks.docker = {
        mountpoint = "/var/lib/docker";
        format = "xfs";
      };
    })
  ];
  environment.systemPackages = with pkgs; [
    nvtopPackages.intel
  ];
  fileSystems = {
    "/mnt/data" = {
      device = "/dev/disk/by-uuid/f7f51e6b-f23b-4aee-9498-6430dff7401e";
      fsType = "btrfs";
      options = [
        "degraded"
        "nofail"
        "noatime"
        "space_cache=v2"
      ];
    };
  };
  hardware.enableRedistributableFirmware = true;
  local = {
    adguardhome.enable = true;
    attic.enable = true;
    beszel = {
      agent.intelGpu = true;
      hub.enable = true;
    };
    bentopdf.enable = true;
    caddy = {
      enable = true;
      traefikPassthrough.enable = true;
    };
    docker = {
      komodo = {
        core.enable = true;
        coreIP = hostIPv4;
        periphery.enable = true;
      };
      swarm = {
        enable = true;
        labels = [
          "intel_gpu"
        ];
        manager = true;
        managerIP = hostIPv4;
      };
    };
    fail2ban.jails.traefik.enable = true;
    forgejo.server.enable = true;
    gatus.reporter.enable = true;
    gotify.enable = true;
    homeassistant = {
      mosquitto.enable = true;
      zigbee2mqtt.enable = true;
    };
    jellyfin.enable = true;
    local = true;
    mealie.enable = true;
    postgresql = {
      databases = [
        "forgejo"
        "freshrss"
        "mealie"
        "miniflux"
        "rxresume"
        "vaultwarden"
      ];
      enable = true;
    };
    redis = {
      databases = [
        "rxresume"
      ];
      enable = true;
    };
    redlib.enable = true;
    renovate.enable = true;
    restic.backups = {
      docker = {
        exclude = [
          "*cache*"
        ];
        paths = [
          "/etc/docker"
          "/var/lib/docker/volumes"
        ];
        user = "root";
      };
      postgresql = {
        paths = [ "/mnt/data/postgresql-backups" ];
        user = "root";
      };
    };
    rustfs.enable = true;
    syncthing = {
      enable = true;
      folder_type = "receiveonly";
      home = "/mnt/data/home/walter";
    };
    vaultwarden.enable = true;
  };
  networking = {
    interfaces.ens18 = {
      ipv4.addresses = lib.mkAfter [
        {
          address = lib.head globals.networking.lan.dns;
          prefixLength = 8;
        }
      ];
      ipv6.addresses = lib.mkAfter [
        {
          address = lib.elemAt globals.networking.lan.dns 1;
          prefixLength = lib.toIntBase10 globals.networking.lan.ipv6.subnetMask;
        }
      ];
    };
    firewall = localLib.mkFirewallRules {
      service = "traefik";
      sources = [
        "0.0.0.0/0"
        "::/0"
      ];
      tcpPorts = [
        80
        443
      ];
      udpPorts = [ 443 ];
    };
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/mnt/data" ];
  };
  systemd.services.docker = {
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
    unitConfig.RequiresMountsFor = [
      "/mnt/media"
      "/var/lib/docker"
    ];
  };
  system.stateVersion = "25.11";
}
