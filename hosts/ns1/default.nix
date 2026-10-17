{ pkgs, config, ... }:
{
  # host configuration
  networking.hostName = "ns1";

  environment.systemPackages = with pkgs; [
    dig
  ];

  networking.extraHosts =
  ''
    10.0.20.12 ns2.${config.networking.domain} ns2
  '';

  sops.defaultSopsFile = ./secrets.yaml;

  # modules
  imports = [
    ../../modules/dns-server.nix
    ../../modules/dns-failover.nix
  ];

  # dns-server configuration
  sops.secrets.cloudflare-api-token-env = {};

  # dns-failover configuration
  services.keepalived.vrrpInstances.dns = {
    priority = 255 - 1;
    unicastPeers = [
      "10.0.20.12" # ns2
    ];
  };

  # update-self-check-heartbeat configuration
  sops.secrets.healthcheck-url = {};

}
