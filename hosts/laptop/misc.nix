{ pkgs, ... }:
let
  creamlinux = import (pkgs.fetchFromGitHub {
    owner = "Novattz";
    repo = "creamlinux-installer";
    rev = "main";
    hash = "sha256-sV23mp0XnJHf4oSqqvFLFfvSkssHzxafqYMNw3HGEdg=";
  }) { inherit pkgs; };
in
{
  environment.systemPackages = [ creamlinux ];
}
