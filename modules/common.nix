{ modulesPath, pkgs, self, config, comin, sops-nix, flakeUrl, ... }:
{
  system.stateVersion = "26.05";
  system.configurationRevision = self.rev or self.dirtyRev or null;

  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    (modulesPath + "/profiles/minimal.nix")

    comin.nixosModules.comin
    sops-nix.nixosModules.sops
  ];

  proxmoxLXC = {
    enable = true;

    privileged = false;

    manageNetwork = false;
    manageHostName = true;
  };


  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";

  services.journald.storage = "volatile";

  services.openssh.settings.PasswordAuthentication = false;

  services.comin = {
    enable = true;
    remotes = [{
      name = "origin";
      url = flakeUrl;
    }];
  };

  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "admin@${config.networking.domain}";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    };
  };

  networking.domain = "schmandt.net";

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
}
