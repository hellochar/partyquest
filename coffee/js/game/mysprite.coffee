define [
  'phaser'
], (Phaser) ->

  class MySprite extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      # p2 forces the anchor to be at the center but x/y are top-left, so move the sprite
      # such that the physics body is positioned correctly
      @x += @width/2
      @y += @height/2

      # Tiled passes the bottom-left corner in as x/y but we're expecting top-left, so shift the y accordingly (we cannot use adjustY in createFromObjects because the position of the sprite must be set before p2 physics is enabled)
      @y -= @height

      @game.physics.p2.enable(this)
      @body.fixedRotation = true
      @body.damping = 1 - (1e-10)

      setTimeout(@initialize, 0) if @initialize
