define [
  'phaser'
], (Phaser) ->
  Phaser.Group::findByName = (name) ->
    @iterate('name', name, Phaser.Group.RETURN_CHILD)
