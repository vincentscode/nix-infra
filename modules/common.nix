{ modulesPath, ... }:
{
  system.stateVersion = "26.05";
  
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    (modulesPath + "/profiles/minimal.nix")
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 14d";

  services.journald.storage = "volatile";

  environment.systemPackages = with pkgs; [
    perl
    git
    wget
    curl
    nano
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
}
