{ unstable, pkgs, config, ... }:
let
  service-self-check-heartbeat = pkgs.writeShellApplication {
    name = "service-self-check-heartbeat";
    runtimeInputs = with pkgs; [
      curl
    ];
    text = ''
      curl --silent --fail "http://localhost:2283/api/server/ping" | grep -q 'pong' || exit 1

      exit 0
    '';
  };
in
{
  # host configuration
  networking.hostName = "immich";

  sops.defaultSopsFile = ./secrets.yaml;

  # services configuration
  services.immich = {
    package = unstable.immich;
    enable = true;
    accelerationDevices = null;
    settings = null;

    mediaLocation = "/mnt/application-data/media";
  };

  services.redis.servers.immich.logLevel = "warning";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  users.users.immich.extraGroups = ["video" "render"];

  services.nginx.enable = true;
  services.nginx.virtualHosts."${config.networking.fqdn}" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.immich.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        # allow large file uploads
        client_max_body_size 50000M;

        # disable buffering uploads
        proxy_request_buffering off;

        # increase body buffer to avoid limiting upload speed
        client_body_buffer_size 1024k;

        # set timeouts
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme.certs."${config.networking.fqdn}" = {
    domain = config.networking.fqdn;

    dnsProvider = "cloudflare";
    environmentFile = config.sops.secrets.cloudflare-api-token-env.path;

    webroot = null;
  };
  sops.secrets.cloudflare-api-token-env = {};

  # update-self-check-heartbeat configuration
  sops.secrets.update-healthcheck-url = {};

  # service-self-check-heartbeat configuration
  sops.secrets.service-healthcheck-url = {};
  services.service-self-check-heartbeat.script = service-self-check-heartbeat;

}
