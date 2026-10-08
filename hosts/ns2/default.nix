{ unstable, lib, pkgs, ... }:
{
  networking.hostName = lib.mkOverride 40 "ns2";

  services.technitium-dns-server = {
    package = unstable.technitium-dns-server;

    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    dig
  ];
}
