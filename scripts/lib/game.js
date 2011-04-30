(function(window, document, $, undefined) {
  
  window.Keyboard = {
    LEFT_ARROW: 37,
    UP_ARROW: 38,
    RIGHT_ARROW: 39,
    DOWN_ARROW: 40
  };
  
  window.Game = (function() {
    var canvas;
    var ctx;
    var images = {};
    var ready = false;
    var curKeyHandler;
    var playerPos = {x: 0, y: 0};
    
    var keyHandlers = {}
    keyHandlers[Keyboard.LEFT_ARROW]  = function() { playerPos.x-- }
    keyHandlers[Keyboard.RIGHT_ARROW] = function() { playerPos.x++ }
    keyHandlers[Keyboard.UP_ARROW]    = function() { playerPos.y-- }
    keyHandlers[Keyboard.DOWN_ARROW]  = function() { playerPos.y++ }
    
    return {
      tickInterval: 30,
      tileSize: 32,
      width: 24,  // in # of tiles; must be a multiple of 2
      height: 16, // in # of tiles; must be a multiple of 2

      imagePath: "images",
      
      imageNames: ["grass", "player"],
      
      init: function() {
        var self = this;
        
        playerPos.x = self.width / 2;
        playerPos.y = self.height / 2;

        canvas = document.createElement("canvas");
        ctx = canvas.getContext("2d");
        canvas.width = self.tileSize * self.width;
        canvas.height = self.tileSize * self.height;
        document.body.appendChild(canvas);

        ready = false;
        self._preloadImages();
        
        bean.add(document, 'keydown', function(event) {
          var keyCode = event.keyCode;
          if (typeof keyHandlers[keyCode] != "undefined") {
            if (!curKeyHandler) curKeyHandler = keyHandlers[keyCode];
            event.preventDefault();
          }
        });
      },

      run: function() {
        var self = this;
        setInterval(function() { self._redraw() }, self.tickInterval);
      },

      _preloadImages: function() {
        var self = this;
        for (var i=0; i<self.imageNames.length; i++) {
          (function(i) {
            var name = self.imageNames[i];
            var image = new Image(self.tileSize, self.tileSize);
            image.src = self.imagePath + "/" + name + ".gif";
            image.onload = function() {
              if (i == self.imageNames.length-1) ready = true;
            }
            images[name] = image;
          })(i)
        }
      },

      _redraw: function() {
        var self = this;
        if (!ready) return;

        // Draw background
        for (var i=0; i<self.width; i++) {
          for (var j=0; j<self.height; j++) {
            self._drawSprite("grass", i, j);
          }
        }

        // Draw player
        self._drawSprite("player", playerPos.x, playerPos.y);
        
        if (curKeyHandler) {
          curKeyHandler();
          curKeyHandler = null;
        }
      },
      
      _drawSprite: function(name, x, y) {
        var self = this;
        ctx.drawImage(images[name], x*self.tileSize, y*self.tileSize);
      }
    }
  })();

  $(function() {
    Game.init();
    Game.run();
  })
  
})(window, window.document, window.$);