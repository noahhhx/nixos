{ config, pkgs, lib, ... }:

{
    imports = [
        ./hardware-configuration.nix
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;

    networking.hostName = "vm";
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

    users.users.vm = {
        isNormalUser = true;
        description = "Virtual Machine";
        extraGroups = [ "networkmanager" "wheel" ];
        shell = pkgs.bash;
    };

    environment.systemPackages = with pkgs; [ git ];

    system.stateVersion = "26.05";
}