{ config, pkgs, ... }:

{
    home.username = "vm";
    home.homeDirectory = "/home/vm";
    programs.git.enable = true;
    home.stateVersion = "26.05";
    programs.bash = {
        enable = true;
    };
}