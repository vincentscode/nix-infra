{ pkgs, config, ... }:
{
  networking.hostName = "ns1";

  imports = [
    ../../modules/dns-server.nix
    ../../modules/dns-failover.nix
  ];

  services.keepalived.vrrpInstances.dns = {
    priority = 255 - 1;
    unicastPeers = [
      "10.0.20.12" # ns2
    ];
  };

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.cloudflare-api-token-env = {};

  networking.extraHosts =
  ''
    10.0.20.12 ns2.${config.networking.domain} ns2
  '';

  environment.systemPackages = with pkgs; [
    dig
  ];
}
