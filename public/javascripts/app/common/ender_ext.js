(function() {
  var enderMembers, enderStatics, _boundsCollide, _boundsFor;

  $._select('<div>');

  _boundsFor = function(offset) {
    return {
      x1: offset.left,
      x2: offset.left + offset.width,
      y1: offset.top,
      y2: offset.top + offset.height
    };
  };

  _boundsCollide = function(b1, b2) {
    var x1i, x2i, xo, y1i, y2i, yo, _ref, _ref2, _ref3, _ref4;
    x1i = (b2.x1 < (_ref = b1.x1) && _ref < b2.x2);
    x2i = (b2.x1 < (_ref2 = b1.x2) && _ref2 < b2.x2);
    xo = b1.x1 <= b2.x1 && b1.x2 >= b2.x2;
    y1i = (b2.y1 < (_ref3 = b1.y1) && _ref3 < b2.y2);
    y2i = (b2.y1 < (_ref4 = b1.y2) && _ref4 < b2.y2);
    yo = b1.y1 <= b2.y1 && b1.y2 >= b2.y2;
    return (x1i || x2i || xo) && (y1i || y2i || yo);
  };

  enderStatics = {
    includes: function(arr, item) {
      return ~arr.indexOf(item);
    }
  };

  $.ender(enderStatics);

  enderMembers = {
    collidesWith: function($element) {
      var eo, to;
      to = this.offset();
      eo = $element.offset();
      return _boundsCollide(to, eo);
    },
    removeClassesLike: function(regex) {
      var classNames;
      classNames = (this[0].className || "").split(" ");
      classNames = $.v.reject(classNames, function(name) {
        return regex.test(name);
      });
      this[0].className = classNames.join(" ");
      return this;
    },
    removeAllClasses: function() {},
    moveBy: function(args) {
      var x, y;
      x = parseInt(this.css('left'), 10) + (args.x || 0);
      y = parseInt(this.css('top'), 10) + (args.y || 0);
      return this.css('left', "" + x + "px").css('top', "" + y + "px");
    },
    moveTo: function(x, y) {
      return this.css('left', "" + x + "px").css('top', "" + y + "px");
    },
    contains: function(elem) {
      if (elem instanceof Array) elem = elem[0];
      this.each(function() {
        if (this === elem) return true;
      });
      return false;
    },
    clone: function() {
      var clone;
      clone = this[0].cloneNode(true);
      clone.removeAttribute('data-node-uid');
      return $(clone);
    }
  };

  $.ender(enderMembers, true);

}).call(this);
