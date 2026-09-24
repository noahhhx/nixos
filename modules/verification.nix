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
            pkgs.testers.nixosTest {
              name = "boot-${name}";
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

                  # Login shells are stored as /run/current-system/sw/bin/zsh
                  # (lib.toShellPath) and terminals exec that path (kitty even
                  # prefers $SHELL, which greetd fills from passwd), so it must
                  # be the wrapped zsh, or shells start with no ZDOTDIR and
                  # zsh-newuser-install greets every new terminal.
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
                  # uwsm fills XDG_CURRENT_DESKTOP from the binary basename
                  # unless overridden; Hyprland warns unless it is "Hyprland".
                  machine.succeed(
                    "systemctl cat greetd.service | grep -oP '(?<=--config )\S+'"
                    + " | head -1 | xargs grep -q 'uwsm start -e -D Hyprland -- start-hyprland'"
                  )

                  # These only run once a Wayland session exists, which the
                  # VM test does not start, so assert on the units instead.
                  machine.succeed("test -f /home/${primaryUser}/.config/systemd/user/hypridle.service")
                  machine.succeed("test -f /home/${primaryUser}/.config/systemd/user/hyprpaper.service")
                  machine.succeed("test -f /home/${primaryUser}/.config/hypr/hyprlock.conf")
                  machine.succeed("test -f /etc/pam.d/hyprlock")

                  # mako is D-Bus-activated on the first notification of a real session.
                  machine.succeed("test -f /home/${primaryUser}/.config/mako/config")

                  machine.succeed("test -f /home/${primaryUser}/.config/systemd/user/hyprpolkitagent.service")

                  # The hyprland portal's daemon lives in libexec, not on PATH.
                  machine.succeed("test -f /run/current-system/sw/share/xdg-desktop-portal/portals/hyprland.portal")
                  machine.succeed("grep -q hyprland /etc/xdg/xdg-desktop-portal/portals.conf")
                  machine.succeed("grep -q gtk /etc/xdg/xdg-desktop-portal/portals.conf")
                  machine.succeed("test -x /run/current-system/sw/bin/brightnessctl")

                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/hyprshot")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/fastfetch")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/nano")
                  machine.succeed("test -x /etc/profiles/per-user/${primaryUser}/bin/nvim")

                  machine.succeed("grep -q zeditor /etc/set-environment")

                  machine.wait_for_unit("nix-gc.timer")

                  machine.succeed("test -f /home/${primaryUser}/.config/mimeapps.list")
                  machine.succeed(
                    "grep -q librewolf.desktop /home/${primaryUser}/.config/mimeapps.list"
                  )

                  machine.succeed(
                    "test -f /run/current-system/sw/share/systemd/user/gvfs-daemon.service"
                  )

                  # D-Bus-activated; assert the unit is installed rather than started.
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
                        machine.fail("systemctl is-active tailscaled.service")
                        machine.succeed("systemctl start tailscaled.service")
                        machine.wait_for_unit("tailscaled.service")
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

                  # A full S3/S4 cycle is not faithful under QEMU (the test plumbing
                  # replaces the real swap/LUKS layout); resume is verified on the
                  # metal host.
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
