
function myImportDrawing(src) {
  var container = document.getElementsByClassName('netlogo-view-container')[0];
  var canvas = container.getElementsByTagName('canvas')[0];
  canvas.style.zIndex = 1;

  var img = document.createElement('img');
  img.onload = function() {
    var w = this.naturalWidth,
        h = this.naturalHeight;

    if (w > h) {
      img.style.width = "100%";
      setTimeout(function() {
        img.style.top = "" + (canvas.offsetTop + Math.round((canvas.offsetHeight - img.clientHeight)/2)) + "px";
        img.style.left = 0;
      }, 1);
    } else {
      img.style.height = "100%";
      setTimeout(function() {
        img.style.top = "" + canvas.offsetTop + "px";
        img.style.left = "" + Math.round((canvas.offsetWidth - img.clientWidth)/2) + "px";
      }, 1);
    }

    img.onload = null;
  };


  img.src = src;
  img.style.position = "absolute";
  img.style.zIndex = 0;

  container.appendChild(img);

}
