{ unstable, ... }:
{
  services.technitium-dns-server = {
    package = unstable.technitium-dns-server;

    enable = true;
    openFirewall = true;
  };
}
