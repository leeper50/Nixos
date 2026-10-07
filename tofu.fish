#!/usr/bin/env fish

# Run OpenTofu against ./OpenTofu with secrets loaded and the VM inventory
# regenerated from flake.nix first.
#
#   ./tofu.fish plan
#   ./tofu.fish apply

cd (status dirname)

set -q AGE_IDENTITY; or set AGE_IDENTITY ~/.ssh/id_ed25519

if test -f secrets/tofu_env.age
    set -l env (age -d -i $AGE_IDENTITY secrets/tofu_env.age)
    or exit 1
    for line in $env
        string match -qr '^\s*(#|$)' -- $line; and continue
        set -l kv (string split -m1 = -- $line)
        set -gx $kv[1] $kv[2]
    end
else
    echo "warning: secrets/tofu_env.age not found; relying on terraform.tfvars / environment" >&2
end

nix eval --json .#proxmoxVms 2>/dev/null | jq . >OpenTofu/vms.json.new
and mv OpenTofu/vms.json.new OpenTofu/vms.json
or begin
    rm -f OpenTofu/vms.json.new
    echo "failed to evaluate .#proxmoxVms" >&2
    exit 1
end

tofu -chdir=OpenTofu $argv
