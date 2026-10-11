{ unstable, pkgs, ... }:
{
  networking.hostName = "ns2";

  services.technitium-dns-server = {
    package = unstable.technitium-dns-server;

    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    dig
  ];
}
