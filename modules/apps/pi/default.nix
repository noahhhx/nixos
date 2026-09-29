# Vendored from nixpkgs at a newer release than the pinned channel ships.
{
  flake.modules.homeManager.pi =
    { pkgs, ... }:
    let
      inherit (pkgs) lib;

      piPackage =
        {
          lib,
          buildNpmPackage,
          fetchFromGitHub,
          fetchurl,
          makeBinaryWrapper,
          ripgrep,
          fd,
          stdenvNoCC,
          writableTmpDirAsHomeHook,
          versionCheckHook,
        }:
        buildNpmPackage (finalAttrs: {
          pname = "pi-coding-agent";
          version = "0.86.1";

          src = fetchFromGitHub {
            owner = "earendil-works";
            repo = "pi";
            tag = "v${finalAttrs.version}";
            hash = "sha256-/7+VoRfXdeOwtiNXQYOKg5OHeKuNLIHfODGDNBhWop0=";
          };

          npmDepsHash = "sha256-VxjYw4lN/w0sDboihHAKEhdJFzJa09qZo7vavkTkBuw=";

          # Upstream generates the provider model catalog with a network fetch
          # and gitignores it, so it is absent from the tarball; restore it from
          # the matching published @earendil-works/pi-ai package.
          modelData = fetchurl {
            url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${finalAttrs.version}.tgz";
            hash = "sha256-88Nb88YGsJ9iupLSx8ieY+DKGAdUcBAtVWVoTFJLfv0=";
          };

          preConfigure = ''
            mkdir -p packages/ai/src/providers/data
            tar --extract --gzip --file=${finalAttrs.modelData} \
              --directory=packages/ai/src/providers/data \
              --strip-components=4 \
              package/dist/providers/data
          '';

          npmWorkspace = "packages/coding-agent";

          npmRebuildFlags = [ "--ignore-scripts" ];

          nativeBuildInputs = [ makeBinaryWrapper ];

          # tsgo directly instead of `npm run build` for workspace deps: pi-ai's
          # generate-models script needs network access; the catalog comes from
          # modelData above.
          buildPhase = ''
            runHook preBuild

            npx tsgo -p packages/chord/tsconfig.build.json
            npx tsgo -p packages/tui/tsconfig.build.json
            npx tsgo -p packages/telemetry/tsconfig.build.json
            npx tsgo -p packages/ai/tsconfig.build.json
            npx tsgo -p packages/agent/tsconfig.build.json
            npx tsgo -p packages/protocol/tsconfig.build.json
            npx tsgo -p packages/client/tsconfig.build.json
            npx tsgo -p packages/server/tsconfig.build.json
            npm run build --workspace=packages/coding-agent

            runHook postBuild
          '';

          dontNpmPrune = true;

          preInstall = ''
            npm prune --omit=dev --no-save
          '';

          postInstall = ''
            local nm="$out/lib/node_modules/pi-monorepo/node_modules"

            for ws in @earendil-works/chord:packages/chord \
                      @earendil-works/pi-ai:packages/ai \
                      @earendil-works/pi-agent-core:packages/agent \
                      @earendil-works/pi-client:packages/client \
                      @earendil-works/pi-protocol:packages/protocol \
                      @earendil-works/pi-telemetry:packages/telemetry \
                      @earendil-works/pi-tui:packages/tui; do
              IFS=: read -r pkg src <<< "$ws"
              rm "$nm/$pkg"
              cp -r "$src" "$nm/$pkg"
            done

            find "$nm" -type l -lname '*/packages/*' -delete

            find "$nm/.bin" -xtype l -delete
          ''
          + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
            # Otherwise audit-tmpdir tries to inspect these ELF RPATHs with patchelf
            rm -rf \
              "$nm/@anthropic-ai/sandbox-runtime/dist/vendor/seccomp" \
              "$nm/@anthropic-ai/sandbox-runtime/vendor/seccomp"
          '';

          postFixup = ''
            wrapProgram $out/bin/pi --prefix PATH : ${
              lib.makeBinPath [
                ripgrep
                fd
              ]
            } \
              --set-default PI_SKIP_VERSION_CHECK 1 \
              --set-default PI_TELEMETRY 0
          '';

          doInstallCheck = true;
          nativeInstallCheckInputs = [
            writableTmpDirAsHomeHook
            versionCheckHook
          ];
          versionCheckKeepEnvironment = [ "HOME" ];
          versionCheckProgram = "${placeholder "out"}/bin/pi";
          versionCheckProgramArg = "--version";

          meta = {
            description = "Coding agent CLI with read, bash, edit, write tools and session management";
            homepage = "https://pi.dev/";
            downloadPage = "https://www.npmjs.com/package/@earendil-works/pi-coding-agent";
            license = lib.licenses.mit;
            mainProgram = "pi";
          };
        });

      # https://github.com/dmtrKovalenko/fff/tree/main/packages/pi-fff
      # pi loads the TypeScript entry via jiti at runtime, so the "build" is
      # just an npm install: fetch the registry tarball, resolve its runtime
      # deps into node_modules, let autoPatchelf fix up the prebuilt fff and
      # ffi-rs native libraries.
      piFffPackage =
        {
          lib,
          autoPatchelfHook,
          buildNpmPackage,
          fetchurl,
          libgcc,
        }:
        buildNpmPackage rec {
          pname = "@ff-labs/pi-fff";
          version = "0.6.0";

          src = fetchurl {
            url = "https://registry.npmjs.org/@ff-labs/pi-fff/-/pi-fff-${version}.tgz";
            hash = "sha256-qMIbL0ep3ma2u1TSCWriQ5pXkkegaImRvJZQB/pQW1A=";
          };

          # Registry tarballs ship no lockfile: ./pi-fff-package.json (the
          # upstream manifest with peerDependencies dropped — pi provides those
          # modules to extensions at runtime via jiti aliases, so installing them
          # would only duplicate pi inside node_modules) and ./pi-fff-lock.json
          # (generated from it) vendor the npm resolution. Regenerate both on
          # version bumps alongside the src and npmDeps hashes; the lockfile
          # records integrity for every platform variant, so one resolution
          # works on any host.
          postPatch = ''
            cp ${./pi-fff-package.json} package.json
            cp ${./pi-fff-lock.json} package-lock.json
          '';

          npmDepsHash = "sha256-ke+4utF1a2WCMhd/XFsGJs3M7nnPMWvutVRHirKU+iU=";

          dontNpmBuild = true;

          nativeBuildInputs = [ autoPatchelfHook ];
          buildInputs = [ libgcc.lib ];

          meta = {
            description = "pi extension: FFF-powered fuzzy file and content search";
            homepage = "https://github.com/dmtrKovalenko/fff/tree/main/packages/pi-fff";
            license = lib.licenses.mit;
          };
        };

      pi = pkgs.callPackage piPackage { };
      pi-fff = pkgs.callPackage piFffPackage { };
    in
    {
      home.packages = [ pi ];

      # ~/.pi/agent is pi's state dir: it owns settings.json (rewritten by
      # /model, pi install, trust prompts), auth.json, and sessions. Only the
      # inputs pi treats as read-only are managed declaratively — the global
      # AGENTS.md, skill directories, and extension packages — via symlinks
      # into pi's auto-discovery locations. Everything is done without
      # touching settings.json, so pi can keep mutating it freely.
      home.file = {
        ".pi/agent/AGENTS.md".source = ./AGENTS.md;

        # ~/.pi/agent/extensions/<dir> auto-discovery loads any directory with
        # a package.json "pi" manifest; node_modules resolves through the
        # symlink into the store package.
        ".pi/agent/extensions/pi-fff".source = "${pi-fff}/lib/node_modules/@ff-labs/pi-fff";
      }
      # First-party skills: each directory under ./skills becomes a global
      # skill (pi discovers <dir>/SKILL.md recursively).
      // lib.mapAttrs' (
        name: _: lib.nameValuePair ".pi/agent/skills/${name}" { source = ./skills + "/${name}"; }
      ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills))
      # First-party extensions: drop .ts files (or package dirs) under
      # ./extensions to have them auto-loaded globally.
      // lib.optionalAttrs (builtins.pathExists ./extensions) (
        lib.mapAttrs' (
          name: _: lib.nameValuePair ".pi/agent/extensions/${name}" { source = ./extensions + "/${name}"; }
        ) (builtins.readDir ./extensions)
      );
    };
}
