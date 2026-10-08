{
  description = "nix-infra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, comin }:
  let
    system = "x86_64-linux";
    unstable = import nixpkgs-unstable { inherit system; };

    mkHost = hostPath: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit unstable comin; };
      modules = [
        hostPath
        ./modules/common.nix
      ];
    };
  in {
    nixosConfigurations = {
      ns1 = mkHost ./hosts/ns1;
      ns2 = mkHost ./hosts/ns2;
    };
  };
}
