require [
  'jquery'
  'underscore'
  "socket.io"
  'phaser'
  'game/level'
  'game/demolevel'
  'game/player'
], ($, _, io, Phaser, Level, DemoLevel, Player) ->

  overlay = (text) ->
    $("#overlay").fadeIn(1000).text(text)
    setTimeout(() ->
      $("#overlay").fadeOut(1000)
    , 1000)

  level = undefined
  player = undefined
  deathText = null
  numPlayersText = null
  timeText = null

  socket = io.connect('/game')

  updateNumPlayers = (num) ->
    numPlayersText.setText("Players: #{num}")


  loadLevel = (num) ->
    console.log("loading level #{num}")
    if level.num != num
      if level.map
        level.destroy()
      level = new Level(game, num)
      game.sound.play('drum_tom')
      game.level = level
      level.create()
      if player
        player.reset()

  preload = ->

    # game.load.onLoadComplete.add(() -> debugger)
    game.load.onFileComplete.add(() -> console.log("loaded", arguments, "("+game.load.progress+")"))
    game.load.onFileError.add(() -> console.log("error loading", arguments, "("+game.load.progress+")"))

    console.log("preloaded!")

    level = new Level(game, 0)
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
    game.load.audio('drum_tom', 'audio/drum_tom.mp3')
    game.load.audio('crowd_applause', 'audio/crowd_applause.mp3')


  create = ->
    game.antialias = false
    game.stage.disableVisibilityChange = true

    #  We're going to be using physics, so enable the Arcade Physics system
    game.physics.startSystem(Phaser.Physics.ARCADE)
    game.physics.arcade.TILE_BIAS = 64

    # the level must be created before the player
    overlay("Level 1")
    # $("#overlay").hide()
    loadLevel(2)
    player.create()

    style = {font: "20pt Arial", fill: "white", align: "left" }
    deathText = game.add.text(0, 0, "", style)
    deathText.fixedToCamera = true
    deathText.cameraOffset.setTo(0, 0)
    deathText.update = () ->
      deathText.setText( "Deaths: #{player.deaths}" )

    numPlayersText = game.add.text(0, 0, "", style)
    numPlayersText.fixedToCamera = true
    numPlayersText.cameraOffset.setTo(0, 24)
    updateNumPlayers("???")

    timeText = game.add.text(0, 0, "", _.extend(style, align: "center"))
    timeText.fixedToCamera = true
    timeText.cameraOffset.setTo(game.width / 2, 0)
    timeText.update = () ->
      formattime = (numberofseconds) ->
        zero = '0'
        time = new Date(0, 0, 0, 0, 0, numberofseconds, 0)
        hh = time.getHours()
        mm = time.getMinutes()
        ss = time.getSeconds()

        # Pad zero values to 00
        hh = (zero+hh).slice(-2)
        mm = (zero+mm).slice(-2)
        ss = (zero+ss).slice(-2)

        if hh > 0
          hh + ':' + mm + ':' + ss
        else
          mm + ':' + ss

      timeText.setText( formattime((Date.now() - game.level.timeStarted) / 1000 | 0) )

    socket.on('players', updateNumPlayers)

  update = ->
    level.update()
    player.update()

    hitWall = (player, wall) ->
      game.sound.play('hit-wall')

    hitSpike = (player, spike) ->
      player.kill()
      game.sound.play('hit-spike')

    hitBaddie = (player, baddie) ->
      player.kill()
      game.sound.play('pig_grunt')

    hitExit = (player, exit) ->
      if not level.finished
        level.finished = true
        game.sound.play('crowd_applause')
        game.sound.play('Pickup_Coin')
        currentLevel = level.num
        overlay("Level #{currentLevel + 1}")
        setTimeout(() ->
          loadLevel(currentLevel + 1)
        , 1000)

    # player
    game.physics.arcade.collide(player.sprite, level.platforms, hitWall)
    game.physics.arcade.collide(player.sprite, level.boxes)

    game.physics.arcade.overlap(player.sprite, level.spikes, hitSpike, null, this)
    game.physics.arcade.overlap(player.sprite, level.baddies, hitBaddie, null, this)
    game.physics.arcade.overlap(player.sprite, level.exit, hitExit, null, this)

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
    # level.platforms.width = width
    # level.platforms.height = height
    # level.platforms.updateMax()

    if game.renderType is Phaser.WEBGL
      game.renderer.resize(width, height)

  $(window).resize(resizeGame)
