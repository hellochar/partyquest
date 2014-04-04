define [
], () ->
  class DemoLevel
    constructor: (@game) ->
      @platforms = null
      @spikes = null

    preload: () =>
      game.load.image('sky', 'images/sky.png')
      game.load.image('ground', 'images/platform.png')
      game.load.image('spike', 'images/spikes.png')

    create: () =>
      game.world.setBounds(0, 0, 1500, 1900)
      game.add.tileSprite(0, 0, @game.world.width, @game.world.height, "sky")

      #  The platforms group contains the ground and the 2 ledges we can jump on
      @platforms = game.add.group()

      #  We will enable physics for any object that is created in this group
      @platforms.enableBody = true

      for i in [0...3]
        for y in [0...4]
          #  Now let's create two ledges
          ledge = @platforms.create(800 * i, 400 * y, "ground")
          ledge.smoothed = false
          ledge.body.immovable = true
          ledge = @platforms.create(-150 + 600 * i, 250 + 400 * y, "ground")
          ledge.smoothed = false
          ledge.body.immovable = true

      @spikes = game.add.group()
      @spikes.enableBody = true
      for i in [0..45]
        spike = @spikes.create(@game.rnd.realInRange(40, @game.world.width), @game.rnd.realInRange(40, @game.world.height), "spike")
        spike.body.collideWorldBounds = true
        spike.smoothed = false

    update: () =>
      @spikes.forEach(@game.drag, null)
