{ ... }:
{
  flake.modules.nixos.user = {
    users.users.noah = {
      isNormalUser = true;
      description = "Noah";
      extraGroups = [
        "wheel"
        "video"
        "input"
      ];
      initialPassword = "nixos";
    };
  };
}
