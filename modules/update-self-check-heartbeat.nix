{ pkgs, lib, config, flakeUrl, ... }:
let
  update-self-check-heartbeat = pkgs.writeShellApplication {
    name = "update-self-check-heartbeat";
    runtimeInputs = with pkgs; [
      curl
      git
      gawk
    ];
    text = ''
      healthcheck_url=$(cat /run/credentials/update-self-check-heartbeat.service/update-healthcheck-url)

      local_revision=$(/run/current-system/sw/bin/nixos-version --configuration-revision)
      remote_revision=$(GIT_TERMINAL_PROMPT=0 timeout 20 git ls-remote ${flakeUrl} refs/heads/main | awk '{print $1}')

      if [[ "$local_revision" == "$remote_revision" ]]; then
        curl --silent --retry 3 "$healthcheck_url" > /dev/null 2>&1
      fi
    '';
  };
in
{
  systemd.services.update-self-check-heartbeat = {
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      ExecStart = "${lib.getExe update-self-check-heartbeat}";
      LoadCredential = [
        "update-healthcheck-url:${config.sops.secrets.update-healthcheck-url.path}"
      ];
    };
  };

  systemd.timers.update-self-check-heartbeat = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
    };
  };
}
