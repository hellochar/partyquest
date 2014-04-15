define [
  'phaser'
], (Phaser) ->
  class Button extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      @x += @width/2
      @y += @height/2
      @y -= @height
      @events.onPressed = new Phaser.Signal()
      @events.onReleased = new Phaser.Signal()
      @game.physics.p2.enable(this)
      @body.fixedRotation = true
      @body.motionState = Phaser.Physics.P2.Body.STATIC
      numPressing = 0
      @body.onBeginContact.add((body) =>
        if body.sprite
          numPressing += 1
          if numPressing is 1
            @game.sound.play('button_click')
            @events.onPressed.dispatch()
            eval(@onpress) if @onpress
            @frame = 1
      )
      @body.onEndContact.add((body) =>
        if body.sprite
          numPressing -= 1
          if numPressing is 0
            @game.sound.play('button_release')
            @events.onReleased.dispatch()
            eval(@onrelease) if @onrelease
            @frame = 0
      )

    # update: () =>
