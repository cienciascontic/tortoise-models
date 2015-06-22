
procedures.pause = function(time) {
  var start = new Date().getTime(),
      expire = start + (time*500);

  while (new Date().getTime() < expire) { }
  return;
};
procedures.PAUSE = procedures.pause;
