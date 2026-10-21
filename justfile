# vim: set ft=make :
set quiet
# Recipe arguments are also passed as "$@", so values containing spaces
# (e.g. a root password) reach the scripts as a single argument.
set positional-arguments

check:
  nix flake check

check-clean:
	if [ -n "$(git status --porcelain)" ]; then echo -e "\e[31merror\e[0m: git tree is dirty. Refusing to copy configuration." >&2; exit 1; fi

update:
  nix flake update

# Deploy to a host, Nixos only
deploy host:
    nix develop --command nh os switch -H {{host}} --target-host root@{{host}}

# Dry-run build every host, or only the ones named
test *hosts:
    ./scripts/eval.fish "$@"

# Run OpenTofu (plan, apply, ...) with secrets loaded and vms.json regenerated
tofu +args:
    ./scripts/tofu.fish "$@"

# Generate a VM host key (--key) or install a VM with nixos-anywhere (--build)
vm-builder +args:
    ./scripts/vm-builder.fish "$@"
