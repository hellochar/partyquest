define [
  'jquery'
], ($) ->
  Overlay = {
    fadeDuration: 1000

    text: (text, duration = 1000) ->
      Overlay.show().html(text)
      Overlay.el.css(top: 0)
      overflowHeight = Overlay.el.height() - $("body").height()
      if overflowHeight > 0
        Overlay.el.animate({top: -overflowHeight}, 20000)

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
