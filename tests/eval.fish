#!/usr/bin/env fish

cd (status dirname)/..

set -l tmpdir (mktemp -d)

function list_attrs
    nix eval --json .#$argv[1] --apply builtins.attrNames 2>/dev/null | jq -r '.[]'
end

function job_id
    string replace -ra '[^A-Za-z0-9_.-]+' _ -- $argv[1]
end

function queue_configs
    set -l label $argv[1]
    set -l flake_attr $argv[2]
    set -l build_attr $argv[3]
    set -l tmpdir $argv[4]
    for h in (list_attrs $flake_attr)
        set -l full_label "$label: $h"
        set -l id (job_id $full_label)
        begin
            nix build --dry-run .#$flake_attr.$h.$build_attr >$tmpdir/$id.out 2>&1
            echo $status >$tmpdir/$id.code
        end &
        echo $full_label
    end
end

set -l jobs (queue_configs nixos nixosConfigurations config.system.build.toplevel $tmpdir)
set -a jobs (queue_configs home homeConfigurations activationPackage $tmpdir)
set -a jobs (queue_configs darwin darwinConfigurations config.system.build.toplevel $tmpdir)

set -l colmena_id (job_id colmena)
begin
    nix eval .#colmena.meta.specialArgs.globals.username >$tmpdir/$colmena_id.out 2>&1
    echo $status >$tmpdir/$colmena_id.code
end &
set -a jobs colmena

wait

set -l failed
for label in $jobs
    set -l id (job_id $label)
    echo "=== $label ==="
    if test (cat $tmpdir/$id.code) -ne 0
        cat $tmpdir/$id.out
        set -a failed $label
    end
end

rm -rf $tmpdir

if test (count $failed) -gt 0
    echo
    echo "failed:"
    for f in $failed
        echo "  - $f"
    end
    exit 1
end
