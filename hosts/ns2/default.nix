{ pkgs, config, ... }:
{
  networking.hostName = "ns2";

  imports = [
    ../../modules/technitium-dns-server.nix
  ];

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
