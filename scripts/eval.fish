#!/usr/bin/env -S fish --no-config
# --no-config: NixOS's fish config replaces PATH with the system default when
# the environment wasn't set up by a login session (as under the CI runner),
# which drops the dev shell's tools.

# Build every NixOS host and push it to the attic cache, and dry-run build the
# Home Manager and nix-darwin configurations, or only the hosts named as
# arguments. Pushing is skipped when the attic client isn't logged in to a
# server that has the cache.
#
#   just test                 # all hosts
#   just test node-1          # just node-1
#   just test node-1 nas      # just node-1 and nas

cd (status dirname)/..

# CI runs as root, which nh refuses by default. Building never escalates, so
# the check only gets in the way.
set -gx NH_BYPASS_ROOT_CHECK true

# Prints one name per line; exits the script if the flake doesn't evaluate.
function list_attrs
    nix eval --raw .#$argv[1] --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)' 2>/dev/null
    or begin
        echo "error: could not evaluate .#$argv[1]; run `nix eval .#$argv[1]` to see why" >&2
        exit 1
    end
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
    set -l tmpdir $argv[2]
    test (count $argv) -ge 3; or return 0
    for h in $argv[3..]
        set -l full_label "$label: $h"
        set -l id (job_id $full_label)
        begin
            switch $label
                case nixos
                    nh os build . -H $h --no-nom -d never -o $tmpdir/$id.result
                case home
                    # nh home also hands extra args to the `nix eval` it uses
                    # to find the configuration, which rejects --dry-run.
                    nix build --dry-run .#homeConfigurations.$h.activationPackage
                case darwin
                    # nh's own --dry is ignored by `build`, so nix's is passed.
                    nh darwin build . -H $h --no-nom -d never -- --dry-run
            end >$tmpdir/$id.out 2>&1
            set -l code $status
            echo $code >$tmpdir/$id.code
            if test $code -eq 0; and set -q attic_push; and test -L $tmpdir/$id.result
                attic push $attic_cache (realpath $tmpdir/$id.result) >>$tmpdir/$id.out 2>&1
                or touch $tmpdir/$id.pushfail
            end
        end &
        echo $full_label
    end
end

if test (count $argv) -gt 0; and contains -- $argv[1] -h --help
    echo "usage: just test [host...]"
    echo
    echo "Build every NixOS host and push it to attic, dry-run the rest,"
    echo "or only the hosts named."
    exit 0
end

set -g requested_hosts $argv

set -l nixos_hosts (list_attrs nixosConfigurations)
set -l home_hosts (list_attrs homeConfigurations)
set -l darwin_hosts (list_attrs darwinConfigurations)
set -l known_hosts $nixos_hosts $home_hosts $darwin_hosts
if test (count $known_hosts) -eq 0
    echo "error: found no host configurations to build" >&2
    exit 1
end

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

set -g attic_cache homelab
if command -q attic; and attic cache info $attic_cache >/dev/null 2>&1
    set -g attic_push
end

set -l tmpdir (mktemp -d)

set -l jobs (queue_configs nixos $tmpdir (filter_hosts $nixos_hosts))
set -a jobs (queue_configs home $tmpdir (filter_hosts $home_hosts))
set -a jobs (queue_configs darwin $tmpdir (filter_hosts $darwin_hosts))

wait

set -l failed
set -l push_failed
for label in $jobs
    set -l id (job_id $label)
    # A missing or empty code (e.g. the disk filled up) counts as a failure.
    set -l code (cat $tmpdir/$id.code 2>/dev/null)
    if test "$code" != 0
        cat $tmpdir/$id.out
        set -a failed $label
    else if test -e $tmpdir/$id.pushfail
        cat $tmpdir/$id.out
        set -a push_failed $label
    end
end

rm -rf $tmpdir

# A failed push leaves the cache behind but the build itself is fine.
if test (count $push_failed) -gt 0
    echo >&2
    echo "warning: built but not pushed to attic:" >&2
    for f in $push_failed
        echo "  - $f" >&2
    end
end

if test (count $failed) -gt 0
    echo
    echo "failed:"
    for f in $failed
        echo "  - $f"
    end
    exit 1
end
