window.drawings = []
images = {}

window.AgentStreamController = class MyAgentStreamController extends window.AgentStreamController
  constructor: ->
    super
    window.drawings ||= []

    triggerRepaint = =>
      @repaint()

    @patchDrawer.loadImage = (src)->
      return images[src] if images[src]?
      return new Promise (resolve,reject)->
        img = new Image()
        img.addEventListener "load", ->
          images[src] = img
          resolve(img)
        , false
        img.src = src

    @patchDrawer.drawScaledImage = (src)->
      img = @loadImage(src)
      if img.then?
        img.then (img)->
          triggerRepaint()
      else
        canvas = @view.canvas
        ctx = @view.ctx
        hRatio = canvas.width  / img.width
        vRatio = canvas.height / img.height
        ratio  = Math.min hRatio, vRatio
        shiftX = (canvas.width - img.width*ratio) / 2
        shiftY = (canvas.height - img.height*ratio) / 2
        ctx.drawImage img, shiftX, shiftY, img.width * ratio, img.height * ratio

    @patchDrawer.repaintOrig = @patchDrawer.repaint
    @patchDrawer.repaint = (model)->
      ret = @repaintOrig(model)
      # inject any images
      for src in window.drawings
        @drawScaledImage src
      return ret
