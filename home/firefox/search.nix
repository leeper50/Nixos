{
  default = "ddg_noai";
  engines = {
    ddg_noai = {
      name = "Duckduckgo No AI";
      urls = [ { template = "https://noai.duckduckgo.com/?q={searchTerms}"; } ];
      iconMapObj."16" = "https://noai.duckduckgo.com/favicon.ico";
      definedAliases = [ "@dd" ];
    };
  };
  force = true;
}
