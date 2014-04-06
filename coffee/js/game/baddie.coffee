define [
  'phaser'
], (Phaser) ->
  class Baddie extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      @anchor.set(0.5)
      @game.physics.arcade.enable(this)
      # @body.y -= 32
      @body.collideWorldBounds = true

    update: () =>
      @game.physics.arcade.moveToObject(this, @game.player.sprite, 60)

