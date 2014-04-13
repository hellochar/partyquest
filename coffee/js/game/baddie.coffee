define [
  'phaser'
], (Phaser) ->
  class Baddie extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      @anchor.set(0, 0)
      @game.physics.p2.enable(this)
      @body.fixedRotation = true
      @body.damping = 1 - (1e-10)
      @lastSnort = 0
      @animations.add("left", [1, 0], 10, true)
      @animations.add("right", [2, 3], 10, true)

    hitPlayer: (player) ->
      @game.sound.play('pig_squeal')
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
      @destroy()

    distanceToPlayer: () => @position.distance(@game.player.sprite.position)

    isAttacking: () => @distanceToPlayer() < 300

    update: () =>
      if @isAttacking()
        @game.physics.arcade.moveToObject(this, @game.player.sprite, 60)
        if Date.now() - @lastSnort > 12 * 1000
          @lastSnort = Date.now()
          @game.sound.play('pig_grunt')

      if @body.velocity.x < -.1
        @animations.play('right')
      else if @body.velocity.x > .1
        @animations.play('left')
      else
        @animations.stop()
        if Math.random() < .003
          if @frame < 2
            @frame = 2
          else
            @frame = 1
