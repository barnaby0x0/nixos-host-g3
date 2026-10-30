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

    colmena = {
      url = "github:nix-community/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      colmena,
      disko,
      ...
    }@inputs:
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
      g3Modules = [
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        ./configuration.nix
      ];
    in
    {
      nixosModules.g3 = g3Modules;
      nixosConfigurations.g3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = g3Modules;
      };
      apps = forAllSystems (
        { pkgs, system, ... }:
        {
          colmena = {
            type = "app";
            program = "${colmena.packages.${system}.colmena}/bin/colmena";
          };
        }
      );
      colmenaHive = colmena.lib.makeHive (import ./colmena/hive.nix { inherit inputs g3Modules; });
      formatter = forAllSystems ({ pkgs, ... }: pkgs.nixfmt);
    };
}
