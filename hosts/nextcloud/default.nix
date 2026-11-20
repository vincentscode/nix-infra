{ pkgs, config, ... }:
let
  service-self-check-heartbeat = pkgs.writeShellApplication {
    name = "service-self-check-heartbeat";
    runtimeInputs = with pkgs; [
      curl
    ];
    text = ''
      curl --silent --fail "http://127.0.0.1/status.php" || exit 1

      exit 0
    '';
  };
in
{
  # host configuration
  networking.hostName = "nextcloud";

  sops.defaultSopsFile = ./secrets.yaml;

  # modules
  imports = [
    ../../modules/nextcloud.nix
  ];

  # nextcloud configuration
  services.nextcloud.datadir = "/mnt/application-data/data";
  sops.secrets.cloudflare-api-token-env = {};

  # update-self-check-heartbeat configuration
  sops.secrets.update-healthcheck-url = {};

  # service-self-check-heartbeat configuration
  sops.secrets.service-healthcheck-url = {};
  services.service-self-check-heartbeat.script = service-self-check-heartbeat;

}
