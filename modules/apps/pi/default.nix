# pi: the CLI itself is vendored here (pinned to this repo's nixpkgs
# channel, newer than the channel ships); the agent setup — the portable
# AGENTS.md base, skills, extensions incl. pi-fff — comes from the
# pi-shop flake input; machine-specific instructions (machine.md) and
# skills (./skills) stay in this directory.
{ inputs, ... }:
{
  flake.modules.homeManager.pi =
    { pkgs, lib, ... }:
    let
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
          version = "0.99.2";

          src = fetchFromGitHub {
            owner = "earendil-works";
            repo = "pi";
            tag = "v${finalAttrs.version}";
            hash = "sha256-ukN//DNSnCr9gZHKSzexAGEZu95eMzTGJLjLc5B+Hwo=";
          };

          npmDepsHash = "sha256-eKghIpCAKawZm0Uf2iG6y1fz21Z5jNnMiAFJ5Quj3GI=";

          # Upstream generates the provider model catalog with a network fetch
          # and gitignores it, so it is absent from the tarball; restore it from
          # the matching published @earendil-works/pi-ai package.
          modelData = fetchurl {
            url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${finalAttrs.version}.tgz";
            hash = "sha256-Cz34eRtIghbzCdkIeJKUp0S7Ybuq0SPZQJjlbflTjSU=";
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

          # tsc directly instead of `npm run build` for workspace deps: pi-ai's
          # generate-models script needs network access; the catalog comes from
          # modelData above.
          buildPhase = ''
            runHook preBuild

            npx tsc -p packages/chord/tsconfig.build.json
            npx tsc -p packages/tui/tsconfig.build.json
            npx tsc -p packages/telemetry/tsconfig.build.json
            npx tsc -p packages/codemode/tsconfig.build.json
            npx tsc -p packages/mcp/tsconfig.build.json
            npx tsc -p packages/ai/tsconfig.build.json
            npx tsc -p packages/agent/tsconfig.build.json
            npx tsc -p packages/protocol/tsconfig.build.json
            npx tsc -p packages/client/tsconfig.build.json
            npx tsc -p packages/server/tsconfig.build.json
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
                      @earendil-works/pi-codemode:packages/codemode \
                      @earendil-works/pi-mcp:packages/mcp \
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

      pi = pkgs.callPackage piPackage { };
    in
    {
      imports = [ inputs.pi-shop.homeManagerModules.default ];

      programs.pi-shop = {
        enable = true;
        extraGlobalInstructions = builtins.readFile ./machine.md;
      };

      home.packages = [ pi ];

      # Machine-specific skills: each directory under ./skills becomes a
      # global skill (pi discovers <dir>/SKILL.md recursively). Portable
      # skills and extensions come from the pi-shop aspect.
      home.file = lib.mapAttrs' (
        name: _: lib.nameValuePair ".pi/agent/skills/${name}" { source = ./skills + "/${name}"; }
      ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills));
    };
}
