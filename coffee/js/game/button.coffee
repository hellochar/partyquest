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
            eval(@onpress) if @onpress
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
            eval(@onrelease) if @onrelease
            @frame = 0
      )
