{ unstable, pkgs, config, lib, ... }:
{
  services.nextcloud = {
    enable = true;

    hostName = config.networking.fqdn;

    https = true;

    database.createLocally = true;

    config = {
      dbtype = "pgsql";
      adminuser = null;
      adminpassFile = null;
    };

    settings = {
      default_phone_region = "DE";
      log_type = "systemd";
    };
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    enableACME = true;
  };

  security.acme.certs."${config.services.nextcloud.hostName}" = {
    domain = config.services.nextcloud.hostName;

    dnsProvider = "cloudflare";
    environmentFile = config.sops.secrets.cloudflare-api-token-env.path;

    webroot = null;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
