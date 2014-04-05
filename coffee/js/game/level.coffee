define [
], () ->
  class Level
    constructor: (@game) ->

    preload: () ->
      @game.load.tilemap('level1', 'maps/lvl1.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.image('tilesheet', 'images/tilesheet.png')

    create: () ->
      @spikes = game.add.group()

      @map = @game.add.tilemap('level1')
      @map.addTilesetImage('tilesheet')

      @map.setCollision(28)

      # hack; fix this later
      @platforms = @map.createLayer('Tile Layer 1')
      @platforms.resizeWorld()

    update: () ->
