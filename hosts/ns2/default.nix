{ pkgs, config, ... }:
{
  networking.hostName = "ns2";

  imports = [
    ../../modules/dns-server.nix
    ../../modules/dns-failover.nix
  ];

  services.keepalived.vrrpInstances.dns = {
    priority = 255 - 2;
    unicastPeers = [
      "10.0.20.11" # ns1
    ];
  };

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.cloudflare-api-token-env = {};

  networking.extraHosts =
  ''
    10.0.20.11 ns1.${config.networking.domain} ns1
  '';

  environment.systemPackages = with pkgs; [
    dig
  ];
}
