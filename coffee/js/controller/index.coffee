require [
  'jquery'
  "socket.io"
], ($, io) ->

  socket = io.connect('/controller')

  press = (direction) ->
    socket.emit(direction)
    arrow = $(".arrow.#{direction}")
    arrow.css("color", "orange")
    setTimeout(() ->
      arrow.css("color", "")
    , 60)

  registerDirection = (direction) ->
    $(".arrow.#{direction}").click((evt) ->
      press(direction)
    )

  $("body").on("keydown", (evt) ->
    direction = {
      37: "left"
      39: "right"
      38: "up"
      40: "down"
    }[evt.which]
    press(direction) if direction
  )

  registerDirection(dir) for dir in ['left', 'right', 'up', 'down']

