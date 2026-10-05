{ ... }:
{
  flake.modules.homeManager.github-desktop =
    { pkgs, ... }:
    {
      home.packages = [
        # Browser sign-in is broken on Linux in GitHub Desktop 3.5.8. Only the
        # macOS-only `open-url` event handles the OAuth deep link
        # (`x-github-client://oauth?code=…&state=…`). On Linux, the browser hands
        # the URL to a second instance of the app, whose handler understands
        # only `--cli-open` and `--cli-clone` and discards the URL without an
        # error. The sign-in spinner then spins forever after the browser
        # authorizes.
        #
        # The main process also hardcodes a 960x660 minimum window size
        # (`minWidth = 960; minHeight = 660` in the main-window class). When a
        # tiling compositor sizes the window below that minimum, the native
        # window shrinks to the tile, but Electron still lays out its content
        # at the minimum size. The tile clips the content. For example, a
        # half-screen tile cuts off the commit button. Rewriting the
        # BrowserWindow options lowers the minimum, so the content follows the
        # tile. The same class fields set the first-run default size, and this
        # rewrite leaves them alone.
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
