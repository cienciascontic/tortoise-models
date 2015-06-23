// This is based on the Scala code for the NetLogo implementation.
// https://github.com/NetLogo/NetLogo/blob/5.x/src/main/org/nlogo/prim/etc/_approximatergb.java
// https://github.com/NetLogo/NetLogo/blob/5.x/src/main/org/nlogo/api/Color.scala

(function() {
  var rgbMap, RGB_Cache,
      _rangeCheck, _getClosestColorNumberByRGB, _estimateClosestColorNumberByRGB, _populateRgbMap;

  procedures.myApproximateRgb = function(r, g, b) {
    r = _rangeCheck(r);
    g = _rangeCheck(g);
    b = _rangeCheck(b);
    var num = r << 16;
    num += g << 8;
    num += b;
    num = _getClosestColorNumberByRGB(num);
    console.log("returning " + num + " for color [" + r + ", " + g + ", " + b + "]");
    return num;
  };

  _rangeCheck = function(v) {
    return Math.round(Math.max(0, Math.min(v, 255)));
  };

  _getClosestColorNumberByRGB = function(v) {
    var val = rgbMap[v];
    if (val || val === 0) {
      return val;
    }

    return _estimateClosestColorNumberByRGB(v);
  };

  _estimateClosestColorNumberByRGB = function(rgb) {
    var smallestDistance = Number.POSITIVE_INFINITY,
        closest = 0,
        key, dist;

    for (key in rgbMap) {
      if (rgbMap.hasOwnProperty(key)) {
        dist = _colorDistance(rgb, key);
        if (dist < smallestDistance) {
          smallestDistance = dist;
          closest = rgbMap[key];
        }
      }
    }
    return closest;
  };

  _colorDistance = function(rgb1, rgb2) {
    var r1 = rgb1 >> 16 & 0xff,
        g1 = rgb1 >> 8 & 0xff,
        b1 = rgb1 & 0xff,
        r2 = rgb2 >> 16 & 0xff,
        g2 = rgb2 >> 8 & 0xff,
        b2 = rgb2 & 0xff,
        rmean = r1 + r2 / 2,
        rd = r1 - r2,
        gd = g1 - g2,
        bd = b1 - b2;
    return (((512 + rmean) * rd * rd) >> 8) + 4 * gd * gd + (((767 - rmean) * bd * bd) >> 8);
  };

  _populateRGB_Cache = function() {
    var b, baseIndex, cachedNetlogoColors, colorTimesTen, g, netlogoBaseColors, r, step;

    netlogoBaseColors = [[140, 140, 140], [215, 48, 39], [241, 105, 19], [156, 109, 70], [237, 237, 47], [87, 176, 58], [42, 209, 57], [27, 158, 119], [82, 196, 196], [43, 140, 190], [50, 92, 168], [123, 78, 163], [166, 25, 105], [224, 126, 149], [0, 0, 0], [255, 255, 255]];

    RGB_Cache = (function() {
      var i, ref, results;
      results = [];
      for (colorTimesTen = i = 0; i <= 1400; colorTimesTen = ++i) {
        baseIndex = Math.floor(colorTimesTen / 100);
        ref = netlogoBaseColors[baseIndex];
        r = ref[0];
        g = ref[1];
        b = ref[2];
        step = (colorTimesTen % 100 - 50) / 50.48 + 0.012;
        if (step < 0) {
          r += Math.floor(r * step);
          g += Math.floor(g * step);
          b += Math.floor(b * step);
        } else {
          r += Math.floor((0xFF - r) * step);
          g += Math.floor((0xFF - g) * step);
          b += Math.floor((0xFF - b) * step);
        }
        results.push((r << 16) + (g << 8) + b);
      }
      return results;
    })();
  };

  _populateRgbMap = function() {
    var i = 0, c;
    rgbMap = {};
    for (i = 0; i < 1400; i++) {
      c = i/10.0;
      rgbMap[RGB_Cache[i]] = c;
    }
  };

  _populateRGB_Cache();
  _populateRgbMap();
})();
