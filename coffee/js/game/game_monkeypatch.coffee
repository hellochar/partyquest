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
