{ config, ... }: {
  nixos.modules.base = {
    users.users.noah = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      initialPassword = "changeme";  # first-boot only; change it after login.
      # Swap for initialHashedPassword before the Framework goes live (Scars: no
      # password + --no-root-passwd = locked out on first boot)
    };
    # lower-level module merging in action: this is how the home bags reach the user
    home-manager.users.noah = {
      imports = with config.homeManager.modules; [ base workstation ];
      home = {
        username = "noah";
        homeDirectory = "/home/noah";
        stateVersion = "26.05";
      };
      programs.home-manager.enable = true;
    };
  };
}
