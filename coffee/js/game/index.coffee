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

  timeStarted = Date.now()

  updateNumPlayers = (num) ->
    numPlayersText.setText("Players: #{num}")

  level = undefined
  player = undefined
  deathText = null
  numPlayersText = null

  preload = ->
    level = new Level(game)
    level.preload()
    game.level = level

    player = new Player(game)
    player.preload()
    game.player = player

    game.load.spritesheet('baddie', 'images/baddie.png', 32, 32)

    game.load.audio('pickup-coin', 'audio/Pickup_Coin.wav')
    game.load.audio('hit-wall', 'audio/Hit_Wall.wav')
    game.load.audio('hit-spike', 'audio/Hit_Spike.wav')
    game.load.audio('pig_grunt', 'audio/pig_grunt.mp3')


  create = ->
    game.antialias = false
    game.stage.disableVisibilityChange = true

    #  We're going to be using physics, so enable the Arcade Physics system
    game.physics.startSystem(Phaser.Physics.ARCADE)
    game.physics.arcade.TILE_BIAS = 64

    # the level must be created before the player
    level.create()
    player.create()

    style = {font: "20pt Arial", fill: "white", align: "left" }
    deathText = game.add.text(0, 0, "", style)
    deathText.fixedToCamera = true
    deathText.cameraOffset.setTo(0, 0)

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

    hitBaddie = (player, wall) ->
      player.kill()
      game.sound.play('pig_grunt')

    hitExit = (player, wall) ->
      $("#overlay").fadeIn(1000).text("you win!")

    # player
    game.physics.arcade.collide(player.sprite, level.platforms, hitWall)

    game.physics.arcade.collide(level.spikes)
    game.physics.arcade.collide(level.spikes, level.platforms)

    # boxes
    game.physics.arcade.collide(level.boxes)
    game.physics.arcade.collide(level.spikes, level.boxes)
    game.physics.arcade.collide(level.boxes, level.platforms)

    # baddie
    game.physics.arcade.collide(level.baddies, level.platforms)
    game.physics.arcade.collide(level.baddies, level.spikes)
    game.physics.arcade.collide(level.baddies, level.boxes)
    game.physics.arcade.collide(level.baddies)

    level.baddies.forEach(game.debug.body, game.debug)

    game.physics.arcade.overlap(player.sprite, level.spikes, hitSpike, null, this)
    game.physics.arcade.overlap(player.sprite, level.baddies, hitBaddie, null, this)
    game.physics.arcade.overlap(player.sprite, level.exit, hitExit, null, this)

    deathText.setText( "deaths: #{player.deaths}" )

    game.camera.follow(player.sprite)

  game = new Phaser.Game(window.innerWidth, window.innerHeight, Phaser.AUTO, "viewport",
    preload: preload
    create: create
    update: update
  )
  game.socket = socket

  game.drag = (sprite, amount = 0.5) ->
    sprite.body.velocity.setMagnitude(sprite.body.velocity.getMagnitude() * amount)

  window.game = game

  resizeGame = () ->
    width = $(window).width()
    height = $(window).height()
    game.width = width
    game.height = height
    game.stage.bounds.width = width
    game.stage.bounds.height = height
    game.camera.view.width = width
    game.camera.view.height = height
    level.platforms.width = width
    level.platforms.height = height

    if game.renderType is Phaser.WEBGL
      game.renderer.resize(width, height)

  $(window).resize(resizeGame)
