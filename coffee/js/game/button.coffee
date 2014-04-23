define [
  'game/mysprite'
  'phaser'
], (MySprite, Phaser) ->

  class Button extends MySprite
    constructor: (game, x, y, key, frame = 0) ->
      super(game, x, y, key, frame)
      @events.onPressed = new Phaser.Signal()
      @events.onReleased = new Phaser.Signal()
      @body.motionState = Phaser.Physics.P2.Body.STATIC
      shape = @body.setRectangleFromSprite()
      shape.sensor = true
      numPressing = 0
      @body.onBeginContact.add((body) =>
        if body.sprite
          window.button = this
          numPressing += 1
          if numPressing is 1
            @game.sound.play('button_click')
            @events.onPressed.dispatch()
            # eval will have access to the 'self' variable
            self = this
            if @onpress
              eval(@onpress)
              tile.onElectricity?.dispatch() for tile in @tileUnderneathMe().neighbors()
            @frame = 1
      )
      @body.onEndContact.add((body) =>
        if body.sprite
          numPressing -= 1
          if numPressing is 0
            @game.sound.play('button_release')
            @events.onReleased.dispatch()
            # eval will have access to the 'self' variable
            self = this
            if @onrelease
              eval(@onrelease)
              tile.onElectricity?.dispatch() for tile in @tileUnderneathMe().neighbors()
            @frame = 0
      )
