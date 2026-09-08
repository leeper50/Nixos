#!/usr/bin/env fish

# Dry-run build every host configuration, or only the ones named as arguments.
#
#   ./tests/eval.fish                 # all hosts (plus the colmena smoke test)
#   ./tests/eval.fish node-1          # just node-1
#   ./tests/eval.fish node-1 nas      # just node-1 and nas

cd (status dirname)/..

function list_attrs
    nix eval --json .#$argv[1] --apply builtins.attrNames 2>/dev/null | jq -r '.[]'
end

function job_id
    string replace -ra '[^A-Za-z0-9_.-]+' _ -- $argv[1]
end

function filter_hosts
    for h in $argv
        if test (count $requested_hosts) -eq 0; or contains -- $h $requested_hosts
            echo $h
        end
    end
end

function queue_configs
    set -l label $argv[1]
    set -l flake_attr $argv[2]
    set -l build_attr $argv[3]
    set -l tmpdir $argv[4]
    test (count $argv) -ge 5; or return 0
    for h in $argv[5..]
        set -l full_label "$label: $h"
        set -l id (job_id $full_label)
        begin
            nix build --dry-run .#$flake_attr.$h.$build_attr >$tmpdir/$id.out 2>&1
            echo $status >$tmpdir/$id.code
        end &
        echo $full_label
    end
end

if test (count $argv) -gt 0; and contains -- $argv[1] -h --help
    echo "usage: ./tests/eval.fish [host...]"
    echo
    echo "Dry-run build every host configuration, or only the ones named."
    exit 0
end

set -g requested_hosts $argv

set -l nixos_hosts (list_attrs nixosConfigurations)
set -l home_hosts (list_attrs homeConfigurations)
set -l darwin_hosts (list_attrs darwinConfigurations)
set -l known_hosts $nixos_hosts $home_hosts $darwin_hosts

set -l unknown
for h in $requested_hosts
    contains -- $h $known_hosts; or set -a unknown $h
end
if test (count $unknown) -gt 0
    echo "unknown host(s): $unknown" >&2
    echo >&2
    echo "available hosts:" >&2
    for h in $known_hosts
        echo "  - $h" >&2
    end
    exit 2
end

set -l tmpdir (mktemp -d)

set -l jobs (queue_configs nixos nixosConfigurations config.system.build.toplevel $tmpdir (filter_hosts $nixos_hosts))
set -a jobs (queue_configs home homeConfigurations activationPackage $tmpdir (filter_hosts $home_hosts))
set -a jobs (queue_configs darwin darwinConfigurations config.system.build.toplevel $tmpdir (filter_hosts $darwin_hosts))

if test (count $requested_hosts) -eq 0
    set -l colmena_id (job_id colmena)
    begin
        nix eval .#colmena.meta.specialArgs.globals.username >$tmpdir/$colmena_id.out 2>&1
        echo $status >$tmpdir/$colmena_id.code
    end &
    set -a jobs colmena
end

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
