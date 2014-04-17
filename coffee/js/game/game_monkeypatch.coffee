define [
  'phaser'
], (Phaser) ->
  Phaser.Group::findByName = (name) ->
    @iterate('name', name, Phaser.Group.RETURN_CHILD)
  Phaser.Group::findInRectangle = (name) ->
    rect = this.game.level.rectangles[name]

    matched = this.children.filter((sprite) -> sprite.getBounds().intersects(rect))
    matched

  Phaser.Sprite::getBounds = (name) ->
    new Phaser.Rectangle(@x, @y, @width, @height)

  Phaser.Tile::isIce = () ->
    @index is 14 # 14 is the magical number for the ice tile index in spritesheet
