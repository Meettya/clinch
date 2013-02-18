var my_package = (function() {
'use strict';
return function(cb) {
  var dependencies, entry_point, name_resolver, require, sources, __slice = [].slice;

  name_resolver = function(parent, name) {
    console.log('parent', parent);
    console.log('name', name);

    var absolute, relative, resolved_names, _i, _len, _ref, _ref1;
    resolved_names = [];
    _ref = dependencies[parent];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      _ref1 = _ref[_i], absolute = _ref1.absolute, relative = _ref1.relative;
      if (relative.indexOf(name) !== -1 || absolute.indexOf(name) !== -1) {
        resolved_names.push(absolute);
      }
    }
    switch (resolved_names.length) {
      case 1:
        return resolved_names[0];
      case 0:
        throw Error("no one module resolved name - |" + name + "| parent - |" + this.parent + "|");
        break;
      default:
        throw Error("more than one module resolved name - |" + name + "| parent - |" + this.parent + "| modules resolved - |" + resolved_names + "|");
    }
  };
  require = function(name) {
    var exports, module, module_source, resolved_name, _ref, _ref1;
    if (this != null && this.__minimalist_module_parent != null) {
      resolved_name = name_resolver(this.__minimalist_module_parent, name);
    }
    else {
      resolved_name = name
    }
    if (!(module_source = (_ref = sources[name]) != null ? _ref : sources[resolved_name])) {
      throw Error("can`t - resolve module at all: original_name - |" + name + "| resolved_name - |" + resolved_name + "|");
    }
    module_source(exports = {}, module = {}, function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return require.apply({
        __minimalist_module_parent: resolved_name
      }, args);
    });
    return (_ref1 = module.exports) != null ? _ref1 : exports;
  };
    entry_point = "/Users/meettya/github/browserpacker/test/fixtures/default/summator.coffee"
    dependencies = {"/Users/meettya/github/browserpacker/test/fixtures/default/summator.coffee":[{"absolute":"/Users/meettya/github/browserpacker/test/fixtures/default/sub_dir/multiplier.coffee","relative":"./sub_dir/multiplier.coffee"}],"/Users/meettya/github/browserpacker/test/fixtures/default/sub_dir/multiplier.coffee":[{"absolute":"/Users/meettya/github/browserpacker/test/fixtures/default/substractor.js","relative":"./../substractor.js"}]}
    sources = {
"/Users/meettya/github/browserpacker/test/fixtures/default/summator.coffee": function(exports, module, require) {(function() {
  var multiplier;

  multiplier = require('./sub_dir/multiplier').multiplier;

  module.exports = {
    summator: function(a, b) {
      return a + b;
    },
    summ_a_b_and_multiply_by_3: function(a, b) {
      return multiplier(this.summator(a, b), 3);
    }
    /*
      sum_multiply_and_substracted_2_multipli : (a,b) ->
        summator multiplier(a,b), multiply_and_substract_2(a,b)
    */

  };

}).call(this);
}, "/Users/meettya/github/browserpacker/test/fixtures/default/sub_dir/multiplier.coffee": function(exports, module, require) {(function() {
  var substractor;

  substractor = require('../substractor').substractor;

  module.exports = {
    multiplier: function(a, b) {
      return a * b;
    }
  };

}).call(this);
}, "/Users/meettya/github/browserpacker/test/fixtures/default/substractor.js": function(exports, module, require) {/* simple module */

(function() {

  module.exports = {
    substractor: function(a, b) {
      return a - b;
    }
  };

}).call(this);

/*
CS

module.exports = 
  substractor : (a, b) -> a - b

*/}}
  try {
    return cb(null, require(entry_point));
  } catch (error) {
    return cb(error, null);
  }
};

}).call(this);

console.log('before');

my_package(function(err, obj) {
    if (err) {
      return console.log(err);
    }
  console.log(obj.summator(10, 2));
});



console.log('after');