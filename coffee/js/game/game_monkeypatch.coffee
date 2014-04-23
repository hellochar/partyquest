define [
  'phaser'
], (Phaser) ->
  Phaser.Group::findByName = (name) ->
    @iterate('name', name, Phaser.Group.RETURN_CHILD)
  Phaser.Group::findInRectangle = (name) ->
    rect = this.game.level.rectangles[name]

    if rect
      matched = this.children.filter((sprite) -> sprite.getBounds().intersects(rect))
      matched
    else
      console.warn("no rectangle with name #{name}")
      []

  Phaser.Sprite::getBounds = (name) ->
    new Phaser.Rectangle(@x, @y, @width, @height)

  Phaser.Tile::isIce = () ->
    @index is 14 # 14 is the magical number for the ice tile index in spritesheet
