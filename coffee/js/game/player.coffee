define [
  'jquery'
], ($) ->

  class Player
    constructor: (@game) ->
      @sprite = null
      @deaths = 0

    preload: () ->
      game.load.spritesheet('dude', 'images/dude.png', 32, 42)
      game.load.image('left-arrow', 'images/arrow.png')

      game.load.audio('move', 'audio/Move.wav')
      game.load.audio('death', 'audio/death.mp3')

    create: () ->
      @sprite = game.add.sprite(32, 32, "dude")
      @sprite.anchor.set(0.5)
      @sprite.smoothed = false
      @game.physics.arcade.enable(@sprite)

      @sprite.body.collideWorldBounds = true

      #  Our two animations, walking left and right.
      @sprite.animations.add "left", [
        0
        1
        2
        3
      ], 10, true
      @sprite.animations.add "right", [
        5
        6
        7
        8
      ], 10, true
      @sprite.events.onKilled.add(() =>
        game.sound.play('death')
        @deaths += 1
        setTimeout(() =>
          @sprite.reset(32, 32)
        , 1000)
      )
      @setupSockets()

    update: () ->
      @game.drag(@sprite)

      if Math.abs(@sprite.body.velocity.x) < 10
        @sprite.body.velocity.x = 0
        @sprite.animations.stop()
        @sprite.frame = 4
      else if @sprite.body.velocity.x > 0
        @sprite.animations.play('right')
      else if @sprite.body.velocity.x < 0
        @sprite.animations.play('left')

    setupSockets: () =>
      socket = @game.socket
      socket.on('left', @moveLeft)
      socket.on('right', @moveRight)
      socket.on('up', @moveUp)
      socket.on('down', @moveDown)

    fadeArrow: (angle) =>
      {x: x, y: y} = @sprite.body
      game.sound.play('move')
      arrow = game.add.sprite(x, y, "left-arrow")
      arrow.angle = angle
      arrow.anchor.set(0.5)
      setTimeout(() ->
        arrow.kill()
      , 1000)

    moveLeft: () =>
      #  Move to the left
      @sprite.body.velocity.x += -500
      @fadeArrow(0)

    moveRight: () =>
      @sprite.body.velocity.x += 500
      @fadeArrow(180)

    moveUp: () =>
      @sprite.body.velocity.y += -500
      @fadeArrow(90)

    moveDown: () =>
      @sprite.body.velocity.y += 500
      @fadeArrow(-90)
