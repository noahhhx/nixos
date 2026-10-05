{
  config,
  inputs,
  lib,
  self,
  ...
}:
let
  inherit (config) hosts;
  inherit (config.flake) nixosConfigurations;

  vmFor =
    host:
    (inputs.nixpkgs.lib.nixosSystem {
      modules = [
        host
        (
          { modulesPath, ... }:
          {
            imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];
          }
        )
      ];
    }).config.system.build.vm;
in
{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-rfc-style;

      checks =
        (lib.mapAttrs' (
          name: _host:
          lib.nameValuePair "toplevel-${name}" (nixosConfigurations.${name}.config.system.build.toplevel)
        ) hosts)
        // (lib.mapAttrs' (
          name: host:
          lib.nameValuePair "vm-test-${name}" (
            pkgs.testers.runNixOSTest {
              name = "boot-${name}";
              node.pkgsReadOnly = false;
              nodes.machine = {
                imports = [ host ];
              };
              testScript =
                let
                  hostConfig = nixosConfigurations.${name}.config;
                  primaryUser = lib.head (
                    lib.filter (u: hostConfig.users.users.${u}.isNormalUser or false) (
                      lib.attrNames hostConfig.users.users
                    )
                  );
                  hasTailscale = hostConfig.services.tailscale.enable;
                  hasMullvad = hostConfig.services.mullvad-vpn.enable;
                  hasDocker = hostConfig.virtualisation.docker.enable;
                  hasEoscam = hostConfig.services.eoscam.enable or false;
                  hasPPD = hostConfig.services.power-profiles-daemon.enable;
                in
                ''
                  start_all()
                  machine.wait_for_unit("multi-user.target")
                  machine.succeed("nixos-version")
                  machine.succeed("test -f /etc/NIXOS")

                  machine.wait_for_unit("greetd.service")
                  machine.wait_for_unit("home-manager-${primaryUser}.service")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/kitty")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/pi")

                  machine.succeed(
                    "grep -aq zsh-dot-dir /run/current-system/sw/bin/zsh"
                  )
                  machine.succeed(
                    "getent passwd ${primaryUser}"
                    + " | grep -q '/run/current-system/sw/bin/zsh'"
                  )
                  machine.succeed(
                    "runuser -u ${primaryUser} -- env HOME=/home/${primaryUser} TERM=xterm"
                    + " /run/current-system/sw/bin/zsh -ic 'print -r -- $ZDOTDIR'"
                    + " 2>/dev/null | grep -q zsh-dot-dir"
                  )
                  machine.fail(
                    "runuser -u ${primaryUser} -- env HOME=/home/${primaryUser} TERM=xterm"
                    + " /run/current-system/sw/bin/zsh -ic true 2>&1"
                    + " | grep -q 'no zsh startup files'"
                  )

                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/devenv")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/direnv")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/hyprlock")
                  machine.succeed("test -x /run/current-system/sw/bin/Hyprland")

                  machine.succeed("test -x /run/current-system/sw/bin/uwsm")
                  machine.succeed(
                    "test -f /run/current-system/sw/share/systemd/user/wayland-session-bindpid@.service"
                  )
                  machine.succeed(
                    "systemctl cat greetd.service | grep -oP '(?<=--config )\S+'"
                    + " | head -1 | xargs grep -q cage"
                  )
                  machine.succeed("test -f /etc/greetd/regreet.toml")
                  machine.succeed("test -f /etc/greetd/regreet.css")
                  machine.succeed(
                    "grep -q 'uwsm start -e -D Hyprland' "
                    + "/run/current-system/sw/share/wayland-sessions/hyprland-uwsm.desktop"
                  )

                  machine.succeed("test -f /home/${primaryUser}/.config/systemd/user/hypridle.service")
                  machine.succeed("test -f /home/${primaryUser}/.config/systemd/user/hyprpaper.service")
                  machine.succeed("test -f /home/${primaryUser}/.config/hypr/hyprlock.conf")
                  machine.succeed("test -f /etc/pam.d/hyprlock")

                  machine.succeed("test -f /home/${primaryUser}/.config/mako/config")

                  machine.succeed("test -f /home/${primaryUser}/.config/systemd/user/swayosd.service")
                  machine.succeed("grep -q show_percentage /home/${primaryUser}/.config/swayosd/config.toml")
                  machine.succeed("test -f /home/${primaryUser}/.config/swayosd/style.css")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/swayosd-client")
                  machine.succeed("grep -q swayosd-client /home/${primaryUser}/.config/hypr/bindings.lua")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/swayosd-brightness")
                  machine.succeed("grep -q swayosd-brightness /home/${primaryUser}/.config/hypr/bindings.lua")

                  machine.succeed("test -f /home/${primaryUser}/.config/systemd/user/hyprpolkitagent.service")

                  machine.succeed("test -f /run/current-system/sw/share/xdg-desktop-portal/portals/hyprland.portal")
                  machine.succeed("grep -q hyprland /etc/xdg/xdg-desktop-portal/portals.conf")
                  machine.succeed("grep -q gtk /etc/xdg/xdg-desktop-portal/portals.conf")
                  machine.succeed("test -x /run/current-system/sw/bin/brightnessctl")

                  machine.succeed(
                    "grep -q adw-gtk3-dark /home/${primaryUser}/.config/gtk-3.0/settings.ini"
                  )
                  machine.succeed(
                    "grep -q gtk-application-prefer-dark-theme=true /home/${primaryUser}/.config/gtk-3.0/settings.ini"
                  )
                  machine.succeed(
                    "grep -q gtk-application-prefer-dark-theme=true /home/${primaryUser}/.config/gtk-4.0/settings.ini"
                  )
                  machine.succeed(
                    "test -d /etc/profiles/per-user/${primaryUser}/share/themes/adw-gtk3-dark"
                  )

                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/hyprshot")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/fastfetch")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/nano")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/nvim")

                  machine.succeed("grep -q zeditor /etc/set-environment")
                  machine.succeed("zsh -ic 'alias zed' | grep -q zeditor")

                  machine.wait_for_unit("nix-gc.timer")

                  machine.succeed("test -f /home/${primaryUser}/.config/mimeapps.list")
                  machine.succeed(
                    "grep -q librewolf.desktop /home/${primaryUser}/.config/mimeapps.list"
                  )

                  machine.succeed(
                    "test -f /run/current-system/sw/share/systemd/user/gvfs-daemon.service"
                  )

                  machine.succeed(
                    "test -f /run/current-system/sw/share/dbus-1/services/org.freedesktop.secrets.service"
                  )
                  machine.succeed("grep -q gnome_keyring /etc/pam.d/greetd")

                  ${
                    if hasPPD then
                      ''
                        machine.succeed(
                          "systemctl cat power-profiles-daemon.service >/dev/null"
                        )
                      ''
                    else
                      ""
                  }

                  ${
                    if hasTailscale then
                      ''
                        machine.wait_for_unit("tailscaled.service")
                        machine.wait_until_succeeds(
                          "tailscale debug prefs | grep -q '\"OperatorUser\": \"${primaryUser}\"'"
                        )
                        machine.succeed("test -f /home/${primaryUser}/.config/systemd/user/trayscale.service")
                        machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/trayscale")
                      ''
                    else
                      ""
                  }
                  ${
                    if hasMullvad then
                      ''
                        machine.wait_for_unit("mullvad-daemon.service")
                      ''
                    else
                      ""
                  }

                  ${
                    if hasEoscam then
                      ''
                        machine.succeed("grep -qx 'EOS Webcam' /sys/devices/virtual/video4linux/video*/name")
                        machine.succeed("test -f /etc/systemd/user/eoscam.service")
                      ''
                    else
                      ""
                  }

                  ${
                    if hasDocker then
                      ''
                        machine.wait_for_unit("docker.service")
                        machine.succeed("docker info >/dev/null")
                        machine.succeed("docker compose version >/dev/null")
                        machine.succeed("docker-compose --version >/dev/null")
                      ''
                    else
                      ""
                  }

                  machine.succeed("grep -q mem /sys/power/state")
                  machine.succeed("grep -q disk /sys/power/state")
                  machine.succeed(
                    "systemctl cat systemd-suspend.service"
                    + " systemd-hibernate.service >/dev/null"
                  )
                '';
            }
          )
        ) hosts);

      packages = lib.mapAttrs' (name: host: lib.nameValuePair "vm-${name}" (vmFor host)) hosts;

      apps.verify = {
        type = "app";
        program = "${self}/scripts/verify.sh";
        meta.description = "Tiered verification (fmt, eval, build, vm); see AGENTS.md";
      };
    };
}
