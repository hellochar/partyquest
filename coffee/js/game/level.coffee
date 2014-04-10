define [
  'game/baddie'
  'game/spike'
  'phaser'
], (Baddie, Spike, Phaser) ->
  class Level
    # @level = 1, 2, 3, etc.
    constructor: (@game, @num) ->
      @timeStarted = Date.now()

    preload: () ->
      @game.load.tilemap('level1', 'maps/lvl1.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.tilemap('level2', 'maps/lvl2.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.image('tilesheet', 'images/tilesheet.png')
      @game.load.image('spike', 'images/spike.png')
      @game.load.image('box', 'images/box.png')
      @game.load.image('exit', 'images/exit.png')

    destroy: () ->
      @map.destroy()
      @platforms.destroy()
      @spikes.destroy()
      @boxes.destroy()
      @baddies.destroy()
      @spawnLocation = undefined
      @exit.destroy()

    create: () ->

      @timeStarted = Date.now()

      @map = @game.add.tilemap("level#{@num}")
      @map.addTilesetImage('tilesheet')

      @map.setCollision(28)

      @platforms = @map.createLayer('Tile Layer 1')
      @platforms.resizeWorld()

      @spikes = game.add.group()
      @spikes.enableBody = true
      @map.createFromObjects('Spike Layer', 485, 'spike', undefined, undefined, undefined, @spikes, Spike)

      @boxes = game.add.group()
      @boxes.enableBody = true
      @map.createFromObjects('Box Layer', 486, 'box', undefined, undefined, undefined, @boxes)
      @boxes.forEach(((sprite) -> sprite.body.y -= 32), null)

      @baddies = game.add.group()
      @baddies.enableBody = true
      @map.createFromObjects('Baddies', 488, 'baddie', undefined, undefined, undefined, @baddies, Baddie)
      @baddies.forEach((baddie) ->
        baddie.anchor.set(0.5)
      )

      @spawnLocation = new Phaser.Point(@map.collision.Spawn[0].x, @map.collision.Spawn[0].y)

      @exit = game.add.sprite(@map.objects.Exit[0].x, @map.objects.Exit[0].y, 'exit')
      @exit.anchor.setTo(0, 1)
      @game.physics.arcade.enable(@exit)

      @game.world.sendToBack(@platforms)

    update: () =>
      @boxes.forEach(@game.drag, null)
      # @baddies.forEach(@game.debug.body, @game.debug)

      # baddie
      game.physics.arcade.collide(@baddies, @platforms)
      game.physics.arcade.collide(@baddies, @spikes)
      game.physics.arcade.collide(@baddies, @boxes)
      game.physics.arcade.collide(@baddies)

      # boxes
      game.physics.arcade.collide(@boxes)
      game.physics.arcade.collide(@spikes, @boxes)
      game.physics.arcade.collide(@boxes, @platforms)

      #spikes
      game.physics.arcade.collide(@spikes)
      game.physics.arcade.collide(@spikes, @platforms)

