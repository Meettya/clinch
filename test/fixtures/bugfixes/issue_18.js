/*
Some libs use this definition for universality
*/

if (typeof exports !== 'undefined') {
  if (typeof module !== 'undefined' && module.exports) {
    // we are want to see this functionality
    exports = module.exports = 'module';
  }
  exports.TESTED = 'exports';
} else {
  root.TESTED = 'root';
}


