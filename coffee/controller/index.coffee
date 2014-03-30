require [
  'jquery'
  "socket.io"
], ($, io) ->

  socket = io.connect('/controller')

  registerDirection = (direction) ->
    $(".arrow.#{direction}").click((evt) ->
      socket.emit(direction)
    )

  registerDirection(dir) for dir in ['left', 'right', 'up', 'down']
