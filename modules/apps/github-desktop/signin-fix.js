// Linux sign-in fix for GitHub Desktop (see default.nix).
//
// Electron on Linux delivers OAuth deep links as command-line arguments: as
// `process.argv` on a cold start, or as the `argv` parameter of the
// `second-instance` event when the app is already running. GitHub Desktop's
// main process only processes such URLs through its `open-url` listener, so
// we re-emit them there. The listener is registered during
// `will-finish-launching`, which fires before `ready`, so it always exists by
// the time this code forwards anything.
;(function () {
  try {
    var electron = require('electron')
    var protocol = /^x-github-(client|desktop-auth|desktop-dev-auth):\/\//

    // The app registers its `open-url` listener twice (once per
    // `will-finish-launching` event), so keep track of what was forwarded to
    // avoid delivering the same URL - and thus the same single-use OAuth code
    // - to the renderer more than once.
    var forwarded = null

    function forward(argv) {
      for (var i = 0; i < argv.length; i++) {
        var arg = argv[i]
        if (protocol.test(arg) && arg !== forwarded) {
          forwarded = arg
          electron.app.emit('open-url', { preventDefault: function () {} }, arg)
        }
      }
    }

    electron.app.on('second-instance', function (_event, argv) {
      forward(argv)
    })

    // Cold start: the app was not running when the browser handed off the URL.
    electron.app.on('ready', function () {
      forward(process.argv)
    })
  } catch (e) {
    console.error('github-desktop sign-in fix failed to install', e)
  }
})()
