{ unstable, pkgs, config, lib, ... }:
let
  domain = config.networking.fqdn;

  authentikStateDirName = "authentik";
  authentikStateDir = "/var/lib/${authentikStateDirName}";
  authentikUser = "authentik";
  authentikGroup = "authentik";
  authentikPackage = unstable.authentik;

  serverHttpPort = 9000;
  serverMetricsPort = 9300;
  workerHttpPort = 9001;
  workerMetricsPort = 9301;

  commonEnvironment = {
    AUTHENTIK_POSTGRESQL__HOST = "/run/postgresql";
    AUTHENTIK_POSTGRESQL__NAME = "authentik";
    AUTHENTIK_POSTGRESQL__USER = "authentik";

    AUTHENTIK_LISTEN__TRUSTED_PROXY_CIDRS = "127.0.0.0/8,::1/128";
    AUTHENTIK_STORAGE__FILE__PATH = authentikStateDir;
    AUTHENTIK_SECRET_KEY = "file://${config.sops.secrets.authentik-secret-key.path}";
    AUTHENTIK_LOG_LEVEL = "info";
  };

  serverEnvironment = commonEnvironment // {
    AUTHENTIK_LISTEN__HTTP = "127.0.0.1:${toString serverHttpPort}";
    AUTHENTIK_LISTEN__METRICS = "127.0.0.1:${toString serverMetricsPort}";
  };

  workerEnvironment = commonEnvironment // {
    AUTHENTIK_LISTEN__HTTP = "127.0.0.1:${toString workerHttpPort}";
    AUTHENTIK_LISTEN__METRICS = "127.0.0.1:${toString workerMetricsPort}";
  };

  authentikSystemdService = role: environment: {
    enable = true;

    description = "authentik ${role}";
    wantedBy = [ "multi-user.target" ];
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];

    inherit environment;

    preStart = ''
      ${config.services.postgresql.package}/bin/pg_isready -h /run/postgresql -d authentik -U authentik
    '';

    serviceConfig = {
      Type = "simple";
      User = authentikUser;
      Group = authentikGroup;
      WorkingDirectory = authentikStateDir;
      StateDirectory = authentikStateDirName;
      StateDirectoryMode = "0750";
      ExecStart = "${authentikPackage}/bin/ak ${role}";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
in
{
  sops.secrets.authentik-secret-key = {
    owner = authentikUser;
    group = authentikGroup;
    mode = "0400";
  };

  users.groups.${authentikGroup} = { };

  users.users.${authentikUser} = {
    isSystemUser = true;
    group = authentikGroup;
    home = authentikStateDir;
  };

  services.postgresql = {
    enable = true;

    package = pkgs.postgresql;
    ensureDatabases = [ "authentik" ];
    ensureUsers = [
      {
        name = "authentik";
        ensureDBOwnership = true;
      }
    ];
    authentication = lib.mkAfter ''
      local authentik authentik peer
    '';
  };

  systemd.services = {
    authentik-server = authentikSystemdService "server" serverEnvironment;
    authentik-worker = authentikSystemdService "worker" workerEnvironment;
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString serverHttpPort}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
