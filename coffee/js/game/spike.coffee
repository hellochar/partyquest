define [
  'phaser'
], (Phaser) ->
  class Spike extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      @anchor.set(0, 0)
      @game.physics.arcade.enable(this)
      @body.collideWorldBounds = true
      if @moves is "vertical"
        @direction = "down"
        @body.bounce.set(1)

    update: () =>
      @game.drag(this)
      switch @direction
        when "down" then @body.velocity.x += 1000
