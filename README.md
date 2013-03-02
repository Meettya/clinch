
# clinch

YA ComonJS to browser packer tool, well-suited for tiny widgets by small overhead and big app by module replacement, node-environment emulations and multi-exports.

## installation

    npm install clinch

## example

    #!/usr/bin/env coffee
    Clinch = require 'clinch'
    packer = new Clinch()
    pack_config = 
      bundle : 
        main : "#{__dirname}/hello_world"
    packer.buldPackage 'my_package', pack_config, (err, data) ->
      if err
        console.log 'Builder, err: ', err
      else
        console.log 'Builder, data: \n', data

Content of `./hellow_world`

    ###
    This is 'Hello World!' example
    ###
    module.exports = 
      hello_world : -> 'Hello World!'

Now `data` contain something like this

    (function() {
        'use strict';
        
    <... skip clinch header ...>

        dependencies = {};
        sources = {
    "2377150448": function(exports, module, require) {
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
    this.my_package = {
    "main": require(2377150448)};
    }).call(this);

And in browser function may be accessed in this way

    hello_world = my_package.main.hello_world

## API & settings

**clinch** have minimalistic API

    packer.buldPackage package_name, package_config, cb

`package_name` - root bundle package name (like `$` for jQuery), remember about name collisions.

`package_config` - package settings

`cb` - standard callback, all in **clinch** are async

### package_config

    ###
    At least one key must be exists
    name -> code place
    this keys was be exported when script loaded
    bundle = 
      main   : function(){...}
      helper : function(){...}

    later in code

      main = bundle.main
    ###

    bundle :
      main : './src'
      helper : './src/lib/helper'

    ###
    This is local for code variables, to imitate node.js environment,
    or replace somthing
    Important - keys will be used as variable name, so any strange things may happened
    if it not old plain string, remember it!!!
    ###
    environment :
      process : './node/js-process'
      console : './node_modules/console-shim'

    ###
    This part replace modules with browser-spec one
    ###
    replacement :
      util : './node_modules/js-util'

    ###
    this is list of modules, which is not be placed in bungle
    ###
    exclude : [
      'underscore'
    ]

    ###
    This is list of modules, which we are not check for require in it
    save time with huge pre-bulded libraries, like `lodash` or `jquery`
    if we are decide to place it in bundle
    ###
    requireless : [
      'lodash'
    ]

## Examples

See `example` or `test` dirs.

Also some examples will be available online at [clinch_demo](http://meettya.github.com/clinch_demo/index.html).

Also **clinch** will be used to browser-pack [TinyData](http://meettya.github.com/TinyData/demo.html), see sources and [packed lib](https://github.com/Meettya/TinyData/blob/master/lib_browser/tinydata.js)

## See also

Its exists README_ru version of documentation, with more information.
