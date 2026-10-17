{ pkgs, lib, ... }:
let
  dns-healthcheck = pkgs.writeShellApplication {
    name = "dns-healthcheck";
    runtimeInputs = with pkgs; [
      bind.host
    ];
    text = ''
      host example.com 127.0.0.1 > /dev/null 2>&1
    '';
  };
in
{
  services.keepalived = {
    enable = true;
    openFirewall = true;

    vrrpScripts.check-dns = {
      script = "${lib.getExe dns-healthcheck}";
      interval = 5;
      fall = 3;
      rise = 2;
    };

    vrrpInstances.dns = {
      state = "BACKUP";
      interface = "eth0";
      virtualRouterId = 10;

      virtualIps = [
        { addr = "10.0.20.10/24"; }
      ];

      trackScripts = [
        "check-dns"
      ];
    };
  };
}
