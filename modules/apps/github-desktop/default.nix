{ ... }:
{
  flake.modules.homeManager.github-desktop =
    { pkgs, ... }:
    {
      home.packages = [
        # Browser sign-in is broken on Linux in GitHub Desktop 3.5.8: the OAuth
        # deep link (`x-github-client://oauth?code=…&state=…`) is only handled by
        # the macOS-only `open-url` event, while on Linux the browser hands the
        # URL to a second instance of the app whose handler only understands
        # `--cli-open`/`--cli-clone` and silently discards it — so the sign-in
        # spinner spins forever after a successful browser authorization.
        # Appended by postFixup, signin-fix.js forwards protocol URLs arriving
        # via `second-instance`/startup argv to the app's own `open-url` handler.
        (pkgs.github-desktop.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            mainjs="$out/share/github-desktop/resources/app/main.js"
            chmod u+w "$mainjs"
            cat ${./signin-fix.js} >>"$mainjs"
          '';
        }))
      ];
    };
}
