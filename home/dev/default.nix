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
      astro-language-server
      bash-language-server
      bruno
      bun
      cargo
      cargo-update
      delve
      direnv
      docker-compose-language-service
      fish-lsp
      go
      golangci-lint-langserver
      gopls
      (lib.lowPrio gotools)
      htop
      jdk25
      kotlin
      kotlin-language-server
      lldb_22
      markdown-oxide
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
    ++ lib.optionals pkgs.stdenv.isLinux [
      k3s
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      wireguard-tools
    ];
  programs = {
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
