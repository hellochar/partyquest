define [
  'phaser'
], (Phaser) ->
  MOVE_SPEED = 500

  class Spike extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      # p2 forces the anchor to be at the center but x/y are top-left, so move the sprite
      # such that the physics body is positioned correctly
      @x += @width/2
      @y += @height/2

      @y -= @height
      @game.physics.p2.enable(this)
      @body.fixedRotation = true
      @body.damping = 1 - (1e-10)

      # @body.onBeginContact.add((body) =>
      #   @game.sound.play('spike_hit_wall', game.player.volumeFor(this))
      # )

      setTimeout(() =>
        if @moves is "vertical"
          @direction = "down"
        else if @moves is "horizontal"
          @direction = "right"
        # if @direction
        #   @sound = @game.sound.play('saw', 0, true)
      , 0)

    update: () =>
      # if @sound
      #   @sound.volume = game.player.volumeFor(this) / 5
      switch @direction
        when "down"
          if @body.velocity.y < -1
            @body.moveDown(MOVE_SPEED)
          else
            @direction = "up"
            @body.moveUp(MOVE_SPEED)
        when "up"
          if @body.velocity.y > 1
            @body.moveUp(MOVE_SPEED)
          else
            @direction = "down"
            @body.moveDown(MOVE_SPEED)
        when "left"
          if @body.velocity.x > 1
            @body.moveLeft(MOVE_SPEED)
          else
            @direction = "right"
            @body.moveRight(MOVE_SPEED)
        when "right"
          if @body.velocity.x < -1
            @body.moveRight(MOVE_SPEED)
          else
            @direction = "left"
            @body.moveLeft(MOVE_SPEED)
