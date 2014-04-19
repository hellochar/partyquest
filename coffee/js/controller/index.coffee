require [
  'jquery'
  'tapjs'
  "socket.io"
  "fastclick"
  'overlay'
], ($, Tap, io, FastClick, Overlay) ->

  Overlay.el.css(
    'background-color': 'rgba(0, 0, 0, 0.5)'
  )
  Overlay.fadeDuration = 200

  socket = undefined

  press = (direction) ->
    socket.emit(direction)


  setInactiveCss = (text) ->
    if not socket.socket.connected
      $(".spans .arrow").removeClass("connected")
      Overlay.text(text, 0)
    else
      setActiveCss()

  setActiveCss = () ->
    if socket.socket.connected
      $(".spans .arrow").addClass("connected")
      Overlay.text('Connected!')
      Overlay.hide()
    else
      Overlay.show()

  registerDirection = (direction) ->
    el = $(".arrow.#{direction}")[0]
    t = new Tap(el)
    el.addEventListener('tap', (evt) ->
      press(direction)
    )

  setButtonSize = () ->
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


  setup = () -> 
    socket = io.connect('/controller')
    socket.on('connect', setActiveCss)
    socket.on('connecting', () -> setInactiveCss("Connecting..."))
    socket.on('connect_failed', () -> setInactiveCss("Connection failed! Try refreshing."))
    socket.on('disconnect', () -> setInactiveCss("Disconnected! Please Wait..."))
    socket.on('reconnecting', () -> setInactiveCss("Reconnecting... Please wait or refresh."))
    socket.on('error', () -> (err) ->
      setInactiveCss("Error! #{err}. Try refreshing.")
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
    $(window).resize(setButtonSize)
    setButtonSize()
    FastClick.attach(document.body)

  setup()
