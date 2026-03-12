{ ... }:
{
  services.fail2ban.enable = true;
  services.openssh = {
    allowSFTP = false;
    enable = true;
    extraConfig = ''
      AllowAgentForwarding no
      AllowTcpForwarding no
      ClientAliveCountMax 0
      ClientAliveInterval 300
      MaxAuthTries 3
      MaxSessions 2
      TCPKeepAlive no
    '';
    ports = [ 22 ];
    settings = {
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-ctr"
        "aes192-ctr"
        "aes256-ctr"
      ];
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
      LogLevel = "VERBOSE";
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-512"
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-256"
        "umac-128-etm@openssh.com"
        "umac-128@openssh.com"
      ];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
