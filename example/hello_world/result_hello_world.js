var my_package = (function() {
    'use strict';
    
var dependencies, name_resolver, require, sources;

name_resolver = function(parent, name) {
  if (dependencies[parent] == null) {
    throw Error("no dependencies list for parent |" + parent + "|");
  }
  if (dependencies[parent][name] == null) {
    throw Error("no one module resolved, name - |" + name + "|, parent - |" + parent + "|");
  }
  return dependencies[parent][name];
};
require = function(name) {
  var exports, module, module_source, resolved_name, _ref;
  if (!(module_source = sources[name])) {
    resolved_name = name_resolver(this.__clinch_module_parent, name);
    if (!(module_source = sources[resolved_name])) {
      throw Error("can`t find module source code: original_name - |" + name + "|, resolved_name - |" + resolved_name + "|");
    }
  }
  module_source(exports = {}, module = {}, function(mod_name) {
    return require.call({
      __clinch_module_parent: resolved_name != null ? resolved_name : name
    }, mod_name);
  });
  return (_ref = module.exports) != null ? _ref : exports;
};
    dependencies = {};
    sources = {
"2377150448": function(exports, module, require) {/*
This is 'Hello World!' example
*/

module.exports = {
  hello_world: function() {
    return 'Hello World!';
  }
};
}};
return {
"main": require(2377150448)};
}).call(this);