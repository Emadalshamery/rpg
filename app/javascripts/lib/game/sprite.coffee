game = window.game
class game.SpriteSheet
  constructor: (path, width, height) ->
    @image = new Image()
    @image.src = path
    [@width, @height] = [width, height]

class game.SpriteAnimation
  constructor: (@spriteSheet, @frequency=0, @frames) ->
    @currentFrame = 0
    @totalFrames = @frames.length
    [@width, @height] = [@spriteSheet.width, @spriteSheet.height]

  step: (x, y)->
    @currentFrame = ((@currentFrame + 1) % @totalFrames) if game.Main.globalCounter % @frequency == 0
    yOffset = @frames[@currentFrame] * @height
    game.Main.canvas.ctx.drawImage(@spriteSheet.image, 0, yOffset, @width, @height, x, y, @width, @height)

    # DEBUG
    ctx = game.Main.canvas.ctx
    ctx.beginPath()
    ctx.moveTo(x+0.5, y+0.5)
    ctx.lineTo(x+@width+0.5, y+0.5)
    ctx.lineTo(x+@width+0.5, y+@height+0.5)
    ctx.lineTo(x+0.5, y+@height+0.5)
    ctx.lineTo(x+0.5, y+0.5)
    ctx.strokeStyle = "#00ff00"
    ctx.stroke()