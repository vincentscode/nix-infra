{ pkgs, config, ... }:
{
  networking.hostName = "ns1";

  imports = [
    ../../modules/technitium-dns-server.nix
  ];

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
