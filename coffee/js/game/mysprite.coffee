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
      @body.damping = 1 - (1e-12)

      setTimeout(@initialize, 0) if @initialize

    reset: (x, y, health) =>
      if arguments.length is 0
        x = @_originalX
        y = @_originalY
      # debugger
      super(x, y, health)
      @initialize() if @initialize
      this

    preUpdate: () =>
      super()

      # # set slipperiness of my body depending on the tile i'm on
      # tile = @tileUnderneathMe()
      # if tile.isIce()
      #   @body.damping = 1 - (1e-1)
      #   @body.data.lastDampingTimeStep = 0
      # else
      #   @body.damping = 1 - (1e-12)
      #   @body.data.lastDampingTimeStep = 0

    tileUnderneathMe: () =>
      @game.level.map.getTileWorldXY(@x, @y)
