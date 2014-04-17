define [
  'jquery'
  'underscore'
  'phaser'
  'game/spike'
  'game/mysprite'
], ($, _, Phaser, Spike, MySprite) ->


  class PlayerSprite extends MySprite
    constructor: (@player, x, y) ->
      super(player.game, x, y, 'dude', 4)
      @body.damping = 1 - (1e-12)
      # normally the body is 32x32 but make it a bit smaller; it's more fun this way
      @body.setRectangle(@width - 6, @height - 6, 0, 0, 0)
      @body.y += @height

      @animations.add("left", [0, 1, 2, 3], 10, true)
      @animations.add("right", [5, 6, 7, 8], 10, true)

    update: () =>
      @body.damping = 0
      @body.data.lastDampingTimeStep = 0

      # ok *getting* the velocity gives it to you in meters (aka game.world.mpx()), but you should *set* in pixel coordinates

      # if Math.abs(@body.velocity.x) < .1
      #   @body.velocity.x = 0
      # if Math.abs(@body.velocity.y) < .1
      #   @body.velocity.y = 0

      vel = new Phaser.Point(@body.velocity.world.mpxi(@body.velocity.x), @body.velocity.world.mpxi(@body.velocity.y))

      FRICTION_OFFSET = 138
      dVel = vel.clone().setMagnitude(-Math.min(FRICTION_OFFSET, vel.getMagnitude()))

      @body.velocity.x = vel.x + dVel.x
      @body.velocity.y = vel.y + dVel.y
      # console.log(@body.velocity.x+", "+(@body.velocity.x = vel.x)+", "+@body.velocity.x)

      if not _.isFinite(@body.velocity.x) or
         not _.isFinite(@body.velocity.y)
        @body.velocity.x = @body.velocity.y = 0

      if Math.abs(@body.velocity.x) < 1
        @animations.stop()
        @frame = 4
      else if @body.velocity.x < 0
        @animations.play('right')
      else if @body.velocity.x > 0
        @animations.play('left')

      # if @tileUnderneathMe().isIce()
      #   @player.tapVelocity = 300
      # else
      #   @player.tapVelocity = 1300

  class Player
    constructor: (@game) ->
      @sprite = null
      @deaths = 0
      @tapVelocity = 800

    preload: () ->
      @game.load.spritesheet('dude', 'images/dude.png', 32, 42)
      @game.load.image('left-arrow', 'images/arrow.png')

      @game.load.audio('move', 'audio/Move.wav')
      @game.load.audio('death', 'audio/death.mp3')
      @game.load.audio('hit_spike', 'audio/Hit_Spike.wav')

    create: () ->
      @reset()
      @setupSockets()

    hitSpike: (spike) ->
      @sprite.kill()
      @game.sound.play('hit_spike')

    hitBaddie: (baddie) ->
      @sprite.kill()

    reset: () =>
      if @sprite
        @sprite.destroy()

      @sprite = new PlayerSprite(this, @game.level.spawnLocation.x, @game.level.spawnLocation.y)
      @sprite = @game.world.add(@sprite)

      @sprite.events.onKilled.add(() =>
        @game.sound.play('death')
        @deaths += 1
        setTimeout(@reset, 1000)
      )

    volumeFor: (sprite) ->
      # pixel distance - things more than 1 screen away should be only 10% volume
      # screen is about ~1500 pixels
      # near to you (within .25 of a screen) = ~400 pixels should still be full volume
      dist = sprite.position.distance(@sprite.position)

      @game.math.clamp(100 / dist - .1, 0, 1)

    setupSockets: () =>
      socket = @game.socket
      cursors = @game.input.keyboard.createCursorKeys()
      mapping = {
        left: @moveLeft
        right: @moveRight
        up: @moveUp
        down: @moveDown
      }
      for direction of mapping
        socket.on(direction, mapping[direction])
        cursors[direction].onDown.add(mapping[direction])

    fadeArrow: (angle) =>
      {x: x, y: y} = @sprite.body
      @game.sound.play('move')
      arrow = @game.add.sprite(x, y, "left-arrow")
      arrow.angle = angle
      arrow.anchor.set(0.5)
      setTimeout(() ->
        arrow.kill()
      , 1000)

    moveLeft: () =>
      #  Move to the left
      @sprite.body.velocity.x += -@tapVelocity
      @fadeArrow(0)

    moveRight: () =>
      @sprite.body.velocity.x += @tapVelocity
      @fadeArrow(180)

    moveUp: () =>
      @sprite.body.velocity.y += -@tapVelocity
      @fadeArrow(90)

    moveDown: () =>
      @sprite.body.velocity.y += @tapVelocity
      @fadeArrow(-90)
