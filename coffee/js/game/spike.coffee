define [
  'game/mysprite'
], (MySprite) ->

  class Spike extends MySprite
    initialize: () =>
      @MOVE_SPEED = parseInt(@MOVE_SPEED || 300)
      if @moves is "vertical"
        @direction = "down"
      else if @moves is "horizontal"
        @direction = "right"
      @body.mass = 10

    update: () =>
      # if @sound
      #   @sound.volume = game.player.volumeFor(this) / 5
      switch @direction
        when "down"
          if @body.velocity.y < -.1
            @body.velocity.y += @MOVE_SPEED
          else
            @direction = "up"
            @body.velocity.y -= @MOVE_SPEED
        when "up"
          if @body.velocity.y > .1
            @body.velocity.y -= @MOVE_SPEED
          else
            @direction = "down"
            @body.velocity.y += @MOVE_SPEED
        when "left"
          if @body.velocity.x > .1
            @body.velocity.x -= @MOVE_SPEED
          else
            @direction = "right"
            @body.velocity.x += @MOVE_SPEED
        when "right"
          if @body.velocity.x < -.1
            @body.velocity.x += @MOVE_SPEED
          else
            @direction = "left"
            @body.velocity.x -= @MOVE_SPEED
