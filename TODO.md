## Future Goals

Make better use of the options system for opt-in configs.

example:
```nix
  locals.profiles.cli.enable = true; # Enables all cli configs
  locals.profiles.dev.enable = true; # Enables all dev configs
  locals.profiles.gui.enable = true; # Enables all gui configs
```

Put more data into `/globals.nix` such as:
1. `/etc/hosts` mappings.
2. More network settings (gateways).