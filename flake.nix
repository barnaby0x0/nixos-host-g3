{
  description = "NixOS configuration for g3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f rec {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
          }

        );
    in
    {
      nixosConfigurations.g3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./configuration.nix
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
        ];
      };
      formatter = forAllSystems ({ pkgs, ... }: pkgs.nixfmt);
    };
}
