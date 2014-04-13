require [
  'jquery'
  'tapjs'
  "socket.io"
  "fastclick"
], ($, Tap, io, FastClick) ->

  socket = io.connect('/controller')

  press = (direction) ->
    socket.emit(direction)

  registerDirection = (direction) ->
    el = $(".arrow.#{direction}")[0]
    t = new Tap(el)

    el.addEventListener('tap', (evt) ->
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

  setButtonSize = ->
    wWidth = $(".spans").width()
    wHeight = $(".spans").height()
    fontSize = Math.min(wWidth, wHeight) * 0.3 | 0
    buttonWidth = fontSize * 1.3 | 0
    buttonHeight = fontSize * 1.3 | 0
    $(".spans").css("font-size", fontSize + "px")
    $(".spans .arrow").css(
      width: buttonWidth
      height: buttonHeight
    )
    $(".spans").show()

  $(window).resize setButtonSize
  setButtonSize()

  FastClick.attach(document.body)
