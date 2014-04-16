define [
  'jquery'
  'underscore'
  'phaser'
  'game/spike'
], ($, _, Phaser, Spike) ->

  class Player
    constructor: (@game) ->
      @sprite = null
      @deaths = 0
      @tapVelocity = 1300

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
      @sprite = @game.add.sprite(@game.level.spawnLocation.x, @game.level.spawnLocation.y, "dude")
      @sprite.height = 32
      @sprite.x += @sprite.width/2
      @sprite.y += @sprite.height/2
      @sprite.player = this
      # @sprite.smoothed = false

      @game.physics.p2.enable(@sprite)
      @sprite.body.damping = 1 - (1e-12)
      @sprite.body.fixedRotation = true
      @sprite.body.setRectangle(26, 26, 0, 0, 0) # normally the body is 32x32 but make it a bit smaller; it's more fun this way

      @sprite.animations.add("left", [0, 1, 2, 3], 10, true)
      @sprite.animations.add("right", [5, 6, 7, 8], 10, true)
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

    update: () ->
      # @sprite.position.clampX(@game.physics.arcade.bounds.x, @game.physics.arcade.bounds.right - @sprite.width)
      # @sprite.position.clampY(@game.physics.arcade.bounds.y, @game.physics.arcade.bounds.bottom - @sprite.height)

      if not _.isFinite(@sprite.body.velocity.x) or
         not _.isFinite(@sprite.body.velocity.y)
        @sprite.body.velocity.x = @sprite.body.velocity.y = 0



      if Math.abs(@sprite.body.velocity.x) < 1
        @sprite.animations.stop()
        @sprite.frame = 4
      else if @sprite.body.velocity.x < 0
        @sprite.animations.play('right')
      else if @sprite.body.velocity.x > 0
        @sprite.animations.play('left')

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
