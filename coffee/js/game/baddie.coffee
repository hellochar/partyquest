define [
  'game/mysprite'
], (MySprite) ->
  class Baddie extends MySprite
    constructor: (game, x, y, key, frame = 1) ->
      super(game, x, y, key, frame)
      @body.mass = 5
      @lastSnort = 0
      @animations.add("left", [1, 0], 10, true)
      @animations.add("right", [2, 3], 10, true)

      # explode on killed
      @events.onKilled.add(() =>
        volume = @game.player.volumeFor(this)
        @game.sound.play('pig_squeal', volume)
        @game.sound.play('explosion_audio', volume)
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
      )

    initialize: () =>
      @sightRange = parseFloat(@sightRange || 280)
      @speed = parseFloat(@speed || 60)

    hitPlayer: (player) =>
      @kill()

    distanceToPlayer: () => @position.distance(@game.player.sprite.position)

    isAttacking: () => @distanceToPlayer() < @sightRange

    update: () =>
      if @exists
        if @isAttacking()
          # @game.physics.arcade.moveToObject(this, @game.player.sprite, @speed || 60)
          angle = Math.atan2(@y - @game.player.sprite.y, @x - @game.player.sprite.x)

          speed = if @tileUnderneathMe().isIce() then @speed / 13 else @speed
          vel = @getPixelVelocity()
          @body.velocity.x = vel.x - Math.cos(angle) * speed
          @body.velocity.y = vel.y - Math.sin(angle) * speed

          if Date.now() - @lastSnort > 12 * 1000
            @lastSnort = Date.now()
            @game.sound.play('pig_grunt', @game.player.volumeFor(this))

        if @body.velocity.x < -.1
          @animations.play('right')
        else if @body.velocity.x > .1
          @animations.play('left')
        else
          @animations.stop()
          @frame = 2 if @frame is 3
          @frame = 1 if @frame is 0
          if Math.random() < .003
            if @frame < 2
              @frame = 2
            else
              @frame = 1
