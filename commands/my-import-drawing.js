
procedures.myImportDrawing = function(src) {
  try {
    window.drawings.push(src);
  } catch(e) {
    if (typeof(console) !== 'undefined' && console && console.log) {
      console.log("Error adding src for myImportDrawing", src, e);
    }
  }
};
procedures['MY-IMPORT-DRAWING'] = procedures.myImportDrawing;
