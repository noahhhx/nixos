let
  # Official release builds: building from source needs Zig and a vendored
  # ghostty build. Hashes come from each release's manifest.
  core = {
    version = "0.1.20";
    sha256 = {
      x86_64-linux = "ac6b86890c451a37584620aaa438b71bc0d0bd430a2e7c1d7e095f052c414e74";
      aarch64-linux = "5f3037379d15cc76cfc72d2fd1a4262ea1c5b24df278bf7cfd8adcff7b914862";
    };
  };
  app = {
    version = "0.1.15";
    sha256 = {
      x86_64-linux = "f99e1e04be82c0e10b2f69ee7403ca34386f480d92511df5865af4703e7655dd";
      aarch64-linux = "0e5fd95a056452ec31e32fe6aa5a47a8b1d42020ae8f3a10cda2e0a1001d4124";
    };
  };

  release =
    pkgs: kind: r:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    pkgs.fetchurl {
      url = "https://releases.herdr.dev/${kind}/${r.version}/herdr-${kind}-linux-${pkgs.stdenv.hostPlatform.parsed.cpu.name}.tar.gz";
      sha256 = r.sha256.${system} or (throw "herdr: no ${kind} release for ${system}");
    };

  herdrCore =
    pkgs:
    pkgs.stdenvNoCC.mkDerivation {
      pname = "herdr-core";
      inherit (core) version;
      src = release pkgs "core" core;
      sourceRoot = ".";
      # A static-pie binary; its ELF build id names the running build, so keep its bytes.
      dontStrip = true;
      dontPatchELF = true;
      installPhase = ''
        install -Dm755 herdr-core $out/bin/herdr-core
        ln -s herdr-core $out/bin/hc
        install -Dm644 LICENSE THIRD-PARTY-NOTICES -t $out/share/licenses/herdr-core
      '';
      meta.mainProgram = "hc";
    };

  herdrApp =
    pkgs: hc:
    pkgs.stdenv.mkDerivation {
      pname = "herdr-app";
      inherit (app) version;
      src = release pkgs "app" app;
      nativeBuildInputs = with pkgs; [
        autoPatchelfHook
        makeWrapper
        copyDesktopItems
      ];
      buildInputs = with pkgs; [
        libxcb
        libxkbcommon
        stdenv.cc.cc.lib
      ];
      runtimeDependencies = with pkgs; [
        vulkan-loader
        wayland
        libGL
        libxkbcommon
      ];
      desktopItems = [
        (pkgs.makeDesktopItem {
          name = "herdr-app";
          desktopName = "Herdr";
          comment = "Terminals and coding agents that keep running";
          exec = "herdr-app";
          icon = "herdr-app";
          categories = [ "Development" ];
          startupWMClass = "herdr-app";
        })
      ];
      # The app self-updates only when herdr-app.svg sits beside its binary
      # (update.rs find_root), so the icon goes to share/ and never next to it.
      # PATH: the core from this same generation, a fallback after the profile's hc.
      # HERDR_TELEMETRY=0 turns off the app's usage reports.
      installPhase = ''
        runHook preInstall
        install -Dm755 herdr-app $out/bin/herdr-app
        install -Dm644 herdr-app.svg $out/share/icons/hicolor/scalable/apps/herdr-app.svg
        install -Dm644 LICENSE THIRD-PARTY-NOTICES -t $out/share/licenses/herdr-app
        wrapProgram $out/bin/herdr-app \
          --suffix PATH : ${hc}/bin \
          --set HERDR_TELEMETRY 0
        runHook postInstall
      '';
      meta.mainProgram = "herdr-app";
    };
in
{
  flake.modules.homeManager.herdr =
    { pkgs, ... }:
    let
      hc = herdrCore pkgs;
    in
    {
      home.packages = [
        hc
        (herdrApp pkgs hc)
      ];
    };
}
