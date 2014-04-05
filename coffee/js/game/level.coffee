define [
], () ->
  class Level
    constructor: (@game) ->

    preload: () ->
      @game.load.tilemap('level1', 'maps/lvl1.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.image('tilesheet', 'images/tilesheet.png')
      @game.load.image('spike', 'images/spike.png')

    create: () ->

      @map = @game.add.tilemap('level1')
      @map.addTilesetImage('tilesheet')

      @map.setCollision(28)

      # hack; fix this later
      @platforms = @map.createLayer('Tile Layer 1')
      @platforms.resizeWorld()

      @spikes = game.add.group()
      @spikes.enableBody = true
      @map.createFromObjects('Spike Layer', 484, 'spike', undefined, undefined, undefined, @spikes)

    update: () =>
      @spikes.forEach(@game.drag, null)
