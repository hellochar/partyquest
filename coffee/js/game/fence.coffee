define [
  'game/mysprite'
  'phaser'
], (MySprite, Phaser) ->
  class Fence extends MySprite
    constructor: (game, x, y, key, frame = 4) ->
      super(game, x, y, key, frame)
      @body.motionState = Phaser.Physics.P2.Body.STATIC
      @body.static = true
      @body.mass = Number.MAX_VALUE

      # @events.onRevived.add(() =>
      #   if @getBounds().intersects(@game.player.sprite.getBounds())
      #     game.player.sprite.kill()
      # )
