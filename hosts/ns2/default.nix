{ pkgs, config, ... }:
{
  # host configuration
  networking.hostName = "ns2";

  environment.systemPackages = with pkgs; [
    dig
  ];

  networking.extraHosts =
  ''
    10.0.20.11 ns1.${config.networking.domain} ns1
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
    priority = 255 - 2;
    unicastPeers = [
      "10.0.20.11" # ns1
    ];
  };

  # update-self-check-heartbeat configuration
  sops.secrets.update-healthcheck-url = {};

}
