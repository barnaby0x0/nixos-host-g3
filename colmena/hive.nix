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
      targetUser = "user";
      allowLocalDeployment = true;
      tags = [ "workstation" ];
    };

    # deployment = {
    #   targetHost = "g3";
    #   targetUser = "user";
    #   privilegeEscalationCommand = [
    #     "sudo"
    #     "-H"
    #     "--"
    #   ];
    # };

  };
}
