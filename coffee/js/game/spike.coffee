define [
  'game/mysprite'
], (MySprite) ->
  MOVE_SPEED = 500

  class Spike extends MySprite
    initialize: () =>
      if @moves is "vertical"
        @direction = "down"
      else if @moves is "horizontal"
        @direction = "right"
      # if @direction
      #   @sound = @game.sound.play('saw', 0, true)

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
