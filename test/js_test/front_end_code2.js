console.log("\n<-- NEW --->\n");

// header start

var greater = (function() {
  'use strict';
  return function(cb) {
    var dependencies, entry_point, name_resolver, require, sources, __slice = [].slice;

    name_resolver = function(parent, name) {
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
          throw Error("no one module resolved\n  name - |" + name + "|\n  parent - |" + this.parent + "|");
          break;
        default:
          throw Error("more than one module resolved\n  name - |" + name + "|\n  parent - |" + this.parent + "|\n  modules resolved - |" + resolved_names + "|");
      }
    };
    require = function(name) {
      var exports, module, module_source, resolved_name, _ref, _ref1;
      if (this != null && this.__minimalist_module_parent != null) {
        resolved_name = name_resolver(this.__minimalist_module_parent, name);
      }
      if (!(module_source = (_ref = sources[name]) != null ? _ref : sources[resolved_name])) {
        throw Error("can`t resolve module at all:\n  original_name - |" + name + "|\n  resolved_name - |" + resolved_name + "|");
      }
      module_source(exports = {}, module = {}, function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return require.apply({
          __minimalist_module_parent: name
        }, args);
      });
      return (_ref1 = module.exports) != null ? _ref1 : exports;
    };

    // header end

    entry_point = '/Users/meettya/github/browserpacker/test/fixtures/default/main.coffee';
    dependencies = {
      '/Users/meettya/github/browserpacker/test/fixtures/default/main.coffee': [
        {
          "absolute": '/Users/meettya/github/browserpacker/test/fixtures/default/capitalizer.coffee',
          "relative": './capitalizer.coffee'
        }, {
          "absolute": '/Users/meettya/github/browserpacker/test/fixtures/default/logger.coffee',
          "relative": './logger.coffee'
        }
      ]
    };

    sources = {
      '/Users/meettya/github/browserpacker/test/fixtures/default/capitalizer.coffee': function(exports, module, require) {
        return module.exports = {
          up: function(message) {
            return ("" + message).toUpperCase();
          }
        };
      },
      '/Users/meettya/github/browserpacker/test/fixtures/default/logger.coffee': function(exports, module, require) {
        var prefix;
        prefix = '>';
        return module.exports = {
          log: function(message) {
            return console.log("" + prefix + " " + message);
          }
        };
      },
      '/Users/meettya/github/browserpacker/test/fixtures/default/main.coffee': function(exports, module, require) {
        var log, up;
        log = require('./logger').log;
        up = require('./capitalizer').up;
        return module.exports = {
          hello: function(name) {
            return log("Hello, " + (up(name)));
          }
        };
      }
    };

    // footer start
    try {
      return cb(null, require(entry_point));
    } catch (error) {
      return cb(error, null);
    }
  };

}).call(this);

// footer end

console.log('before');

greater(function(err, obj) {
    if (err) {
      return console.log(err);
    }
  return obj.hello('username_low');
});

console.log('after');
