{
  lib,
  pkgs,
  systemType,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      android-tools
      bash-language-server
      cargo
      cargo-update
      delve
      docker-compose-language-service
      fish-lsp
      go
      golangci-lint-langserver
      gopls
      (lib.lowPrio gotools)
      jdk25
      kotlin
      kotlin-language-server
      lldb_22
      markdown-oxide
      nmap
      onefetch
      ragenix
      rclone
      restic
      rsync
      ruff
      rust-analyzer
      rustc
      shfmt
      svelte-language-server
      tinymist
      tombi
      typescript-language-server
      typos-lsp
      vscode-css-languageserver
      vscode-json-languageserver
      yaml-language-server
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      wireguard-tools
    ];
  programs = {
    bun = {
      enable = true;
      settings = {
        test = {
          coverage = true;
          coverageThreshold = 0.9;
        };
      };
    };
    direnv = {
      enable = true;
      enableFishIntegration = true;
    };
    gcc.enable = systemType != "Standalone";
    gitui.enable = true;
    helix = {
      languages = {
        language-server = {
          typos.command = "typos-lsp";
          golang-ci.command = "golangci-lint-langserver";
          gopls.command = "gopls";
        };
        language = [
          {
            auto-format = true;
            formatter = {
              command = "goimports";
            };
            language-servers = [
              "golang-ci"
              "gopls"
            ];
            name = "go";
          }
          {
            file-types = [
              "env"
              "ini"
            ];
            name = "ini";
          }
          {
            auto-format = true;
            formatter.command = "nixfmt";
            name = "nix";
          }
          {
            auto-format = true;
            formatter = {
              arguments = [ "check" ];
              command = "ruff";
            };
            name = "python";
          }
          {
            language-servers = [
              "tinymist"
              "typos"
            ];
            name = "typst";
          }
          {
            auto-format = true;
            file-types = [
              ".zsh"
              ".zshrc"
            ];
            formatter = {
              arguments = [
                "-s"
                "-w"
              ];
              command = "shfmt";
            };
            language-servers = [
              "bash-language-server"
            ];
            name = "zsh";
            scope = "zsh";
          }
        ];
      };
    };
  };
}
