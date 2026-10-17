{ pkgs, config, ... }:
let
  service-self-check-heartbeat = pkgs.writeShellApplication {
    name = "service-self-check-heartbeat";
    runtimeInputs = with pkgs; [
      bind.host
    ];
    text = ''
      host example.org 127.0.0.1 > /dev/null 2>&1
    '';
  };
in
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

  # service-self-check-heartbeat configuration
  sops.secrets.service-healthcheck-url = {};
  services.service-self-check-heartbeat.script = service-self-check-heartbeat;

}
