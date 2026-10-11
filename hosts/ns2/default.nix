{ unstable, pkgs, ... }:
{
  networking.hostName = "ns2";

  services.technitium-dns-server = {
    package = unstable.technitium-dns-server;

    enable = true;

    openFirewall = true;
    firewallUDPPorts = [53];
    firewallTCPPorts = [53 443 853 5380 53443];
  };

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.cloudflare-api-token-env = {};

  environment.systemPackages = with pkgs; [
    dig
  ];
}
