define [
  'phaser'
], (Phaser) ->
  class Baddie extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      @anchor.set(0, 0)
      @game.physics.p2.enable(this)
      @body.fixedRotation = true
      @lastSnort = 0
      @animations.add("left", [1, 0], 10, true)
      @animations.add("right", [2, 3], 10, true)

    hitPlayer: (player) ->
      @game.sound.play('pig_squeal')
      @kill()
      @game.sound.play('explosion_audio')
      explosion = @game.add.sprite(@x, @y, 'explosion')
      explosion.scale.set(2)
      explosion.anchor.set(0.5)
      anim = explosion.animations.add('explosion')
      anim.play(20, false)
      setTimeout(() =>
        residue = @game.add.sprite(explosion.x, explosion.y, 'explosion_residue')
        residue.scale.set(2)
        residue.anchor.set(0.5)
        explosion.bringToTop()
      , 400)
      anim.onComplete.add(() =>
        setTimeout((-> explosion.destroy()), 0)
      )

    update: () =>
      # TODO fix this
      @game.physics.arcade.moveToObject(this, @game.player.sprite, 60)
      if @body.velocity.x < 0
        @animations.play('right')
      else
        @animations.play('left')
      if @position.distance(@game.player.sprite.position) < 100 and Date.now() - @lastSnort > 12 * 1000
        @lastSnort = Date.now()
        @game.sound.play('pig_grunt')
