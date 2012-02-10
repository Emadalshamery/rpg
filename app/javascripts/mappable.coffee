game = (window.game ||= {})

meta = game.meta2

# This assumes assignable
Mappable = meta.def 'game.Mappable',
  init: (@width, @height) ->
    @_initBounds()
    @_initLastBounds()
    return this

  assignToMap: (map) ->
    @assignTo(map)
    @map = map
    # I don't like this, but it's useful for the player
    @viewport = @map.viewport
    return this

  setMapPosition: (x, y) ->
    @bounds.onMap.anchor(x, y)
    # Don't worry about setting the viewport bounds, that happens when the
    # object is drawn
    # @recalculateViewportBounds()

  recalculateViewportBounds: ->
    # XXX: Move this to the viewport?
    x1 = @bounds.onMap.x1 - @viewport.bounds.x1
    y1 = @bounds.onMap.y1 - @viewport.bounds.y1
    @bounds.inViewport.anchor(x1, y1)

  # Public: Move the viewport and map bounds of the player.
  #
  # Signatures:
  #
  # translate(axis, amount)
  #
  #   axis   - A String: 'x' or 'y'.
  #   amount - An integer by which to move the bounds in the axis.
  #
  # translate(obj)
  #
  #   obj - Object:
  #         x - An integer by which to move x1 and x2 (optional).
  #         y - An integer by which to move y1 and y2 (optional).
  #
  # Examples:
  #
  #   translateBounds('x', 20)
  #   translateBounds(x: 2, y: -9)
  #
  # Returns the self-same Viewport.
  #
  # Also see Bounds#translate.
  #
  translate: (args...) ->
    @bounds.inViewport.translate(args...)
    @bounds.onMap.translate(args...)

  # Public: Move the X- or Y- bounds of the player by specifying the position
  # of one side of the map bounds. The viewport bounds will be moved
  # accordingly.
  #
  # side  - A String name of the side of the bounds: 'x1', 'x2', 'y1', or 'y2'.
  # value - An integer. The `side` is set to the `value`, and the corresponding
  #         sides are moved accordingly.
  #
  # Returns the integer distance the bounds were moved.
  #
  # Also see Bounds#translateBySide.
  #
  translateBySide: (side, value) ->
    axis = side[0]
    distMoved = @bounds.onMap.translateBySide(side, value)
    @bounds.inViewport.translate(axis, distMoved)
    return distMoved

  inspect: ->
    JSON.stringify
      "bounds.inViewport": @bounds.inViewport.inspect(),
      "bounds.onMap": @bounds.onMap.inspect()

  debug: ->
    console.log "bounds.inViewport = #{@bounds.inViewport.inspect()}"
    console.log "bounds.OnMap = #{@bounds.onMap.inspect()}"

  _initBounds: ->
    @bounds = {}
    @_initBoundsOnMap()
    @_initBoundsInViewport()

  _initLastBounds: ->
    @lastBounds = {}
    @lastBounds.onMap = @bounds.onMap
    @lastBounds.inViewport = @bounds.inViewport

  _initBoundsOnMap: ->
    @bounds.onMap = game.Bounds.rect(0, 0, @width, @height)

  _initBoundsInViewport: ->
    @bounds.inViewport = game.Bounds.rect(0, 0, @width, @height)

game.Mappable = Mappable

window.scriptLoaded('app/mappable')
