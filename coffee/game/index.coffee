require [
  'jquery'
  "socket.io"
  'phaser'
], ($, io, Phaser) ->

  $("#overlay").hide()

  socket = io.connect('/game')

  deaths = 0
  timeStarted = Date.now()

  fadeArrow = (angle) ->
    {x: x, y: y} = player.body
    game.sound.play('move')
    arrow = game.add.sprite(x, y, "left-arrow")
    arrow.angle = angle
    arrow.anchor.set(0.5)
    setTimeout(() ->
      arrow.kill()
    , 1000)

  moveLeft = () ->
    #  Move to the left
    player.body.velocity.x += -500
    fadeArrow(0)

  moveRight = () ->
    player.body.velocity.x += 500
    fadeArrow(180)

  moveUp = () ->
    player.body.velocity.y += -500
    fadeArrow(90)

  moveDown = () ->
    player.body.velocity.y += 500
    fadeArrow(-90)

  updateNumPlayers = (num) ->
    numPlayersText.setText("Players: #{num}")

  setupSockets = () ->
    socket.on('left', moveLeft)
    socket.on('right', moveRight)
    socket.on('up', moveUp)
    socket.on('down', moveDown)
    socket.on('players', updateNumPlayers)

  collectStar = (player, star) ->
    # Removes the star from the screen
    game.sound.play('pickup-coin')
    star.kill()
    if stars.countLiving() is 0
      $("#overlay").fadeIn(1000).text("You win!")

  hitSpike = (player, spike) ->
    player.kill()
    game.sound.play('death')
    game.sound.play('hit-spike')
    deaths += 1
    $("#overlay").fadeIn(1000, () -> 
      player.reset(32, 32)
      $("#overlay").fadeOut(1000)
    )

  playerCollided = (player, wall) ->
    game.sound.play('hit-wall')

  preload = ->
    game.load.image('sky', 'images/sky.png')
    game.load.image('ground', 'images/platform.png')
    game.load.image('star', 'images/star.png')
    game.load.spritesheet('dude', 'images/dude.png', 32, 48)
    game.load.image('spike', 'images/spikes.png')
    game.load.image('left-arrow', 'images/arrow.png')

    game.load.audio('pickup-coin', 'audio/Pickup_Coin.wav')
    game.load.audio('hit-spike', 'audio/Hit_Spike.wav')
    game.load.audio('hit-wall', 'audio/Hit_Wall.wav')
    game.load.audio('move', 'audio/Move.wav')
    game.load.audio('death', 'audio/death.mp3')

  player = undefined
  platforms = undefined
  stars = undefined
  spikes = null
  deathText = null
  starsText = null
  numPlayersText = null

  create = ->

    game.antialias = false

    ratio = window.innerWidth / 2000

    game.world.setBounds(0, 0, 1500, 1900)

    #  We're going to be using physics, so enable the Arcade Physics system
    game.physics.startSystem Phaser.Physics.ARCADE

    #  A simple background for our game
    game.add.tileSprite 0, 0, game.world.width, game.world.height, "sky"

    #  The platforms group contains the ground and the 2 ledges we can jump on
    platforms = game.add.group()

    #  We will enable physics for any object that is created in this group
    platforms.enableBody = true

    # Here we create the ground.
    ground = platforms.create(0, 600 - 64, "ground")
    ground.smoothed = false

    #  This stops it from falling away when you jump on it
    ground.body.immovable = true

    for i in [0...3]
      for y in [0...4]
        #  Now let's create two ledges
        ledge = platforms.create(800 * i, 400 * y, "ground")
        ledge.smoothed = false
        ledge.body.immovable = true
        ledge = platforms.create(-150 + 600 * i, 250 + 400 * y, "ground")
        ledge.smoothed = false
        ledge.body.immovable = true

    spikes = game.add.group()
    spikes.enableBody = true
    for i in [0..45]
      spike = spikes.create(game.rnd.realInRange(40, game.world.width), game.rnd.realInRange(40, game.world.height), "spike")
      spike.smoothed = false

    # The player and its settings
    player = game.add.sprite(32, 32, "dude")
    player.anchor.set(0.5)
    player.smoothed = false

    #  We need to enable physics on the player
    game.physics.arcade.enable player

    player.body.collideWorldBounds = true

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

    i = 0

    while i < 5

      #  Create a star inside of the 'stars' group
      star = stars.create(game.rnd.realInRange(0, game.world.width), game.rnd.realInRange(0, game.world.height), "star")
      star.smoothed = false
      star.body.collideWorldBounds = true
      star.body.velocity.setTo 0, game.rnd.realInRange(-100, 100)
      star.scale.setTo 2, 2

      #  This just gives each star a slightly random bounce value
      star.body.bounce.y = 1
      i++

    style = {font: "20pt Arial", fill: "white", align: "left" }
    deathText = game.add.text(0, 0, "", style)
    deathText.fixedToCamera = true
    deathText.cameraOffset.setTo(0, 0)

    starsText = game.add.text(0, 0, "", style)
    starsText.fixedToCamera = true
    starsText.cameraOffset.setTo(0, 24)

    numPlayersText = game.add.text(0, 0, "", style)
    numPlayersText.fixedToCamera = true
    numPlayersText.cameraOffset.setTo(0, 48)
    updateNumPlayers("???")

    setupSockets()

  update = ->
    game.physics.arcade.collide(player, platforms, playerCollided)
    game.physics.arcade.collide(stars, platforms)
    game.physics.arcade.collide(spikes, spikes)
    game.physics.arcade.overlap(player, stars, collectStar, null, this)
    game.physics.arcade.overlap(player, spikes, hitSpike, null, this)

    deathText.setText( "deaths: #{deaths}" )
    starsText.setText( "stars collected: #{stars.countDead()}/#{stars.children.length}" )

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
