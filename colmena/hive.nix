{ inputs, g3Modules }:

{
  meta = {
    nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    specialArgs = { inherit inputs; };
  };

  g3 = { ... }: {
    imports = g3Modules;

    deployment = {
      targetHost = "g3";
      targetUser = "colmena";
      allowLocalDeployment = true;
      tags = [ "workstation" ];
    };

  };
}
