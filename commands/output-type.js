
procedures.myOutputType = function(str) {
  var div = document.getElementById('output');
  if (div) {
    div.innerHTML += str;
  }
};
procedures['MY-OUTPUT-TYPE'] = procedures.myOutputType;
