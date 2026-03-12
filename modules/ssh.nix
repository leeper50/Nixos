{
  lib,
  config,
  ...
}:
{
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
        "aes128-ctr"
        "aes128-gcm@openssh.com"
        "aes192-ctr"
        "aes256-ctr"
        "aes256-gcm@openssh.com"
        "chacha20-poly1305@openssh.com"
      ];
      KbdInteractiveAuthentication = true;
      KexAlgorithms = [
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
        "ecdh-sha2-nistp256"
        "ecdh-sha2-nistp384"
        "ecdh-sha2-nistp521"
      ];
      LogLevel = "VERBOSE";
      Macs = [
        "hmac-sha2-256-etm@openssh.com"
        "hmac-sha2-256"
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-512"
        "umac-128-etm@openssh.com"
        "umac-128@openssh.com"
      ];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
