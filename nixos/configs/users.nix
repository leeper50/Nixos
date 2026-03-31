{ config, pkgs, ... }:
let
  user_settings = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbDcD3eXAYp+ra3OXFLEDABbvVcBpY5yHEv9JULMBdW wleeper13@outlook.com"
    ];
    shell = pkgs.fish;
  };
in
{
  programs.fish.enable = true;
  users.users = {
    root = user_settings;
    walter = user_settings // {
      description = "Administrator";
      extraGroups = [
        "networkmanager"
        "walter"
        "wheel"
      ];
      hashedPasswordFile = config.age.secrets."user_walter_hash.age".path;
      isNormalUser = true;
    };
  };
}
