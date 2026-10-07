#!/usr/bin/env fish

# --target defaults to the installer ISO's mDNS name, which every fresh VM
# shares, so only one VM can be installed at a time unless an address is given.
argparse build key root_pass= target= -- $argv
or return 2

if test -z "$argv[1]"
    echo "Missing hostname"
    return 1
end
set host "$argv[1]"

if set -q _flag_key
    rm -rdf /tmp/$host
    mkdir -p /tmp/$host/etc/ssh/
    ssh-keygen -N '' -f /tmp/$host/etc/ssh/ssh_host_ed25519_key -t ed25519 -a 32 -C "root@$host" &>/dev/null
    echo "Add to secrets/keys.nix"
    echo "$host = \"$(cat /tmp/$host/etc/ssh/ssh_host_ed25519_key.pub)\";"
    return $status
end

if test -z "$_flag_root_pass"
    echo "Must set root password of node when building"
    return 1
end

set -q _flag_target; or set _flag_target nixos-installer.local

if set -q _flag_build
    set -lx SSHPASS $_flag_root_pass
    nixos-anywhere \
        --env-password \
        --extra-files /tmp/$host \
        --flake .#$host \
        -p 22 \
        --target-host root@$_flag_target
    set -l rc $status
    rm -rdf /tmp/$host
    return $rc
end
