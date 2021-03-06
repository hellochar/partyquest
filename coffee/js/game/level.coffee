define [
  'game/baddie'
  'game/spike'
  'game/box'
  'game/button'
  'game/fence'
  'phaser'
], (Baddie, Spike, Box, Button, Fence, Phaser) ->

  class Level
    # @level = 1, 2, 3, etc.
    constructor: (@game, @num) ->
      @timeStarted = Date.now()
      @objectGroups = []

    preload: () ->
      @game.load.tilemap('level1', 'maps/lvl1.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.tilemap('level2', 'maps/lvl2.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.tilemap('level3', 'maps/lvl3.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.tilemap('level4', 'maps/lvl4.json', null, Phaser.Tilemap.TILED_JSON)
      # @game.load.tilemap('level5', 'maps/lvl5.json', null, Phaser.Tilemap.TILED_JSON)
      @game.load.image('tilesheet', 'images/tilesheet.png')
      @game.load.image('spike', 'images/spike.png')
      @game.load.image('box', 'images/box.png')
      @game.load.image('exit', 'images/exit.png')
      @game.load.image('halfwire', 'images/halfwire.png')
      @game.load.image('clear', 'images/clear.png')

    destroy: () ->
      @game.physics.p2.clearTilemapLayerBodies(@map, @platforms)
      @map.destroy()
      @platforms.destroy()

      @wires.destroy()

      group.destroy() for group in @objectGroups

      @spawnLocation = undefined
      @exit.destroy()
      @rectangles = null

      @game.world.removeAll(true)
      @game.physics.p2.clear()

    unfence: (rectName, type = 'fences') =>
      obj.kill() for obj in this[type].findInRectangle(rectName)

    refence: (rectName, type = 'fences') =>
      obj.revive() for obj in this[type].findInRectangle(rectName)

    callAll: (rectName, methodName, type = 'fences') =>
      obj[methodName]() for obj in this[type].findInRectangle(rectName)

    broadphaseFilter: (body1, body2) =>
      player = @game.player
      [hasPlayer, sprite] =
        if body1?.sprite?.player
          [true, body2?.sprite]
        else if body2.sprite?.player
          [true, body1?.sprite]
        else
          [false, null]

      if hasPlayer
        # game.debug.spriteBounds(sprite)
        if sprite instanceof Spike
          player.hitSpike(sprite)
          return false
        if sprite instanceof Baddie
          player.hitBaddie(sprite)
          sprite.hitPlayer(player)
          return false
        if sprite is game.level.exit
          @game.hitExit()
          return false
        if sprite?.tile?.index is 27 # magic number for glass tile
          return false
        else
          return true
      else
        return true


    create: () =>
      @game.physics.startSystem(Phaser.Physics.P2JS)
      @game.physics.p2.setImpactEvents(true)
      @game.physics.p2.defaultRestitution = 5.0
      @game.physics.p2.setPostBroadphaseCallback(@broadphaseFilter, this)

      @timeStarted = Date.now()

      @map = @game.add.tilemap("level#{@num}")
      @map.addTilesetImage('tilesheet')
      @map.setCollisionBetween(28, 30)

      @map.setLayer('Tile Layer 1')

      @platforms = @map.createLayer('Tile Layer 1')
      @platforms.resizeWorld()
      @platformBodies = @game.physics.p2.convertTilemap(@map, @platforms)

      @wires = @game.add.group()
      # @platforms.collisionGroup = game.physics.p2.createCollisionGroup()
      # for body in platformBodies
      #   body.setCollisionGroup(@platforms.collisionGroup)
      #
      WIRE_TILE = 30
      @map.forEach(((tile) ->
        if tile.index is WIRE_TILE
          neighbors = [
           {x: 0, y: 1}
           {x: 0, y: -1}
           {x: 1, y: 0}
           {x: -1, y: 0}
          ]
          tile.onElectricity = new Phaser.Signal()
          tile.onElectricity.add(_.throttle((evalStr, from) ->
            wire.activate() for wire in tile.wires
            setTimeout(() ->
              if _.isEqual(tile.neighbors, [from]) or tile.neighbors.length == 0 # we're at the end
                eval(evalStr)
              else
                neighbor.onElectricity.dispatch(evalStr, tile) for neighbor in _.without(tile.neighbors, from)
            , 20)
          , 100, trailing: false))
          tile.neighbors = [] # neighboring tiles that have wires
          tile.wires = [] # wires on this tile
          for offset in neighbors
            neighborTile = @map.getTile(tile.x + offset.x, tile.y + offset.y)
            if (not neighborTile.collides) or neighborTile.index is WIRE_TILE
              if neighborTile.index is WIRE_TILE
                tile.neighbors.push(neighborTile)
              halfwire = @game.add.image(tile.worldX + 16, tile.worldY + 16, 'halfwire')
              halfwire.anchor.set(0.5, 0.5)
              halfwire.angle = Math.atan2(offset.y, offset.x) * 180 / Math.PI
              halfwire.alpha = 0.1
              halfwire.activate = () ->
                @alpha = 1
                @game.add.tween(@).to({alpha: 0.1}, 300, Phaser.Easing.Cubic.In).start()


              @wires.add(halfwire)
              tile.wires.push(halfwire)
      ), this, 0, 0, @map.width, @map.height, 'Tile Layer 1')

      GLASS_TILE = 27
      @map.forEach((tile) ->
        if tile.index is GLASS_TILE
          sprite = @game.add.sprite(tile.worldX + 16, tile.worldY + 16, 'clear')
          @game.physics.p2.enable(sprite)
          sprite.body.fixedRotation = true
          sprite.body.motionState = Phaser.Physics.P2.Body.STATIC
          sprite.body.mass = 0
          sprite.tile = tile
      )


      @rectangles = {}
      if @map.collision.Rectangles
        for rect in @map.collision.Rectangles
          if rect.name
            @rectangles[rect.name] = new Phaser.Rectangle(rect.x, rect.y, rect.width, rect.height)
          else
            console.warn("found rectangle with no name at #{rect.x}, #{rect.y}!")

      createGroup = () =>
        group = game.add.group()
        # group.collisionGroup = game.physics.p2.createCollisionGroup()
        group.enableBody = true
        group.physicsBodyType = Phaser.Physics.P2JS
        @objectGroups.push(group)
        group

      populateGroup = (group, layer, spriteName, customClass) =>
        @map.createFromObjects(layer, undefined, spriteName, undefined, undefined, undefined, group, customClass, false)
        group.forEach((sprite) ->
          # sprite.body.setCollisionGroup(group.collisionGroup)
          # sprite.body.collides(commonCollisionGroups)
        )

      @buttons = createGroup()
      @spikes = createGroup()
      @boxes = createGroup()
      @baddies = createGroup()
      @fences = createGroup()

      # commonCollisionGroups = [@spikes.collisionGroup, @boxes.collisionGroup, @baddies.collisionGroup, @platforms.collisionGroup]

      populateGroup(@buttons, 'Buttons', 'button', Button)
      populateGroup(@spikes, 'Spike Layer', 'spike', Spike)
      populateGroup(@boxes, 'Box Layer', 'box', Box)
      populateGroup(@baddies, 'Baddies', 'baddie', Baddie)
      populateGroup(@fences, 'Fences', 'fence', Fence)

      @spawnLocation = new Phaser.Point(@map.collision.Spawn[0].x, @map.collision.Spawn[0].y)

      @exit = game.add.sprite(@map.objects.Exit[0].x, @map.objects.Exit[0].y, 'exit')
      @exit.x += @exit.width/2
      @exit.y += @exit.height/2
      @exit.y -= @exit.height
      @game.physics.p2.enable(@exit)
      @exit.body.motionState = 2

      if @map.collision.Text
        for textRect in @map.collision.Text
          props = textRect.properties
          if props.text
            fontSize = props.fontSize || 20
            style = {font: "#{fontSize}pt Arial", fill: "white", align: "left" }
            p = @game.add.text(textRect.x, textRect.y, props.text, style)


      @game.world.sendToBack(@platforms)

      @game.player.deaths = 0

      # @game.physics.p2.updateBoundsCollisionGroup()

    update: () =>
