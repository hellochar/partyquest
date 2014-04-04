define [
], () ->
  class Level
    constructor: (@game) ->

    preload: () ->
      @game.load.tilemap('level1', 'maps/lvl1.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.image('tilesheet', 'images/tilesheet.png')

    create: () ->
      @map = @game.add.tilemap('level1')
      @map.addTilesetImage('tilesheet')

      @worldLayer = @map.createLayer('Tile Layer 1')
      @worldLayer.resizeWorld()

    update: () ->
