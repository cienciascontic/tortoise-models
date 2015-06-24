
procedures.myHideSpeedSlider = function() {
  var elems = document.getElementsByClassName('netlogo-speed-slider'), i;

  for (i = 0; i < elems.length; i++) {
    elems[i].style.visibility = 'hidden';
  }
};
procedures['MY-HIDE-SPEED-SLIDER'] = procedures.myHideSpeedSlider;
