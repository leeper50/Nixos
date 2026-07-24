{ globals, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "no";
        Compression = false;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "10m";
        ForwardAgent = false;
        HashKnownHosts = false;
        IdentityFile = "~/.ssh/id_ed25519";
        ServerAliveCountMax = 3;
        ServerAliveInterval = 15;
        User = globals.username;
      };
      "gk55" = {
        HostName = "10.0.0.50";
        User = "root";
      };
      "hetzner" = {
        HostName = "u400147.your-storagebox.de";
        Port = 23;
        User = "u400147";
      };
      "komodo".HostName = "komodo.local";
      "laptop".HostName = "laptop.local";
      "nas".HostName = "nas.local";
      "node-1".HostName = "node-1.local";
      "node-2".HostName = "node-2.local";
      "node-3".HostName = "node-3.local";
      "proxmox" = {
        HostName = "10.0.0.30";
        User = "root";
      };
      "racknerd".HostName = "107.174.237.4";
      "servercheap".HostName = "65.75.202.6";
      "tower" = {
        HostName = "10.0.0.51";
        User = "root";
      };
    };
  };
}
