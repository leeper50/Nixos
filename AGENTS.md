# AGENTS.md

Nix flake for all of my machines: NixOS hosts (laptop, Proxmox VMs, VPSes), a
nix-darwin macbook, and a standalone Home Manager workstation. Read `README.md`
for the folder layout and the Proxmox VM workflow.

## Commands

- Tools: `nix develop` (or direnv via `.envrc`) provides ragenix, tofu,
  nixos-rebuild, nixfmt, deadnix, typos, jq and fish, and installs the
  pre-commit hook.
- Check: `./tests/eval.fish [host ...]` dry-run builds every host (or the ones
  named); it prints nothing on success. CI (`.forgejo/workflows/check.yml`)
  runs it plus `.#checks.x86_64-linux.pre-commit`.
- Format: `nix fmt`. The pre-commit hook rejects commits that fail nixfmt,
  deadnix or typos. Prefix unused lambda arguments with `_`; add spellcheck
  false positives to `_typos.toml`. Don't disable the hooks.
- Deploy one host manually (normally comin does it):
  `nixos-rebuild switch --flake .#<host> --target-host <host> --sudo`.

## Things that will bite you

- **Pushing to `main` deploys.** Every NixOS host runs comin, which pulls
  `main` from the Forgejo remote and builds and switches on the host itself.
  Never push without being asked.
- **Flakes only see git-tracked files.** `git add` new files before evaluating,
  or the flake will say they don't exist.
- **Host shells are fish.** Bash one-liners over SSH fail; send scripts with
  `ssh <host> bash -s < script.sh`.
- **Docker published ports bypass the NixOS firewall.** Docker DNATs them
  before `networking.firewall` sees the traffic. For LAN-only services, use
  host networking or bind to `127.0.0.1` behind Caddy.
- **Temporary pins.** `nixpkgs-authelia` in `flake.nix` holds authelia back
  until nixpkgs is fixed; its database is at schema 29, so never pin anything
  older. Remove the input and its overlay together.

## Conventions

- **One file per service, owning everything it needs:** options, firewall
  rules, users/groups, `age.secrets`, reverse-proxy entries.
- **Module shape:** declare `options.local.<name>.enable`, and wrap config in
  `lib.mkMerge [ (lib.mkIf cfg.enable { ... }) ... ]`. Hosts import modules
  by path from `configs/nixos/homelab/` and enable them under `local`.
- **Helpers:** `localLib` (`configs/nixos/lib/`) provides `mkFirewallRules`
  (source-restricted ports) and `mkCaddyVirtualHosts`. Use them instead of
  raw `networking.firewall` or Caddy config.
- **Shared values** (IPs, domains, subnets, username) live in `globals.nix`;
  reference `globals.*` instead of hard-coding them.
- **Scope:** `configs/nixos` is NixOS-only, `configs/darwin` nix-darwin-only,
  `configs/home` works under any Home Manager setup. In standalone Home
  Manager `osConfig` is `null`, so guard any use of it.
- **Secrets:** agenix (ragenix). A module declares its own `age.secrets.*`;
  `secrets/secrets.nix` only lists recipients. Rekey with `ragenix -r` in
  `secrets/`. Never print or commit decrypted secrets.
- **Swarm VMs** (`node-1..3`) are built by `mkSwarmHost` in `flake.nix`, which
  also holds each VM's Proxmox shape for OpenTofu.
- **Commits:** `<scope>: <change>`, lowercase and imperative, where scope is
  the module or host touched (`redlib: switch to luciferscircle fork`,
  `node-3: enable redlib`, `flake: bump nixpkgs`).
  - Add a body only when the diff doesn't explain why: workarounds, pins,
    non-obvious choices.
  - One logical change per commit, since each commit on `main` is a deploy
    and `git revert` is the rollback. Keep `flake.lock` bumps in their own
    commit.
  - No vague subjects (`fixes`, `update`, `wip`).
