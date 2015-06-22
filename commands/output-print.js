
procedures.myOutputPrint = function(str) {
  var div = document.getElementById('output');
  if (div) {
    div.innerHTML += str + "\n";
  }
};
procedures['MY-OUTPUT-PRINT'] = procedures.myOutputPrint;
