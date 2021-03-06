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

      emitElectricity = (evalStr) =>
        # eval will have access to the 'self' variable
        self = this
        neighbors = @tileUnderneathMe().neighbors().filter((tile) -> tile.onElectricity?)
        if neighbors.length > 0
          tile.onElectricity.dispatch(evalStr, @tileUnderneathMe()) for tile in neighbors
        else
          eval(evalStr)

      @body.onBeginContact.add((body) =>
        if body.sprite
          window.button = this
          numPressing += 1
          if numPressing is 1
            @game.sound.play('button_click')
            @events.onPressed.dispatch()
            emitElectricity(@onpress) if @onpress
            @frame = 1
      )
      @body.onEndContact.add((body) =>
        if body.sprite
          numPressing -= 1
          if numPressing is 0
            @game.sound.play('button_release')
            @events.onReleased.dispatch()
            emitElectricity(@onrelease) if @onrelease
            @frame = 0
      )
