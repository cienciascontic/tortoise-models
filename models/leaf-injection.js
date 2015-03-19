(function() {
  var turtleLayer = document.getElementsByClassName('turtle-view')[0];
  turtleLayer.style.zIndex = 2;
  document.getElementsByClassName('spotlight-view')[0].style.zIndex = 3;

  var aspenLeaf = document.createElement('img');
  aspenLeaf.src = 'aspenleaftrans.png';
  aspenLeaf.style.position = "absolute";
  aspenLeaf.style.top = 0;
  aspenLeaf.style.left = "" + Math.round((turtleLayer.offsetWidth - 245)/2) + "px";
  aspenLeaf.style.height = "100%";
  aspenLeaf.style.zIndex = 1;
  document.getElementsByClassName('view-layers')[0].appendChild(aspenLeaf);

})();
