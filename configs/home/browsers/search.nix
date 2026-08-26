{
  default = "ddg_noai";
  engines = {
    ddg_noai = {
      definedAliases = [ "@dd" ];
      iconMapObj."16" = "https://noai.duckduckgo.com/favicon.ico";
      name = "Duckduckgo No AI";
      urls = [ { template = "https://noai.duckduckgo.com/?q={searchTerms}"; } ];
    };
    searxng = {
      definedAliases = [ "@sx" ];
      iconMapObj."16" = "https://sx.dellhplaptop.xyz/favicon.ico";
      name = "Searxng";
      urls = [ { template = "https://sx.dellhplaptop.xyz/?q={searchTerms}"; } ];
    };
  };
  force = true;
}
