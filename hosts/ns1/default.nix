{ unstable, pkgs, lib, config, ... }:
{
  networking.hostName = "ns1";

  services.technitium-dns-server = {
    package = unstable.technitium-dns-server;

    enable = true;

    openFirewall = true;
    firewallUDPPorts = [53];
    firewallTCPPorts = [53 443 853 5380 53443];
  };

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.cloudflare-api-token-env = {};

  security.acme = {
    certs = {
      "${config.networking.fqdn}" = {
        domain = config.networking.fqdn;
        
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets.cloudflare-api-token-env.path;

        postRun = ''
          ${lib.getBin pkgs.openssl}/bin/openssl pkcs12 -export -out bundle.pfx -inkey key.pem -in cert.pem -certfile chain.pem -passout pass:
          chown 'acme:acme' bundle.pfx
          chmod 644 bundle.pfx
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    dig
    openssl
  ];
}
