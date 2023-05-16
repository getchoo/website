{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.getchoo-website;
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options.services.getchoo-website = {
    enable = mkEnableOption "enable getchoo-website";

    hostName = mkOption {
      type = types.str;
      description = "hostname for nginx virtualHost";
    };

    location = mkOption {
      type = types.str;
      default = "/";
      description = "location to serve on virtualHost";
    };
  };

  config.services.nginx = mkIf cfg.enable {
    enable = true;
    virtualHosts.${cfg.hostName} = {
      locations.${cfg.location} = {
        root = "${pkgs.getchoo-website}/libexec/getchoo-website/deps/getchoo-website/dist/";
        index = "index.html";
        tryFiles = "$uri =404";
      };
    };
  };
}
