{ unstable, pkgs, lib, config, ... }:
{
  services.resolved.settings.Resolve.DNSStubListener = false;

  services.technitium-dns-server = {
    package = unstable.technitium-dns-server;

    enable = true;

    openFirewall = true;
    firewallUDPPorts = [53 443 853];
    firewallTCPPorts = [53 443 853 5380 53443];
  };

  security.acme.certs."${config.networking.fqdn}" = {
    domain = config.networking.fqdn;
    
    dnsProvider = "cloudflare";
    environmentFile = config.sops.secrets.cloudflare-api-token-env.path;

    reloadServices = [
      "technitium-dns-server"
    ];

    postRun = ''
      ${lib.getBin pkgs.openssl}/bin/openssl pkcs12 -export -out bundle.pfx -inkey key.pem -in cert.pem -certfile chain.pem -passout pass:
      chown 'acme:acme' bundle.pfx
      chmod 640 bundle.pfx
    '';
  };

  # will place the bundle.pfx into /run/credentials/technitium-dns-server.service/
  systemd.services.technitium-dns-server = let
    certDir = config.security.acme.certs."${config.networking.fqdn}".directory;
  in {
    serviceConfig.LoadCredential = [
      "bundle.pfx:${certDir}/bundle.pfx"
    ];
  };

  environment.systemPackages = with pkgs; [
    openssl
  ];
}
