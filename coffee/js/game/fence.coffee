define [
  'phaser'
], (Phaser) ->
  class Fence extends Phaser.Sprite
    constructor: (game, x, y, key, frame = 4) ->
      super(game, x, y, key, frame)
      @x += @width/2
      @y += @height/2
      @y -= @height
      @game.physics.p2.enable(this)
      @body.fixedRotation = true
      @body.motionState = Phaser.Physics.P2.Body.STATIC
      @body.static = true
      @body.mass = Number.MAX_VALUE

    # update: () =>
