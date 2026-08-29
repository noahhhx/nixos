{ config, pkgs, ... }:

{
    home.username = "fw13";
    home.homeDirectory = "/home/fw13";
    programs.git.enable = true;
    home.stateVersion = "26.05";
    programs.bash = {
        enable = true;
    };
}