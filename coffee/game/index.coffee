require [
  'jquery'
  "socket.io"
  'phaser'
], ($, io, Phaser) ->

  socket = io.connect('/game')

  moveLeft = () ->
    #  Move to the left
    player.body.velocity.x += -500

  moveRight = () ->
    player.body.velocity.x += 500

  moveUp = () ->
    player.body.velocity.y += -500

  moveDown = () ->
    player.body.velocity.y += 500

  socket.on('left', moveLeft)
  socket.on('right', moveRight)
  socket.on('up', moveUp)
  socket.on('down', moveDown)


  collectStar = (player, star) ->
    # Removes the star from the screen
    star.kill()

  preload = ->
    game.load.image('sky', 'images/sky.png')
    game.load.image('ground', 'images/platform.png')
    game.load.image('star', 'images/star.png')
    game.load.spritesheet('dude', 'images/dude.png', 32, 48)

  player = undefined
  platforms = undefined
  stars = undefined

  create = ->

    game.antialias = false

    ratio = window.innerWidth / 1400

    game.camera.scale.setTo ratio, ratio

    game.world.setBounds(0, 0, 3000, 600)

    #  We're going to be using physics, so enable the Arcade Physics system
    game.physics.startSystem Phaser.Physics.ARCADE

    #  A simple background for our game
    game.add.tileSprite 0, 0, 3000, 600, "sky"

    #  The platforms group contains the ground and the 2 ledges we can jump on
    platforms = game.add.group()

    #  We will enable physics for any object that is created in this group
    platforms.enableBody = true

    # Here we create the ground.
    ground = platforms.create(0, 600 - 64, "ground")
    ground.smoothed = false

    #  This stops it from falling away when you jump on it
    ground.body.immovable = true

    for i in [0...5]
      #  Now let's create two ledges
      ledge = platforms.create(800 * i, 400, "ground")
      ledge.smoothed = false
      ledge.body.immovable = true
      ledge = platforms.create(-150 + 600 * i, 250, "ground")
      ledge.smoothed = false
      ledge.body.immovable = true

    # The player and its settings
    player = game.add.sprite(32, 600 - 150, "dude")
    player.anchor.set(0.5)
    player.smoothed = false

    #  We need to enable physics on the player
    game.physics.arcade.enable player

    player.body.collideWorldBounds = true
    player.body.gravity.y = 300

    window.player = player

    #  Our two animations, walking left and right.
    player.animations.add "left", [
      0
      1
      2
      3
    ], 10, true
    player.animations.add "right", [
      5
      6
      7
      8
    ], 10, true

    # game.camera.follow(player, Phaser.Camera.FOLLOW_PLATFORMER)

    stars = game.add.group()
    stars.enableBody = true

    #  Here we'll create 12 of them evenly spaced apart
    i = 0

    while i < 12

      #  Create a star inside of the 'stars' group
      star = stars.create(i * 70, 0, "star")
      star.smoothed = false

      #  This just gives each star a slightly random bounce value
      star.body.bounce.y = 0.7 + Math.random() * 0.2
      i++

  update = ->
    game.physics.arcade.collide(player, platforms)
    game.physics.arcade.collide(stars, platforms)
    game.physics.arcade.overlap(player, stars, collectStar, null, this)

    game.camera.bounds = null
    game.camera.focusOnXY(player.body.x * game.camera.scale.x, player.body.y * game.camera.scale.y)

    player.body.velocity.setMagnitude(player.body.velocity.getMagnitude() * .8)

    if Math.abs(player.body.velocity.x) < 10
      player.body.velocity.x = 0
      player.animations.stop()
      player.frame = 4
    else if player.body.velocity.x > 0
      player.animations.play('right')
    else if player.body.velocity.x < 0
      player.animations.play('left')

  game = new Phaser.Game(window.innerWidth, window.innerHeight, Phaser.AUTO, "viewport",
    preload: preload
    create: create
    update: update
  )
  window.game = game
