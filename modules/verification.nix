# Verification: everything needed to prove that a change to this flake
# works, from any machine — including one that does not run the OS this repo
# installs. See the "Verification system" section in AGENTS.md for usage.
#
# Exposes (per system):
#   formatter.<system>                     nixfmt-rfc-style (nix fmt)
#   checks.<system>.toplevel-<host>        host closure builds
#   checks.<system>.vm-test-<host>         host boots in a headless QEMU VM
#                                          (building this check RUNS the test)
#   packages.<system>.vm-<host>            interactive VM (nix run .#vm-<host>)
#   apps.<system>.verify                   scripts/verify.sh as a flake app
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

  # Wrap a host module into an interactive QEMU VM runner.
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
        (
          # Every host must build a complete system closure.
          lib.mapAttrs' (
            name: _host:
            lib.nameValuePair "toplevel-${name}" (nixosConfigurations.${name}.config.system.build.toplevel)
          ) hosts
        )
        // (
          # Every host must boot in a headless QEMU VM and reach a sane state.
          lib.mapAttrs' (
            name: host:
            lib.nameValuePair "vm-test-${name}" (
              pkgs.testers.nixosTest {
                name = "boot-${name}";
                nodes.machine = {
                  imports = [ host ];
                };
                # Extend with feature-specific assertions as the config grows
                # (e.g. machine.wait_for_unit("<new-service>.service")).
                testScript = # python
                  ''
                    start_all()
                    machine.wait_for_unit("multi-user.target")
                    machine.succeed("nixos-version")
                    machine.succeed("test -f /etc/NIXOS")

                    # Desktop stack: greeter is up, home-manager activated the
                    # user profile, and the compositor is installed.
                    machine.wait_for_unit("greetd.service")
                    machine.wait_for_unit("home-manager-noah.service")
                    machine.succeed("test -x /etc/profiles/per-user/noah/bin/kitty")
                    machine.succeed("test -x /run/current-system/sw/bin/Hyprland")

                    # Sleep stack: the kernel exposes suspend (mem) and
                    # hibernate (disk) sleep states, and systemd's sleep
                    # units are present. Exercising a full S3/S4 cycle is not
                    # faithful under QEMU (the test plumbing replaces the
                    # host's real swap/LUKS layout), so the actual resume path
                    # is verified on the metal host instead.
                    machine.succeed("grep -q mem /sys/power/state")
                    machine.succeed("grep -q disk /sys/power/state")
                    machine.succeed(
                      "systemctl cat systemd-suspend.service"
                      + " systemd-hibernate.service >/dev/null"
                    )
                  '';
              }
            )
          ) hosts
        );

      packages = lib.mapAttrs' (name: host: lib.nameValuePair "vm-${name}" (vmFor host)) hosts;

      apps.verify = {
        type = "app";
        program = "${self}/scripts/verify.sh";
        meta.description = "Tiered verification (fmt, eval, build, vm); see AGENTS.md";
      };
    };
}
