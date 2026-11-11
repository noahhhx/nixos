{ inputs, ... }:
{
  flake.modules.homeManager.pi =
    { lib, ... }:
    {
      imports = [ inputs.pi-shop.homeManagerModules.default ];

      programs.pi-shop = {
        enable = true;
        extraGlobalInstructions = builtins.readFile ./machine.md;
      };

      home.file = lib.mapAttrs' (
        name: _: lib.nameValuePair ".pi/agent/skills/${name}" { source = ./skills + "/${name}"; }
      ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills));
    };
}
