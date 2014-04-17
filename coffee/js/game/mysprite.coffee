define [
  'phaser'
], (Phaser) ->

  class MySprite extends Phaser.Sprite
    constructor: (game, x, y, key, frame) ->
      super(game, x, y, key, frame)
      # p2 forces the anchor to be at the center but x/y are top-left, so move the sprite
      # such that the physics body is positioned correctly
      @x += @width/2
      @y += @height/2

      # Tiled passes the bottom-left corner in as x/y but we're expecting top-left, so shift the y accordingly (we cannot use adjustY in createFromObjects because the position of the sprite must be set before p2 physics is enabled)
      @y -= @height

      @_originalX = @x
      @_originalY = @y

      @game.physics.p2.enable(this)
      @body.fixedRotation = true
      # @body.damping = 1 - (1e-1)

      setTimeout(@initialize, 0) if @initialize

    reset: (x, y, health) =>
      if arguments.length is 0
        x = @_originalX
        y = @_originalY
      # debugger
      super(x, y, health)
      @initialize() if @initialize
      this

    getPixelVelocity: () =>
      # *getting* the velocity gives it to you in meters (aka game.world.mpx()), but you should *set* in pixel coordinates
      new Phaser.Point(@body.velocity.world.mpxi(@body.velocity.x), @body.velocity.world.mpxi(@body.velocity.y))

    getFriction: (tile) =>
      if tile.isIce() then 3 else 100

    preUpdate: () =>
      super()

      FRICTION_OFFSET = @getFriction(@tileUnderneathMe())

      vel = @getPixelVelocity()
      dVel = vel.clone().setMagnitude(-Math.min(FRICTION_OFFSET, vel.getMagnitude()))
      @body.velocity.x = vel.x + dVel.x
      @body.velocity.y = vel.y + dVel.y

      if not _.isFinite(@body.velocity.x) or
         not _.isFinite(@body.velocity.y)
        @body.velocity.x = @body.velocity.y = 0


    tileUnderneathMe: () =>
      @game.level.map.getTileWorldXY(@x, @y)
