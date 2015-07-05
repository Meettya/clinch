(function() {
  'use strict';
  
  var dependencies, sources, require, modules_cache = {};
  dependencies = {};

  sources = {
"JPGt0": function(exports, module, require) {
// /Users/meettya/github/clinch/example/hello_world/hello_world.coffee 

/*
This is 'Hello World!' example
 */
module.exports = {
  hello_world: function() {
    return 'Hello World!';
  }
};

}};

if(this.clinch_runtime_v2 == null) {
  throw Error("Resolve clinch runtime library version |2| first!");
}

require = this.clinch_runtime_v2.require_builder.call(this, dependencies, sources, modules_cache);

/* bundle export */
this.my_package = {
  main : require("JPGt0")
};
}).call(this);