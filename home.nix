{ config, pkgs, ... }:

{
    home.username = "noah";
    home.homeDirectory = "/home/noah";
    programs.git.enable = true;
    home.stateVersion = "25.05";
    programs.bash = {
        enable = true;
    };
}