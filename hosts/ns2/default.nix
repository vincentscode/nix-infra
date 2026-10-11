{ unstable, pkgs, lib, config, ... }:
{
  networking.hostName = "ns2";
  
  services.resolved.settings.Resolve.DNSStubListener = false;

  services.technitium-dns-server = {
    package = unstable.technitium-dns-server;

    enable = true;

    openFirewall = true;
    firewallUDPPorts = [53 443 853];
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
          chmod 755 .
        '';
      };
    };
  };

  networking.extraHosts =
  ''
    10.0.20.11 ns1.${config.networking.domain} ns1
  '';

  environment.systemPackages = with pkgs; [
    dig
    openssl
  ];
}
