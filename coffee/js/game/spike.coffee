define [
  'phaser'
], (Phaser) ->
  class Spike extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      @anchor.set(0, 0)
      @game.physics.arcade.enable(this)
      @body.collideWorldBounds = true
      setTimeout(() =>
        if @moves is "vertical"
          # start it moving downward
          @body.velocity.y += 200
          @body.bounce.set(1)
      , 0)

    update: () =>
      @game.drag(this)
      if @moves is "vertical"
        if @body.velocity.y > 0
          @body.velocity.y += 200
        else if @body.velocity.y < 0
          @body.velocity.y -= 200

    collidedWith: (other) =>
    #   if @direction is "down"
    #     @direction = "up"
    #   else if @direction is "up"
    #     @direction = "down"

