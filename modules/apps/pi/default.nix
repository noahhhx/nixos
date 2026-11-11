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

      home.file =
        lib.mapAttrs' (
          name: _: lib.nameValuePair ".pi/agent/skills/${name}" { source = ./skills + "/${name}"; }
        ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills))
        // {
          # Project-level MCP servers for ~/dev/mimos. The API serves MCP at
          # /mcp and signs agents in through Keycloak's public `mimos-agent`
          # client; Keycloak accepts any loopback port (mimos ADR-0014).
          "dev/mimos/.pi/mcp.json".text = builtins.toJSON {
            mcpServers.mimos = {
              url = "https://mimos-api.noahhh.co.uk/mcp";
              description = "Mimos (mimos.noahhh.co.uk): recipes, meal plans, shopping lists, and food log";
              oauth = {
                clientId = "mimos-agent";
                callbackPort = 8976;
              };
            };
          };
        };
    };
}
