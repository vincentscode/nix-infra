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
  in {
    nixosConfigurations = {
      dns-02 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit unstable; };
        modules = [
          ./hosts/dns-02
          ./modules/common.nix
        ];
      };
    };
  };
}
