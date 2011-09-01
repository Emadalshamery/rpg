game = window.game
{Keyboard, EventHelpers, Viewport, CollisionLayer, FpsReporter, Link} = game

Main = game.util.module "game.Main", EventHelpers

everySecond = (->
  df = 0
  t0 = (new Date()).getTime()
  (fn) ->
    df++
    t = (new Date()).getTime()
    dt = t - t0
    if dt >= 1000
      fn(df, dt)
      t0 = (new Date()).getTime()
      df = 0
)()

tick = ->
  # Respond to keystrokes executed during the "dead time", i.e., the time
  # between the end of the last iteration and the start of this iteration
  Keyboard.runHandlers()

  draw()

  # Increment the global counter
  Main.globalCounter = (Main.globalCounter + 1) % 10

  Main.tickTimer = window.requestAnimFrame(tick, Main.viewport.canvas.element) if Main.isTicking

draw = ->
  canvas = Main.viewport.canvas

  Main.viewport.draw()
  everySecond (df, dt) ->
    Main.fpsReporter.draw(df, dt)

  Main.player.draw(canvas)

$.extend Main,
  drawInterval: 90   # ms/frame
  tileSize: 64   # pixels

  imagesPath: "/images"

  entities: []

  debug: true

  init: ->
    unless @isInit
      @reset()

      Keyboard.init()

      # init map
      @map = {
        width:  @dim(2560, 'pixels')
        height: @dim(1600, 'pixels')
      }

      @viewport = Viewport.init(this)
      @fpsReporter = FpsReporter.init(this)
      @collisionLayer = CollisionLayer.init(this)

      @player = new Link(this, 'link2x.gif', width: 34, height: 48)
      @entities.push(@player)

      @isInit = true
    return this

  destroy: ->
    if @isInit
      @removeEvents()
      @detach()
      Keyboard.destroy()
      @viewport.destroy()
      @fpsReporter.destroy()
      @collisionLayer.destroy()
      @stopTicking()
      @stopLogging()
      @reset()
      @isInit = false
    return this

  reset: ->
    @stopTicking()
    @stopLogging()
    @globalCounter = 0
    @logQueue = {}
    @logQueueMessages = []
    return this

  addEvents: ->
    self = this

    Keyboard.addEvents()
    @_assignKeyHandlers()
    @collisionLayer.addEvents()

    @bindEvents window,
      blur: -> self.suspend()
      focus: -> self.resume()

    return this

  removeEvents: ->
    Keyboard.removeEvents()
    @collisionLayer.removeEvents()
    @unbindEvents window, 'blur', 'focus'
    return this

  attachTo: (element) ->
    @viewport.attachTo(element)
    @fpsReporter.attachTo(@viewport.$element)
    @collisionLayer.attachTo(@viewport.$element)
    return this

  detach: ->
    @viewport.detach()
    @fpsReporter.detach()
    @collisionLayer.detach()
    return this

  ready: (callback) ->
    timer = setInterval =>
      console.log "Checking to see if all entities are loaded..."
      if (
        @collisionLayer.isLoaded and
        $.v.every @entities, (entity) -> entity.isLoaded
      )
        clearInterval(timer)
        callback()
    , 100

  run: ->
    @startTicking()
    #@startLogging()

  startTicking: ->
    @isTicking = true
    @tickTimer = window.requestAnimFrame(tick, @viewport.canvas.element) unless @tickTimer
    return this

  stopTicking: ->
    @isTicking = false
    if @tickTimer
      window.cancelRequestAnimFrame(@tickTimer)
      @tickTimer = null
    return this

  startLogging: ->
    self = this
    @isLogging = true
    @keepLogging()
    return this

  stopLogging: ->
    @isLogging = false
    return this

  keepLogging: ->
    self = this
    @flushLogQueue()
    setTimeout (-> self.keepLogging()), 1000 if @isLogging

  flushLogQueue: ->
    for name in @logQueueMessages
      msgs = @logQueue[name]()
      msgs = [msgs] unless $.v.is.arr(msgs)
      console.log(msg) for msg in msgs
    @logQueue = {}
    @logQueueMessages = []

  log: (name, fn) ->
    unless @logQueue.hasOwnProperty(name)
      @logQueue[name] = fn
      @logQueueMessages.push(name)

  suspend: ->
    unless @stateBeforeSuspend
      @stateBeforeSuspend = {wasTicking: @isTicking, wasLogging: @isLogging}
      @stopTicking()
      #@stopLogging()

  resume: ->
    if @stateBeforeSuspend
      @startTicking() if @stateBeforeSuspend.wasTicking
      #@startLogging() if @stateBeforeSuspend.wasLogging
      @stateBeforeSuspend = null

  dim: (value, unit) ->
    d = {}
    switch unit
      when "tile", "tiles"
        d.tiles = value;
        d.pixels = value * @tileSize
      when "pixel", "pixels"
        d.pixels = value;
        d.tiles = value / @tileSize
    return d

  _assignKeyHandlers: ->
    self = this

    # if @debug
    #   Keyboard.addKeyHandler ->
    #     self.log "debug viewport and player on keypress", -> [
    #       "viewport: #{self.viewport.inspect()}",
    #       "player: #{self.player.inspect()}"
    #     ]

    # Keyboard.addKeyHandler ->
    #   biv = self.player.bounds.inViewport
    #   bom = self.player.bounds.onMap
    #   vbm = self.viewport.frame.boundsOnMap
    #   console.log "bounds.inViewport:         #{biv.inspect()}"
    #   console.log "bounds.onMap:              #{bom.inspect()}"
    #   console.log "viewport.bounds.onMap:     #{vbm.inspect()}"

    Keyboard.addKeyHandler 'KEY_A', 'KEY_LEFT',  'KEY_H', -> self.player.moveLeft()
    Keyboard.addKeyHandler 'KEY_D', 'KEY_RIGHT', 'KEY_L', -> self.player.moveRight()
    Keyboard.addKeyHandler 'KEY_W', 'KEY_UP',    'KEY_K', -> self.player.moveUp()
    Keyboard.addKeyHandler 'KEY_S', 'KEY_DOWN',  'KEY_J', -> self.player.moveDown()
