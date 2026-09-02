{ globals, ... }:
{
  services.fail2ban = {
    bantime = "24h";
    enable = true;
    ignoreIP = [
      "162.233.151.119/32"
      "2600:1702:58c1:9acf/64"
    ];
  };
  services.openssh = {
    allowSFTP = true;
    enable = true;
    ports = [ globals.sshPort ];
    settings = {
      AllowAgentForwarding = false;
      AllowTcpForwarding = "no";
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-ctr"
        "aes192-ctr"
        "aes256-ctr"
      ];
      ClientAliveCountMax = 2;
      ClientAliveInterval = 300;
      KbdInteractiveAuthentication = true;
      KexAlgorithms = [
        "mlkem768x25519-sha256"
        "sntrup761x25519-sha512"
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "ecdh-sha2-nistp256"
        "ecdh-sha2-nistp384"
        "ecdh-sha2-nistp521"
      ];
      LoginGraceTime = 20;
      LogLevel = "VERBOSE";
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-512"
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-256"
        "umac-128-etm@openssh.com"
        "umac-128@openssh.com"
      ];
      MaxAuthTries = 3;
      MaxSessions = 2;
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
      PermitTunnel = "no";
      PubkeyAuthentication = true;
      TCPKeepAlive = false;
      UseDns = false;
      X11Forwarding = false;
    };
  };
}
