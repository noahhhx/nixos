# Hosts: composes aspects into complete NixOS configurations.
#
# The top-level `hosts` option is the single registry of host modules; any
# other module can read it (e.g. verification.nix builds a VM test for every
# entry). Values are `deferredModule`s, so multiple files can contribute to
# the same host.
{
  config,
  inputs,
  lib,
  ...
}:
let
  # Desktop/user aspects imported for noah on every graphical host. Keep the
  # username in sync with modules/user.nix.
  noahImports = with config.flake.modules.homeManager; [
    home
    hyprland
    walker
    waybar
    kitty
    git
    zed
    librewolf
    dolphin
  ];
in
{
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf lib.types.deferredModule;
    default = { };
    description = "Complete NixOS host modules (composed aspects + host-specific settings), keyed by host name.";
  };

  config = {
    hosts.default = {
      imports = with config.flake.modules.nixos; [
        base
        fonts
        home-manager
        hyprland
        user
      ];

      home-manager.users.noah = {
        home.stateVersion = "25.05";
        imports = noahImports;
      };

      networking.hostName = "default";
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "25.05";

      # Placeholder boot setup so the closure builds and boots in a VM.
      # Replace per real host (mkDefault lets the VM/test framework override).
      boot.loader.grub = {
        enable = lib.mkDefault true;
        device = lib.mkDefault "/dev/vda";
      };
      fileSystems."/" = lib.mkDefault {
        device = "/dev/vda";
        fsType = "ext4";
      };
    };

    # The Framework Laptop 13 (AMD Ryzen AI 300 series). Same aspects as
    # `default` plus hardware enablement (audio, framework) and this
    # machine's real disk layout.
    hosts.framework = {
      imports = with config.flake.modules.nixos; [
        base
        fonts
        home-manager
        hyprland
        user
        audio
        framework
      ];

      home-manager.users.noah = {
        # stateVersion = release at first install on this machine.
        home.stateVersion = "26.05";
        imports = noahImports;
      };

      networking.hostName = "framework";
      nixpkgs.hostPlatform = "x86_64-linux";
      system.stateVersion = "26.05";

      # Real disk (captured from this machine's current install: GPT with a
      # 2G ESP and a LUKS2 root holding btrfs subvolumes @, @home, @log,
      # @pkg). Plain values are fine: the VM/test plumbing replaces the
      # whole fileSystems/luks sets when building VM checks, so this stays
      # host-specific. After reinstalling from scratch, refresh the UUIDs
      # from the generated /etc/nixos/hardware-configuration.nix.
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      boot.initrd.luks.devices."root" = {
        device = "/dev/disk/by-uuid/87a30974-33c8-4002-b8a8-2153b01f95e2";
        allowDiscards = true; # SSD TRIM through LUKS
      };
      fileSystems = {
        "/boot" = {
          device = "/dev/disk/by-uuid/E2C8-DE43";
          fsType = "vfat";
        };
        "/" = {
          device = "/dev/mapper/root";
          fsType = "btrfs";
          options = [
            "subvol=@"
            "compress=zstd:3"
            "noatime"
          ];
        };
        "/home" = {
          device = "/dev/mapper/root";
          fsType = "btrfs";
          options = [
            "subvol=@home"
            "compress=zstd:3"
            "noatime"
          ];
        };
        "/var/log" = {
          device = "/dev/mapper/root";
          fsType = "btrfs";
          neededForBoot = true;
          options = [
            "subvol=@log"
            "compress=zstd:3"
            "noatime"
          ];
        };
        # @pkg was /var/cache/pacman/pkg under Arch; reused as /var/cache.
        "/var/cache" = {
          device = "/dev/mapper/root";
          fsType = "btrfs";
          options = [
            "subvol=@pkg"
            "compress=zstd:3"
            "noatime"
          ];
        };
      };
    };

    flake.nixosConfigurations = lib.mapAttrs (
      name: host: inputs.nixpkgs.lib.nixosSystem { modules = [ host ]; }
    ) config.hosts;
  };
}
