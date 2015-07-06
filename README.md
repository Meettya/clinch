[![Join the chat at https://gitter.im/Meettya/clinch](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Meettya/clinch?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Dependency Status](https://gemnasium.com/Meettya/clinch.png)](https://gemnasium.com/Meettya/clinch)
[![Build Status](https://travis-ci.org/Meettya/clinch.png?branch=master)](https://travis-ci.org/Meettya/clinch)

# clinch

YA ComonJS to browser packer tool, well-suited for tiny widgets by small overhead and big app by module replacement, node-environment emulations and multi-exports.

In addition it rapidly compiles the first pass of packaging and has an elegant solution to caching data.

## BRAKING CHANGES

### 1.0.1

A lot of processors moved to separate modules.

It may brake you old bundler and require some changes - add used processor to dependencies, install it and declare via `.addPlugin()` - see example section.

## what in a box?

 - `.js`      - just put it to bundle as is
 - `.json`    - wrap in `module.exports` as node do it on `require('file.json')`

Yes, with version 1.0.1 box fairly empty and the default itself ** clinch ** can only work with these two types of files.

## where another processors?

All other processors moved into separate modules. At the moment, the list is as follows:

 - [clinch.coffee](https://github.com/Meettya/clinch.coffee) - `.coffee` - compile to JavaScript
 - [clinch.eco](https://github.com/Meettya/clinch.eco)    - `.eco` - precompile to JavaScript function
 - [clinch.jade](https://github.com/Meettya/clinch.jade)   - `.jade` -  precompile it in [client-mode](https://github.com/visionmedia/jade#a4) way
 - [clinch.jsx](https://github.com/Meettya/clinch.jsx)    - `.jsx` - compile [React '.jsx'](http://facebook.github.io/react/index.html) to JavaScript
 - [clinch.csbx](https://github.com/Meettya/clinch.csbx)   - `.csbx` - compile '.jsx' on Coffee with backticks to JavaScript (yes, we do it)

Separation of code done in order to provide flexibility in target versions required you to processors. Ie for example, you can continue to use the processor with a version of `.csbx` ** React ** 0.11.1 for the old project and to take for the new 0.14.1, simply prescribe the right version you react-processor ** clinch ** in your package.json project.

## what about my custom template engine?

This possibility almost exists - **clinch** from 0.2.5 have API for third party processors, but template engine must support template-to-function precompilation.

More info and example - below at description of methods `addPlugin()` and `registerProcessor()`

For additional example - see [using Handelbars](https://github.com/Meettya/clinch/wiki/Handlebars-template-engine-support) - yap, now [Hadlebars](http://handlebarsjs.com/) supported as add-on.

## installation

    npm install clinch clinch.coffee

## example

    #!/usr/bin/env coffee
    Clinch           = require 'clinch'
    clinch_coffee = require 'clinch.coffee'

    packer = new Clinch runtime : on
    # register '.coffee' processor
    packer.addPlugin clinch_coffee

    pack_config = 
      package_name : 'my_package'
      bundle : 
        main : "#{__dirname}/hello_world"
    packer.buildPackage pack_config, (err, data) ->
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

And in browser function may be accessed in this way

    hello_world = my_package.main.hello_world

## API

**clinch** have minimalistic API

### constructor

    packer = new Clinch clinch_options

`clinch_options` - Clinch settings


### buildPackage()

    packer.buildPackage package_config, cb
    # or old form, will be deprecated in new version
    packer.buildPackage package_name, package_config, cb

`package_name` - root bundle package name (like `$` for jQuery), remember about name collisions, may be omitted. Will be deprecated in new versions, use `package_config.package_name`

`package_config` - package settings

`cb` - standard callback, all in **clinch** are async

### addPlugin()

    packer.addPlugin clinch_plugin

This method allows you to connect plug-ins, in fact being a syntactic sugar to `registerProcessor ()`

`clinch_plugin` -  plugin-processor for selected files

Example:

    # declare plugin in place
    econ_plugin = 
      extension : '.econ'
      processor : (file_content, filename, cb) ->
        content = Eco.precompile file_content
        cb null, "module.exports = #{content}"

    # add .econ processor
    packer.addPlugin econ_plugin

### registerProcessor()

    packer.registerProcessor file_extention, fn

This method allow to register any file content processor, which will be used to process files with `file_extention`.

`file_extention` - file extension to proceed

`fn` - processor function

Example:

    # add .econ processor
    packer.registerProcessor '.econ', (file_content, filename, cb) ->
      content = Eco.precompile file_content
      cb null, "module.exports = #{content}"

At now **clinch** will be compile all required `.econ` files with this function.

And in module code:

    template = require './template' # ./template.econ, extension may be omitted
    res = template data # res now is some html-contented string

In fact, similar to the method `addPlugin ()`.

### flushCache()

    packer.flushCache()

This method will force flush packer cache. As usually **clinch** flush cache if files changed, but for some rare cases its available to force it.

### getPackageFilesList()

    packer.getPackageFilesList package_config, cb

This method will return an Array of all files, used in package building process.
May be used for custom `watch` implementation or in other cases

## Settings

### clinch_options
    log           : off  # will add verbose output, but now not realized yet
    strict        : on   # knob for 'use strict;' in bundle header
    inject        : on   # if changed to 'off' - bundle will not to inject 'package_name' to global
    runtime       : off  # use internal boilerplate code, or as external file
    cache_modules : on   # by default all resolved by 'require' file will be cached, if you have some problem - turn cache off and notice me

### package_config
    ###
    May be omitted. If omitted - inject all bundle members to global OR, if `inject : off` in package settings - make all bundle members local for bundle (it may be usefully in case of widgets with self-detection)
    ###
    package_name : 'bundle_pack_name'

    # bundle settings
    strict : on   # bundle knob for 'use strict;' in bundle header
    inject : on   # if changed to 'off' - bundle will not to inject 'package_name' to global
    runtime       : off  # use internal boilerplate code, or as external file
    cache_modules : on   # by default all resolved by 'require' file will be cached, if you have some problem - turn cache off and notice me


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
      lodash : -> @_  # yes, its allowed to use function instead of file (`this` will be pointed to global scoop)

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

## Acknowledgement

[Shuvalov Anton](https://github.com/shuvalov-anton)

[Simakov Konstantin](https://github.com/GigabyteTheOne)
