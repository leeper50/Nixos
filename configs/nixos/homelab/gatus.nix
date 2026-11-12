# Off-site outage alerting for the LAN, in two halves:
# - local.gatus.enable (servercheap): Gatus, which emails through mailbox.org
#   when a reported check fails or a reporter stops reporting. The push API is
#   public (each push carries a bearer token); the status page is only on the
#   tailnet.
# - local.gatus.reporter.enable (a LAN host): checks the internet connection,
#   the DNS VIP and the gotify path every minute and pushes each result to
#   Gatus. Pushes go to servercheap's IP, so they don't depend on LAN DNS. If
#   Gatus can't be reached while the internet is up, falls back to gotify.
{
  config,
  globals,
  lib,
  pkgs,
  secrets,
  self,
  ...
}:
let
  cfg = config.local.gatus;
  pass = config.age.secrets;
  net = globals.networking;
  hostName = config.networking.hostName;
  port = 8090;
  publicDomain = "status.${globals.domains.primary}";
  tailnetDomain = "status.${globals.domains.deviceTailnet}";
  dnsTest = "dnstest.dellhplaptop.xyz";
  # node-3's own Caddy, skipping the VIP and LAN DNS.
  gotify = {
    host = "g.node-3.${globals.domains.primary}";
    ip = net.hosts.node-3.ipv4;
  };

  dig = server: name: ''
    out=$(${pkgs.dnsutils}/bin/dig +short +time=2 +tries=2 @${server} ${name} A) || exit 1
    [ -n "$out" ] || { echo "no answer for ${name} from ${server}"; exit 1; }
  '';
  ping =
    ip:
    "${pkgs.iputils}/bin/ping -q -c 3 -W 2 ${ip} > /dev/null || { echo '${ip} unreachable'; exit 1; }";
  curl = "${lib.getExe pkgs.curl} -fsS -m 10";

  # Ordered from the router outwards; the first failing one says where the
  # problem is. Gatus has one endpoint per name for each reporter.
  checks = {
    gateway = ping net.ipv4.gateway;
    internet = "${ping "9.9.9.9"} 2>/dev/null || ${ping "1.1.1.1"}";
    upstream-dns = dig "9.9.9.9" "example.com";
    vip-local = dig (lib.head net.nameservers.local) dnsTest;
    vip-recursion = dig (lib.head net.nameservers.local) "example.com";
    vip-ipv6 = dig (lib.elemAt net.nameservers.local 1) dnsTest;
    gotify = "${curl} -o /dev/null --resolve ${gotify.host}:443:${gotify.ip} https://${gotify.host}/health";
    gotify-via-vip = "${curl} -o /dev/null https://g.dellhplaptop.xyz/health";
  }
  # Each keepalived member's resolver, to catch lost redundancy early.
  // lib.listToAttrs (
    map (node: lib.nameValuePair "dns-${node}" (dig net.hosts.${node}.ipv4 dnsTest)) [
      "node-1"
      "node-2"
      "node-3"
      "nas"
    ]
  );

  # Server side.
  reporters = lib.attrNames (
    lib.filterAttrs (
      _: system: system.config.local.gatus.reporter.enable or false
    ) self.nixosConfigurations
  );
  token = "\${PROBE_TOKEN}";
  externalEndpoints = lib.concatMap (
    reporter:
    map (name: {
      inherit name token;
      group = reporter;
      alerts = [ { type = "email"; } ];
    }) (lib.attrNames checks)
    ++ [
      {
        name = "heartbeat";
        group = reporter;
        inherit token;
        heartbeat.interval = "5m";
        alerts = [
          {
            type = "email";
            failure-threshold = 1;
            description = "No results from ${reporter} for 5 minutes: home internet, power or ${reporter} is down.";
          }
        ];
      }
    ]
  ) reporters;

  start = pkgs.writeShellScript "gatus-start" ''
    SMTP_PASSWORD=$(tr -d '\n' < "$CREDENTIALS_DIRECTORY/smtp")
    PROBE_TOKEN=$(tr -d '[:space:]' < "$CREDENTIALS_DIRECTORY/token")
    export SMTP_PASSWORD PROBE_TOKEN
    exec ${lib.getExe config.services.gatus.package}
  '';

  # Reporter side.
  report = pkgs.writeShellScript "gatus-reporter" ''
    set -u
    token=$(tr -d '[:space:]' < "$CREDENTIALS_DIRECTORY/token")
    pushFailed=0

    # Usage: push <name> <true|false> [error]
    push() {
      printf 'header = "Authorization: Bearer %s"\n' "$token" |
        ${curl} -o /dev/null -K - -X POST -G \
          --resolve ${publicDomain}:443:${net.hosts.servercheap.ipv4} \
          --data-urlencode "success=$2" --data-urlencode "error=''${3:-}" \
          "https://${publicDomain}/api/v1/endpoints/${hostName}_$1/external" || pushFailed=1
    }

    # Usage: check <name> <script>
    check() {
      if out=$("$2" 2>&1); then
        push "$1" true
        echo "$1: ok"
      else
        err=$(printf '%s\n' "$out" | tail -n 1 | cut -c 1-200)
        push "$1" false "$err"
        echo "$1: failed: $err"
      fi
    }

    ${lib.concatStrings (
      lib.mapAttrsToList (name: script: ''
        check ${name} ${pkgs.writeShellScript "check-${name}" script}
      '') checks
    )}
    push heartbeat true

    # Fall back to gotify once Gatus has been unreachable for 3 runs in a row
    # while the internet works, and once more when it's back.
    state="$STATE_DIRECTORY/push-failures"
    count=$(cat "$state" 2>/dev/null || echo 0)
    if [ "$pushFailed" = 1 ] && ${pkgs.writeShellScript "check-internet" checks.internet} > /dev/null 2>&1; then
      count=$((count + 1))
    elif [ "$pushFailed" = 0 ]; then
      [ "$count" -ge 3 ] && ${notify} "gatus-reporter: Gatus reachable again" 4 "${hostName} can push to ${publicDomain} again."
      count=0
    fi
    [ "$count" = 3 ] && ${notify} "gatus-reporter: Gatus unreachable" 8 \
      "${hostName} can't push to ${publicDomain} (${net.hosts.servercheap.ipv4}) but the internet is up. Network outages won't be emailed until it's fixed."
    echo "$count" > "$state"
    exit 0
  '';

  notify = pkgs.writeShellScript "gatus-reporter-notify" ''
    printf 'header = "X-Gotify-Key: %s"\n' "$(tr -d '[:space:]' < "$CREDENTIALS_DIRECTORY/gotify")" |
      ${curl} -o /dev/null -K - --resolve ${gotify.host}:443:${gotify.ip} \
        --form-string "title=$1" --form-string "priority=$2" --form-string "message=$3" \
        https://${gotify.host}/message
  '';
in
{
  options.local.gatus = {
    enable = lib.mkEnableOption "Gatus outage alerting for LAN reporters";
    reporter.enable = lib.mkEnableOption "network outage checks reported to Gatus on servercheap";
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(checks ? heartbeat);
          message = "gatus: 'heartbeat' is reserved for the heartbeat endpoint.";
        }
      ];
    }
    (lib.mkIf cfg.enable {
      age.secrets = {
        "gatus_mail_app_password.age".file = "${secrets}/gatus_mail_app_password.age";
        "network_probe_token.age".file = "${secrets}/network_probe_token.age";
      };
      services.gatus = {
        enable = true;
        settings = {
          alerting.email = {
            default-alert = {
              failure-threshold = 3;
              send-on-resolved = true;
              success-threshold = 2;
            };
            from = globals.primaryEmail;
            host = "smtp.mailbox.org";
            password = "\${SMTP_PASSWORD}";
            port = 587;
            to = globals.primaryEmail;
            username = globals.primaryEmail;
          };
          # Skip heartbeat alerts while servercheap itself is offline.
          connectivity.checker = {
            interval = "1m";
            target = "9.9.9.9:53";
          };
          # Gatus needs at least one endpoint it checks itself. No alert: if
          # this fails, the email couldn't be sent anyway.
          endpoints = [
            {
              conditions = [ "[CONNECTED] == true" ];
              interval = "5m";
              name = "mailbox.org smtp";
              url = "starttls://smtp.mailbox.org:587";
            }
          ];
          external-endpoints = externalEndpoints;
          storage = {
            path = "/var/lib/gatus/data.db";
            type = "sqlite";
          };
          ui.title = "Home network";
          web = {
            address = "127.0.0.1";
            inherit port;
          };
        };
      };
      # The module's ExecStart can't read agenix files: load them as
      # credentials and export them for Gatus' ${VAR} interpolation.
      systemd.services.gatus.serviceConfig = {
        ExecStart = lib.mkForce start;
        LoadCredential = [
          "smtp:${pass."gatus_mail_app_password.age".path}"
          "token:${pass."network_probe_token.age".path}"
        ];
      };
      services.caddy.virtualHosts = {
        ${publicDomain} = {
          extraConfig = ''
            @push {
              method POST
              path_regexp ^/api/v1/endpoints/[^/]+/external$
            }
            handle @push {
              reverse_proxy 127.0.0.1:${toString port}
            }
            handle {
              abort
            }
          '';
          useACMEHost = config.local.caddy.domain;
        };
        ${tailnetDomain} = {
          extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
          useACMEHost = globals.domains.deviceTailnet;
        };
      };
    })
    (lib.mkIf cfg.reporter.enable {
      age.secrets = {
        "gotify_comin_token.age".file = "${secrets}/gotify_comin_token.age";
        "network_probe_token.age".file = "${secrets}/network_probe_token.age";
      };
      systemd.services.gatus-reporter = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          DynamicUser = true;
          ExecStart = report;
          LoadCredential = [
            "gotify:${pass."gotify_comin_token.age".path}"
            "token:${pass."network_probe_token.age".path}"
          ];
          StateDirectory = "gatus-reporter";
        };
      };
      systemd.timers.gatus-reporter = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          AccuracySec = "5s";
          OnBootSec = "1m";
          OnUnitActiveSec = "1m";
        };
      };
    })
  ];
}
