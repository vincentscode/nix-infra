{ modulesPath, pkgs, comin, ... }:
{
  system.stateVersion = "26.05";
  
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    (modulesPath + "/profiles/minimal.nix")

    comin.nixosModules.comin
  ];

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
      url = "https://github.com/vincentscode/nix-infra.git";
    }];
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
