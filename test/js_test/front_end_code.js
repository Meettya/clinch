(function() {
  var main_fn,
    __slice = [].slice;

  console.log("\n<-- NEW --->\n");

  main_fn = function(cb) {
    /*
      # logger.coffee -> './logger'
      prefix = '>'
      module.exports = 
        log : (message) -> console.log "#{prefix} #{message}"
    
      # main.coffee -> main
      {log} = require './logger'
      module.exports = 
        hello : (name) -> log "Hello, #{name}"
    */

    /*
       { '/Users/meettya/github/frankenweenie/test/fixtures/default/summator.coffee': 
          { lodash: null,
            './sub_dir/multiplier': '/Users/meettya/github/frankenweenie/test/fixtures/default/sub_dir/multiplier.coffee' },
         '/Users/meettya/github/frankenweenie/test/fixtures/default/sub_dir/multiplier.coffee': { '../substractor': '/Users/meettya/github/frankenweenie/test/fixtures/default/substractor.js' },
         '.': { '/Users/meettya/github/frankenweenie/test/fixtures/default/summator': '/Users/meettya/github/frankenweenie/test/fixtures/default/summator.coffee' } },
    */

    var dependencies, entry_point, name_resolver, require, sources;
    entry_point = '/Users/meettya/github/browserpacker/test/fixtures/default/main';
    dependencies = {
      '.': {
        '/Users/meettya/github/browserpacker/test/fixtures/default/main': '/Users/meettya/github/browserpacker/test/fixtures/default/main.coffee'
      },
      '/Users/meettya/github/browserpacker/test/fixtures/default/main.coffee': {
        './capitalizer': '/Users/meettya/github/browserpacker/test/fixtures/default/capitalizer.coffee',
        './logger': '/Users/meettya/github/browserpacker/test/fixtures/default/logger.coffee'
      }
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
      resolved_name = name_resolver(this.__frankenweenie_module_parent, name);
      if (!(module_source = sources[resolved_name])) {
        throw Error("can`t find module source code: original_name - |" + name + "|, resolved_name - |" + resolved_name + "|");
      }
      module_source(exports = {}, module = {}, function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return require.apply({
          __frankenweenie_module_parent: resolved_name
        }, args);
      });
      return (_ref = module.exports) != null ? _ref : exports;
    };
    try {
      return cb(null, require.call({
        __frankenweenie_module_parent: '.'
      }, entry_point));
    } catch (error) {
      return cb(error, null);
    }
  };

  console.log('before');

  main_fn(function(err, obj) {
    if (err) {
      throw err;
    }
    return obj.hello('username_low');
  });

  console.log('after');

}).call(this);
[Finished in 1.0s]