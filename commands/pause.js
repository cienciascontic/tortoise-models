// This overrides a function in the model.
function pause(time) {
  var start = new Date().getTime(),
      expire = start + (time*500);

  while (new Date().getTime() < expire) { }
  return;
}
