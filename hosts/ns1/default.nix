{ unstable, pkgs, config, ... }:
{
  networking.hostName = "ns1";

  services.technitium-dns-server = {
    package = unstable.technitium-dns-server;

    enable = true;

    openFirewall = true;
    firewallUDPPorts = [53];
    firewallTCPPorts = [53 443 853 5380 53443];
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.secrets.cloudflare-api-token-env = {};

  security.acme = {
    certs = {
      "${config.networking.fqdn}" = {
        domain = config.networking.fqdn;
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets.cloudflare-api-token-env.path;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    dig
  ];
}
