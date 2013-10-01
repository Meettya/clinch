clinch_runtime_v2 = (function(exports){
/*!
 * Clinch - runtime lib
 * version 2
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

  internal_require_builder = function(sources, name_resolver, modules_cache){
    var require, resolve_code;

    require = function (name, parent) {
      var module_source, resolved_name;
      if (!(module_source = sources[name])) {
        resolved_name = name_resolver(parent, name);
        if (!(module_source = sources[resolved_name])) {
          throw Error("can`t find module source code: original_name - |" + name + "|, resolved_name - |" + resolved_name + "|");
        }
      }
      resolved_name = resolved_name != null ? resolved_name : name;
      if (modules_cache != null) {
        if (modules_cache[resolved_name] != null) {
          return modules_cache[resolved_name];
        }
        else {
          return modules_cache[resolved_name] = resolve_code(module_source, resolved_name);
        }
      }
      else {
        return resolve_code(module_source, resolved_name);
      }
    };

    resolve_code = function (module_source, resolved_name) {
      var exports, module, _ref;
      module_source.call(_this,exports = {}, module = {}, function(mod_name) {
        return require(mod_name, resolved_name);
      });
      return (_ref = module.exports) != null ? _ref : exports;
    };

    return require;
  };

  // not require itself but builder
  exports.require_builder = function(dependencies, sources, modules_cache){
    return internal_require_builder(sources, name_resolver_builder(dependencies), modules_cache);
  };

  return exports;

})({});