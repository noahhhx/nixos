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
        #
        # The main process also hardcodes a 960x660 minimum window size
        # (`minWidth = 960; minHeight = 660` in the main-window class). Under a
        # tiling compositor that configures windows to sizes below it, the
        # native window shrinks to the tile but Electron keeps laying out its
        # content at the minimum size, so the content is clipped (e.g. the
        # commit button is cut off when the window is tiled to half a screen).
        # Rewriting the BrowserWindow options lowers that minimum so the
        # content tracks the tile instead. (First-run default size comes from
        # the same class fields, which this rewrite does not touch.)
        (pkgs.github-desktop.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            mainjs="$out/share/github-desktop/resources/app/main.js"
            chmod u+w "$mainjs"
            sed -i 's/minWidth:this.minWidth,minHeight:this.minHeight/minWidth:400,minHeight:300/' "$mainjs"
            grep -q 'minWidth:400,minHeight:300' "$mainjs" || {
              echo 'github-desktop min-size patch no longer applies' >&2
              exit 1
            }
            cat ${./signin-fix.js} >>"$mainjs"
          '';
        }))
      ];
    };
}
