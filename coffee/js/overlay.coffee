define [
  'jquery'
], ($) ->
  Overlay = {
    fadeDuration: 1000

    text: (text, duration = 1000) ->
      Overlay.show().text(text)
      if duration > 0
        setTimeout(Overlay.hide, duration)

    hide: () ->
      Overlay.el.fadeOut(Overlay.fadeDuration)
    show: () ->
      Overlay.el.fadeIn(Overlay.fadeDuration)

    hideImmediately: () ->
      Overlay.el.hide()
    showImmediately: () ->
      Overlay.el.show()

    blackScreen: () ->
      Overlay.text("", -1)

    el: $("#overlay")
  }
