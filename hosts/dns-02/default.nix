{ pkgs, unstable, ... }:
{
  services.technitium-dns-server = {
    package = unstable.technitium-dns-server;

    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    htop
    nano
    vim
  ];
}
