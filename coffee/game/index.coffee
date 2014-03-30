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

  tryJump = () ->
    #  Allow the player to jump if they are touching the ground.
    player.body.velocity.y += -500 if player.body.touching.down

  socket.on('left', moveLeft)
  socket.on('right', moveRight)
  socket.on('up', tryJump)


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
  cursors = undefined
  stars = undefined

  create = ->

    #  We're going to be using physics, so enable the Arcade Physics system
    game.physics.startSystem Phaser.Physics.ARCADE

    #  A simple background for our game
    game.add.sprite 0, 0, "sky"

    #  The platforms group contains the ground and the 2 ledges we can jump on
    platforms = game.add.group()

    #  We will enable physics for any object that is created in this group
    platforms.enableBody = true

    # Here we create the ground.
    ground = platforms.create(0, 600 - 64, "ground")

    # #  Scale it to fit the width of the game (the original sprite is 400x32 in size)
    # ground.scale.setTo 2, 2

    #  This stops it from falling away when you jump on it
    ground.body.immovable = true

    #  Now let's create two ledges
    ledge = platforms.create(400, 400, "ground")
    ledge.body.immovable = true
    ledge = platforms.create(-150, 250, "ground")
    ledge.body.immovable = true

    # The player and its settings
    player = game.add.sprite(32, 600 - 150, "dude")

    #  We need to enable physics on the player
    game.physics.arcade.enable player

    #  Player physics properties. Give the little guy a slight bounce.
    player.body.bounce.y = 0.0
    player.body.gravity.y = 600
    player.body.collideWorldBounds = true

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

    cursors = game.input.keyboard.createCursorKeys()

    stars = game.add.group()
    stars.enableBody = true

    #  Here we'll create 12 of them evenly spaced apart
    i = 0

    while i < 12

      #  Create a star inside of the 'stars' group
      star = stars.create(i * 70, 0, "star")

      #  Let gravity do its thing
      star.body.gravity.y = 6

      #  This just gives each star a slightly random bounce value
      star.body.bounce.y = 0.7 + Math.random() * 0.2
      i++

  update = ->
    game.physics.arcade.collide(player, platforms)
    game.physics.arcade.collide(stars, platforms)
    game.physics.arcade.overlap(player, stars, collectStar, null, this)

    player.body.velocity.x *= .8

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
