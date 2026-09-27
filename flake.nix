{
  description = "nix-infra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
  let
    system = "x86_64-linux";
    unstable = import nixpkgs-unstable { inherit system; };

    mkHost = hostPath: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit unstable; };
      modules = [
        hostPath
        ./modules/common.nix
      ];
    };
  in {
    nixosConfigurations = {
      dns-01 = mkHost ./hosts/dns-01;
      dns-02 = mkHost ./hosts/dns-02;
    };
  };
}
