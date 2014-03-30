require [
  'jquery'
  "socket.io"
], ($, io) ->

  socket = io.connect('/game')

  registerEvent = (dir) ->
    socket.on(dir, () ->
      $("body").append(dir)
    )

  registerEvent(dir) for dir in ['left', 'right', 'up', 'down']
