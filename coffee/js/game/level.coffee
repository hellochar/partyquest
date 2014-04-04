define [
], () ->
  class Level
    constructor: (@game) ->
      @platforms = null

    preload: () ->
      @game.load.tilemap('level1', 'maps/lvl1.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.image('tilesheet', 'images/tilesheet.png')

    create: () ->
      @platforms = game.add.group()
      @spikes = game.add.group()

      @map = @game.add.tilemap('level1')
      @map.addTilesetImage('tilesheet')

      @map.setCollision(28)

      @worldLayer = @map.createLayer('Tile Layer 1')
      @worldLayer.resizeWorld()

    update: () ->
