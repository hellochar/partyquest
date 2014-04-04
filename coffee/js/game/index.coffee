require [
  'jquery'
  "socket.io"
  'phaser'
  'game/level'
  'game/demolevel'
  'game/player'
], ($, io, Phaser, Level, DemoLevel, Player) ->

  $("#overlay").hide()

  socket = io.connect('/game')

  deaths = 0
  timeStarted = Date.now()

  updateNumPlayers = (num) ->
    numPlayersText.setText("Players: #{num}")

  collectStar = (player, star) ->
    # Removes the star from the screen
    game.sound.play('pickup-coin')
    star.kill()
    if stars.countLiving() is 0
      $("#overlay").fadeIn(1000).text("You win!")

  level = undefined
  player = undefined
  stars = undefined
  deathText = null
  starsText = null
  numPlayersText = null


  preload = ->
    level = new DemoLevel(game)
    level.preload()
    window.level = level

    player = new Player(game)
    player.preload()
    window.player = player

    game.load.image('star', 'images/star.png')
    game.load.audio('pickup-coin', 'audio/Pickup_Coin.wav')
    game.load.audio('hit-wall', 'audio/Hit_Wall.wav')
    game.load.audio('hit-spike', 'audio/Hit_Spike.wav')


  create = ->
    game.antialias = false
    game.stage.disableVisibilityChange = true

    #  We're going to be using physics, so enable the Arcade Physics system
    game.physics.startSystem Phaser.Physics.ARCADE

    level.create()
    player.create()

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

    socket.on('players', updateNumPlayers)

  update = ->
    level.update()
    player.update()

    hitWall = (player, wall) ->
      game.sound.play('hit-wall')

    hitSpike = (player, spike) ->
      player.kill()
      game.sound.play('hit-spike')

    game.physics.arcade.collide(player.sprite, level.platforms, hitWall)
    game.physics.arcade.overlap(player.sprite, level.spikes, hitSpike, null, this)
    game.physics.arcade.overlap(player.sprite, stars, collectStar, null, this)
    game.physics.arcade.collide(stars, level.platforms)

    deathText.setText( "deaths: #{deaths}" )
    starsText.setText( "stars collected: #{stars.countDead()}/#{stars.children.length}" )

    game.camera.bounds = null
    game.camera.focusOnXY(player.sprite.body.x * game.camera.scale.x, player.sprite.body.y * game.camera.scale.y)

  game = new Phaser.Game(window.innerWidth, window.innerHeight, Phaser.AUTO, "viewport",
    preload: preload
    create: create
    update: update
  )
  game.socket = socket
  window.game = game
