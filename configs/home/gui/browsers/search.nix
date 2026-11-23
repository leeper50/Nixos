{
  default = "Duckduckgo No AI";
  engines =
    let
      nix_icon = "https://wiki.nixos.org/favicon.ico";
    in
    {
      "Duckduckgo No AI" = {
        definedAliases = [ "@dd" ];
        iconMapObj."16" = "https://noai.duckduckgo.com/favicon.ico";
        name = "Duckduckgo No AI";
        urls = [ { template = "https://noai.duckduckgo.com/?q={searchTerms}"; } ];
      };
      "Nix Packages" = {
        name = "Nix Packages";
        urls = [
          {
            template = "https://search.nixos.org/packages";
            params = [
              {
                name = "type";
                value = "packages";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        iconMapObj."16" = nix_icon;
        definedAliases = [ "@np" ];
      };
      "Nix Options" = {
        name = "Nix Options";
        urls = [
          {
            template = "https://search.nixos.org/options";
            params = [
              {
                name = "type";
                value = "options";
              }
              {
                name = "query";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        iconMapObj."16" = nix_icon;
        definedAliases = [ "@no" ];
      };
      "NixOS Wiki" = {
        name = "NixOS Wiki";
        urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
        iconMapObj."16" = nix_icon;
        definedAliases = [ "@nw" ];
      };
    };
  force = true;
}
