{ pkgs, ... }:
let
  service-self-check-heartbeat = pkgs.writeShellApplication {
    name = "service-self-check-heartbeat";
    runtimeInputs = with pkgs; [
      bind.host
    ];
    text = ''
      SERVER_URL=http://127.0.0.1:9000
      curl --silent --fail "$SERVER_URL/-/health/live/" || exit 1
      curl --silent --fail "$SERVER_URL/-/health/ready/" || exit 1

      WORKER_URL=http://127.0.0.1:9001
      curl --silent --fail "$WORKER_URL/-/health/ready/" || exit 1

      exit 0
    '';
  };
in
{
  # host configuration
  networking.hostName = "sso";

  sops.defaultSopsFile = ./secrets.yaml;

  # modules
  imports = [
    ../../modules/authentik.nix
  ];

  # authentik configuration
  sops.secrets.authentik-secret-key = {};

  # update-self-check-heartbeat configuration
  sops.secrets.update-healthcheck-url = {};

  # service-self-check-heartbeat configuration
  sops.secrets.service-healthcheck-url = {};
  services.service-self-check-heartbeat.script = service-self-check-heartbeat;

}
