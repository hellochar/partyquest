require [
  'jquery'
  'underscore'
  "socket.io"
  'phaser'
  'overlay'
  'game/level'
  'game/spike'
  'game/baddie'
  'game/player'
  'game/game_monkeypatch'
], ($, _, io, Phaser, Overlay, Level, Spike, Baddie, Player) ->

  numPlayers = 0
  level = undefined
  player = undefined
  deathText = null
  numPlayersText = null
  timeText = null
  playText = null

  huds = []

  createHud = () ->
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

    timeText = game.add.text(0, 0, "", _.extend(_.clone(style, align: "center")))
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

    playText = game.add.text(0, 0, "visit party-quest.com to play!", _.extend(_.clone(style), {fill: "yellow", align: "center"}))
    playText.fixedToCamera = true
    playText.cameraOffset.setTo((game.width - playText.width)/2, game.height - 40)

    # game.add.tween(playText)
    #   .to({alpha: 1}, 4000, Phaser.Easing.Linear.None)
    #   .to({alpha: 0}, 1000, Phaser.Easing.Linear.None)
    #   .to({alpha: 0}, 25000, Phaser.Easing.Linear.None)
    #   .to({alpha: 1}, 1000, Phaser.Easing.Linear.None)
    #   .loop().start()

    huds = [deathText, numPlayersText, timeText, playText]

  socket = io.connect('/game')

  updateNumPlayers = (num) ->
    numPlayers = num
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

      game.world.add(text) for text in huds


  broadphaseFilter = (body1, body2) ->
    [hasPlayer, sprite] =
      if body1?.sprite?.player
        [true, body2?.sprite]
      else if body2.sprite?.player
        [true, body1?.sprite]
      else
        [false, null]

    if hasPlayer
      if sprite instanceof Spike
        player.hitSpike(sprite)
        return false
      if sprite instanceof Baddie
        player.hitBaddie(sprite)
        sprite.hitPlayer(player)
        return false
      if sprite is game.level.exit
        hitExit()
        return false
      else
        return true
    else
      return true

  hitExit = () ->
    if not level.finished
      level.finished = true
      nextLevel = level.num + 1
      if game.cache.getTilemapData("level#{nextLevel}") is undefined
        doWin()
      else
        game.sound.play('crowd_applause')
        game.sound.play('Pickup_Coin')
        Overlay.text("Level #{nextLevel}")
        setTimeout(() ->
          loadLevel(nextLevel)
        , 1000)

  doWin = () ->
    sound = game.sound.play('final_fantasy', 0.4)
    Overlay.text("""
    <br><br><br><br><br>
    Congratulations!
    <br><br><br><br><br>
    You and #{numPlayers - 1} others have successfully navigated through the treacherous depths of partyquest!
    <br><br><br><br><br>
    By Xiaohan Zhang
    <br><br><br><br><br>
    Art from phaser.io, Pixel Prospector, Meena Vempathy, and gamedev.net
    <br><br><br><br><br>
    Ending song - Final Fantasy VII - Victory Fanfare (don't sue me!)
    <br><br><br><br><br>
    Hope you enjoyed :)
    <br> Game will reset in <span class='resetGame'>80</span> seconds.
      <br><br><br><br>
    """, 0)
    timeLeft = 52
    interval = setInterval((() ->
      timeLeft -= 1
      $(".resetGame").text(timeLeft)
      if timeLeft is 0
        sound.stop()
        loadLevel(1)
        Overlay.hide()
        clearInterval(interval)
    ), 1000)

  preload = ->
    game.load.onFileComplete.add((percent, title, completed, numComplete, total) ->
      Overlay.text("#{title} - #{percent}% (#{numComplete}/#{total})", 0)
    )
    game.load.onFileError.add(() -> console.log("error loading", arguments, "("+game.load.progress+")"))

    level = new Level(game, 0)
    level.preload()
    game.level = level

    player = new Player(game)
    player.preload()
    game.player = player

    game.load.spritesheet('baddie', 'images/baddie.png', 32, 32)
    game.load.spritesheet('explosion', 'images/explosion.png', 64, 64)
    game.load.spritesheet('button', 'images/button.png', 32, 32)
    game.load.spritesheet('fence', 'images/fence.png', 32, 32)
    game.load.image('explosion_residue', 'images/explosion_residue.png')

    game.load.audio('applause_long', 'audio/applause_long.mp3')
    game.load.audio('final_fantasy', 'audio/final_fantasy.mp3')
    game.load.audio('pickup-coin', 'audio/Pickup_Coin.wav')
    game.load.audio('pig_grunt', 'audio/pig_grunt.mp3')
    game.load.audio('pig_squeal', 'audio/pig_squeal.mp3')
    game.load.audio('drum_tom', 'audio/drum_tom.mp3')
    game.load.audio('crowd_applause', 'audio/crowd_applause.mp3')
    game.load.audio('explosion_audio', 'audio/explosion.mp3')
    game.load.audio('button_click', 'audio/button_click.mp3')
    game.load.audio('button_release', 'audio/button_release.mp3')
    game.load.audio('spike_hit_wall', 'audio/spike_hit_wall.mp3')
    # game.load.audio('saw', 'audio/saw.mp3')


  create = ->
    game.antialias = false
    game.stage.disableVisibilityChange = true
    game.paused = false

    # press 1-9 to quickly go to level 1-9
    for i in [1..9]
      ((i) ->
        key = game.input.keyboard.addKey(48 + i) # 48 == keyCode for 0, 49 == keyCode for 1, etc.
        key.onDown.add(() -> 
          loadLevel(i)
        )
      )(i)

    game.physics.startSystem(Phaser.Physics.P2JS)
    game.physics.p2.setImpactEvents(true)
    game.physics.p2.defaultRestitution = 5.0
    game.physics.p2.setPostBroadphaseCallback(broadphaseFilter, this)

    createHud()

    # the level must be created before the player
    # Overlay.text("Level 1")
    Overlay.hideImmediately()
    loadLevel(1)

    player.create()

    # game.physics.p2.updateBoundsCollisionGroup()

    socket.on('players', updateNumPlayers)

  update = ->
    level.update()
    game.camera.follow(player.sprite)

  game = new Phaser.Game(window.innerWidth, window.innerHeight, Phaser.AUTO, "viewport",
    preload: preload
    create: create
    update: update
  )
  game.socket = socket

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
