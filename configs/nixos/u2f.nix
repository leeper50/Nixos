{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.u2f;
  mappings = lib.concatStringsSep ":" [
    "walter"
    "Mi7MXvTRvWnYuPjVZxo4Dapx7wQrwDj1KQPBTUsWx93t5WW8jMoI1qYIVNfo4pYaUxm8hG5gLPMKDpFIZ9ZEcQ==,289Zf5usJahaIkN2wUzvRXJ/OvUBxHKrjKu+ebyRkucLTeirPlr9B22tEu4Gy7CQxL9MNJJxodgpLBS6RxBYVg==,es256,+presence+pin"
    "r55N1pBhD88J2vqNGxfkQtyzxq85pyhZ9GEzxmGlUYnwwiQMqol1pOyf8KVoUOmhJPwHjvv1i6zPSrdaw/eQMg==,jlz0EZSdsE0MqtdhDT1mckvlLEycufgG9P3vhhZRQ6WoHc7/sEsFY31vnpHkUHnyz3vvLAvh3jdWTygYlxbj/w==,es256,+presence+pin"
    "ZLRQUKpWgDP91P74ORfy4CS/TbvnIyKdLuDKwWrtLIoJkb9cAfnmV57iArwLj18KY1hooNZmXAR2ACI+nWRb9Q==,F+L8zKvNanH45lTIEF4vdyph8zodem0CGY8U0JWKtJmd79kiZI5D7wPSxVceTJQBrcucVGRJMVXAZVBXJYmmzA==,es256,+presence+pin"
  ];
  origin = "pam://walter";
in
{
  options.local.u2f = {
    enable = lib.mkEnableOption "YubiKey (FIDO2 PIN and touch) as an alternative to the password";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      security.pam = {
        services.noctalia = { };
        u2f = {
          control = "sufficient";
          enable = true;
          settings = {
            appid = origin;
            authfile = pkgs.writeText "u2f-mappings" mappings;
            cue = true;
            inherit origin;
            pinverification = 1;
          };
        };
      };
    })
  ];
}
