
procedures.myImportDrawing = function(src) {
  try {
    window.drawings.push(src);
  } catch(e) {
  }
};
procedures['MY-IMPORT-DRAWING'] = procedures.myImportDrawing;
