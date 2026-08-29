{ config, pkgs, lib, ... }:

{
    imports = [
        ./hardware-configuration.nix
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "fw13";
    networking.networkmanager.enable = true;

    time.timeZone = "UTC";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIMES = "en_US.UTF-8";
    };

    users.users.fw13 = {
        isNormalUser = true;
        description = "Framework 13";
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.bash;
    };

    environment.systemPackages = with pkgs; [ git ];

    system.stateVersion = "26.05";
}