
function myOutputPrint(str) {
  var div = document.getElementById('output');
  if (div) {
    div.innerHTML += str + "\n";
  }
}
