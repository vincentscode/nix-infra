{ pkgs, lib, config, ... }:
let
  service-self-check-heartbeat = pkgs.writeShellApplication {
    name = "service-self-check-heartbeat";
    runtimeInputs = with pkgs; [
      curl
    ];
    text = ''
      healthcheck_url=$(cat /run/credentials/service-self-check-heartbeat.service/service-healthcheck-url)

      set +o errexit
      ${lib.getExe config.services.service-self-check-heartbeat.script}
      EXIT_CODE=$?
      set -o errexit

      curl --silent --retry 3 "$healthcheck_url/$EXIT_CODE" > /dev/null 2>&1
    '';
  };
in
{
  options.services.service-self-check-heartbeat = {
    script = lib.mkOption {
      type = lib.types.package;
    };
  };
  config = {
    systemd.services.service-self-check-heartbeat = {
      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
        ExecStart = "${lib.getExe service-self-check-heartbeat}";
        LoadCredential = [
          "service-healthcheck-url:${config.sops.secrets.service-healthcheck-url.path}"
        ];
      };
    };

    systemd.timers.service-self-check-heartbeat = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "15s";
        OnUnitActiveSec = "1min";
        AccuracySec = "1s";
      };
    };
  };
}
