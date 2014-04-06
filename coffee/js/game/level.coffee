define [
  'phaser'
], (Phaser) ->
  class Level
    constructor: (@game) ->

    preload: () ->
      @game.load.tilemap('level1', 'maps/lvl1.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.image('tilesheet', 'images/tilesheet.png')
      @game.load.image('spike', 'images/spike.png')
      @game.load.image('box', 'images/box.png')
      @game.load.image('exit', 'images/exit.png')

    create: () ->

      @map = @game.add.tilemap('level1')
      @map.addTilesetImage('tilesheet')

      @map.setCollision(28)

      # hack; fix this later
      @platforms = @map.createLayer('Tile Layer 1')
      @platforms.resizeWorld()

      @spikes = game.add.group()
      @spikes.enableBody = true
      @map.createFromObjects('Spike Layer', 485, 'spike', undefined, undefined, undefined, @spikes)
      @spikes.forEach(((spike) -> spike.body.y -= 32), null)

      @boxes = game.add.group()
      @boxes.enableBody = true
      @map.createFromObjects('Box Layer', 486, 'box', undefined, undefined, undefined, @boxes)
      @boxes.forEach(((sprite) -> sprite.body.y -= 32), null)



      @spawnLocation = new Phaser.Point(@map.collision.Spawn[0].x, @map.collision.Spawn[0].y)

      @exit = game.add.sprite(@map.objects.Exit[0].x, @map.objects.Exit[0].y, 'exit')
      @game.physics.arcade.enable(@exit)
      @exit.body.y -= @exit.body.height

    update: () =>
      @spikes.forEach(@game.drag, null)
      @boxes.forEach(@game.drag, null)
