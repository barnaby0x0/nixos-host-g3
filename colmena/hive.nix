{ inputs }:

{
  meta = {
    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
    };
    specialArgs = { inherit inputs; };
  };

  # Valeurs communes à tous les nœuds
  defaults = { ... }: {
    imports = [ inputs.disko.nixosModules.disko ];
    deployment.buildOnTarget = false;
  };

  g3 = { ... }: {
    deployment = {
      targetHost = "g3";   # ou IP / nom SSH / Tailscale
      targetUser = "root";       # ou "user" + allowLocalDeployment / sudo
      tags = [ "workstation" ];
    };

    imports = [
      ../configuration.nix
      ../hardware-configuration.nix
      ../disko.nix
      ../plasma.nix
    ];
  };
}