define [
  'phaser'
], (Phaser) ->
  class Baddie extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      @anchor.set(0, 0)
      @game.physics.p2.enable(this)

    update: () =>
      # TODO fix this
      @game.physics.arcade.moveToObject(this, @game.player.sprite, 60)

