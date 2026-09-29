{ lib }:
{
  service,
  sources,
  protocols ? [ ],
  tcpPorts ? [ ],
  udpPorts ? [ ],
}:
let
  isV6 = source: lib.hasInfix ":" source;
  sourcesV4 = lib.filter (source: !isV6 source) sources;
  sourcesV6 = lib.filter isV6 sources;
  rule =
    family: familySources: match:
    lib.optionalString (familySources != [ ]) ''
      ${family} saddr { ${lib.concatStringsSep ", " familySources} } ${match} accept comment "${service}"
    '';
  portRules =
    family: familySources: protocol: ports:
    lib.optionalString (ports != [ ]) (
      rule family familySources "${protocol} dport { ${lib.concatMapStringsSep ", " toString ports} }"
    );
  protocolRules =
    family: familySources:
    lib.concatMapStrings (
      protocol: rule family familySources "meta l4proto ${toString protocol}"
    ) protocols;
in
{
  extraInputRules =
    portRules "ip " sourcesV4 "tcp" tcpPorts
    + portRules "ip " sourcesV4 "udp" udpPorts
    + protocolRules "ip " sourcesV4
    + portRules "ip6" sourcesV6 "tcp" tcpPorts
    + portRules "ip6" sourcesV6 "udp" udpPorts
    + protocolRules "ip6" sourcesV6;
}
