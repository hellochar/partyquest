define [
  'game/baddie'
  'game/spike'
  'game/box'
  'phaser'
], (Baddie, Spike, Box, Phaser) ->
  class Level
    # @level = 1, 2, 3, etc.
    constructor: (@game, @num) ->
      @timeStarted = Date.now()

    preload: () ->
      @game.load.tilemap('level1', 'maps/lvl1.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.tilemap('level2', 'maps/lvl2.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.tilemap('level3', 'maps/lvl3.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.image('tilesheet', 'images/tilesheet.png')
      @game.load.image('spike', 'images/spike.png')
      @game.load.image('box', 'images/box.png')
      @game.load.image('exit', 'images/exit.png')

    destroy: () ->
      @game.physics.p2.clearTilemapLayerBodies(@map, @platforms)
      @map.destroy()
      @platforms.destroy()
      @spikes.destroy()
      @boxes.destroy()
      @baddies.destroy()
      @spawnLocation = undefined
      @exit.destroy()

    create: () =>

      @timeStarted = Date.now()

      @map = @game.add.tilemap("level#{@num}")
      @map.addTilesetImage('tilesheet')
      @map.setCollisionBetween(28, 28)

      @platforms = @map.createLayer('Tile Layer 1')
      @platforms.resizeWorld()
      platformBodies = @game.physics.p2.convertTilemap(@map, @platforms)
      # @platforms.collisionGroup = game.physics.p2.createCollisionGroup()
      # for body in platformBodies
      #   body.setCollisionGroup(@platforms.collisionGroup)

      createGroup = () =>
        group = game.add.group()
        # group.collisionGroup = game.physics.p2.createCollisionGroup()
        group.enableBody = true
        group.physicsBodyType = Phaser.Physics.P2JS
        group

      populateGroup = (group, layer, gid, spriteName, customClass, cb) =>
        @map.createFromObjects(layer, gid, spriteName, undefined, undefined, undefined, group, customClass, false)
        group.forEach((sprite) ->
          # sprite.body.setCollisionGroup(group.collisionGroup)
          # sprite.body.collides(commonCollisionGroups)
          cb(sprite) if cb
        )

      @spikes = createGroup()
      @boxes = createGroup()
      @baddies = createGroup()

      # commonCollisionGroups = [@spikes.collisionGroup, @boxes.collisionGroup, @baddies.collisionGroup, @platforms.collisionGroup]

      populateGroup(@spikes, 'Spike Layer', 485, 'spike', Spike)
      populateGroup(@boxes, 'Box Layer', 486, 'box', Box)
      populateGroup(@baddies, 'Baddies', 488, 'baddie', Baddie)

      @spawnLocation = new Phaser.Point(@map.collision.Spawn[0].x, @map.collision.Spawn[0].y)

      @exit = game.add.sprite(@map.objects.Exit[0].x, @map.objects.Exit[0].y, 'exit')
      @exit.x += @exit.width/2
      @exit.y += @exit.height/2
      @exit.y -= @exit.height
      @game.physics.p2.enable(@exit)
      @exit.body.motionState = 2

      @game.world.sendToBack(@platforms)

      # @game.physics.p2.updateBoundsCollisionGroup()

    update: () =>
