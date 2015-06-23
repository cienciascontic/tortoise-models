(function() {
  var _rangeCheck = function(v, min, max) {
    return Math.max(min, Math.min(v, max));
  };

  var _hsvToRgb = function(h, s, v) {
    // Taken from http://stackoverflow.com/a/17243070
    h = h/255;
    s = s/255;
    v = v/255;
    var r, g, b, i, f, p, q, t;
    i = Math.floor(h * 6);
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);
    switch (i % 6) {
        case 0:
          r = v;
          g = t;
          b = p;
          break;
        case 1:
          r = q;
          g = v;
          b = p;
          break;
        case 2:
          r = p;
          g = v;
          b = t;
          break;
        case 3:
          r = p;
          g = q;
          b = v;
          break;
        case 4:
          r = t;
          g = p;
          b = v;
          break;
        case 5:
          r = v;
          g = p;
          b = q;
          break;
    }
    return {
        r: Math.floor(r * 255),
        g: Math.floor(g * 255),
        b: Math.floor(b * 255)
    };
  };

  procedures.myHsb = function(h, s, b) {
    h = _rangeCheck(h, 0, 255);
    s = _rangeCheck(s, 0, 255);
    b = _rangeCheck(b, 0, 255);
    var rgb = _hsvToRgb(h, s, b);
    return ListPrims.list(rgb.r, rgb.g, rgb.b);
  };

})();
