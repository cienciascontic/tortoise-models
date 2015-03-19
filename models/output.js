// This overrides a function in the model.
function myOutputType(str) {
  var div = document.getElementById('output');
  if (div) {
    div.innerHTML += str;
  }
}

function myOutputPrint(str) {
  var div = document.getElementById('output');
  if (div) {
    div.innerHTML += str + "\n";
  }
}

function myClearOutput() {
  var div = document.getElementById('output');
  if (div) {
    div.innerHTML = "";
  }
}
