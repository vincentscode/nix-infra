{
  description = "nix-infra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, comin, sops-nix }:
  let
    system = "x86_64-linux";
    unstable = import nixpkgs-unstable { inherit system; };

    flakeUrl = "https://github.com/vincentscode/nix-infra.git";

    mkHost = hostPath: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit unstable self comin sops-nix flakeUrl; };
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
