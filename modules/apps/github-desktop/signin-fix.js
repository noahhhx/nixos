// GitHub Desktop registers its `open-url` listener during
// `will-finish-launching`, which fires before `ready`, so it always exists by
// the time this code forwards anything.
;(function () {
  try {
    var electron = require('electron')
    var protocol = /^x-github-(client|desktop-auth|desktop-dev-auth):\/\//

    function forward(argv) {
      for (var i = 0; i < argv.length; i++) {
        var arg = argv[i]
        if (protocol.test(arg)) {
          electron.app.emit('open-url', { preventDefault: function () {} }, arg)
        }
      }
    }

    electron.app.on('second-instance', function (_event, argv) {
      forward(argv)
    })

    electron.app.on('ready', function () {
      forward(process.argv)
    })
  } catch (e) {
    console.error('github-desktop sign-in fix failed to install', e)
  }
})()
