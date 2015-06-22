
procedures.myClearOutput = function() {
  var div = document.getElementById('output');
  if (div) {
    div.innerHTML = "";
  }
};
procedures['MY-CLEAR-OUTPUT'] = procedures.myClearOutput;
