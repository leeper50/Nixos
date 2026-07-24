#!/usr/bin/env fish

cd (status dirname)

set -l failed 0

function list_attrs
    nix eval --json .#$argv[1] --apply builtins.attrNames 2>/dev/null | jq -r '.[]'
end

for h in (list_attrs nixosConfigurations)
    echo "=== nixos: $h ==="
    nix build --dry-run .#nixosConfigurations.$h.config.system.build.toplevel 2>&1 | tail -5
    if test $pipestatus[1] -ne 0
        set failed 1
    end
end

for h in (list_attrs homeConfigurations)
    echo "=== home: $h ==="
    nix build --dry-run .#homeConfigurations.$h.activationPackage 2>&1 | tail -5
    if test $pipestatus[1] -ne 0
        set failed 1
    end
end

for h in (list_attrs darwinConfigurations)
    echo "=== darwin: $h ==="
    nix build --dry-run .#darwinConfigurations.$h.config.system.build.toplevel 2>&1 | tail -5
    if test $pipestatus[1] -ne 0
        set failed 1
    end
end

echo "=== colmena ==="
nix eval .#colmena.meta.specialArgs.globals.username 2>&1 | tail -5
if test $pipestatus[1] -ne 0
    set failed 1
end

if test $failed -eq 1
    echo "one or more configurations failed"
    exit 1
end
