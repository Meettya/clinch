clinch_runtime = (function(exports){
/*!
 * Clinch - runtime lib
 * Copyright(c) 2013 Dmitrii Karpich <meettya@gmail.com>
 * MIT Licensed
 */

  var name_resolver_builder, internal_require_builder, _this = this;

  name_resolver_builder = function(dependencies){
    return function(parent, name) {
      if (dependencies[parent] == null) {
        throw Error("no dependencies list for parent |" + parent + "|");
      }
      if (dependencies[parent][name] == null) {
        throw Error("no one module resolved, name - |" + name + "|, parent - |" + parent + "|");
      }
      return dependencies[parent][name];
    };
  };

  internal_require_builder = function(sources, name_resolver){
    return function require(name, parent) {
      var exports, module, module_source, resolved_name, _ref;
      if (!(module_source = sources[name])) {
        resolved_name = name_resolver(parent, name);
        if (!(module_source = sources[resolved_name])) {
          throw Error("can`t find module source code: original_name - |" + name + "|, resolved_name - |" + resolved_name + "|");
        }
      }
      module_source.call(_this,exports = {}, module = {}, function(mod_name) {
        return require(mod_name, resolved_name != null ? resolved_name : name);
      });
      return (_ref = module.exports) != null ? _ref : exports;
    };
  };

  // not require itself but builder
  exports.require_builder = function(dependencies, sources){
    return internal_require_builder(sources, name_resolver_builder(dependencies));
  };

  // may be helpfully in future 
  exports.version = 1;

  return exports;

})({});