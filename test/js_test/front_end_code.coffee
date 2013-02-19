#!/usr/bin/env coffee

# _ = require 'lodash'

util = require 'util'

console.log "\n"
util.log " NEW \n"



# get main fn
my_package_raw = ->

  ###
  # logger.coffee -> './logger'
  prefix = '>'
  module.exports = 
    log : (message) -> console.log "#{prefix} #{message}"

  # main.coffee -> main
  {log} = require './logger'
  module.exports = 
    hello : (name) -> log "Hello, #{name}"
  ###

  dependencies =
    '/Users/meettya/github/browserpacker/test/fixtures/default/main.coffee' :
      './capitalizer' : '/Users/meettya/github/browserpacker/test/fixtures/default/capitalizer.coffee'
      './logger' : '/Users/meettya/github/browserpacker/test/fixtures/default/logger.coffee'


  sources = 

    '/Users/meettya/github/browserpacker/test/fixtures/default/capitalizer.coffee' : (exports, module, require) ->
      module.exports = 
        up : (message) -> "#{message}".toUpperCase()

    '/Users/meettya/github/browserpacker/test/fixtures/default/logger.coffee' : (exports, module, require) ->
      prefix = '>'
      module.exports = 
        log : (message) -> console.log "#{prefix} #{message}"

    '/Users/meettya/github/browserpacker/test/fixtures/default/main.coffee' : (exports, module, require) ->
      {log} = require './logger'
      {up}  = require './capitalizer'
      module.exports = 
        hello : (name) -> log "Hello, #{up name}"

  name_resolver = (parent, name) ->

    unless dependencies[parent]? 
      return throw Error "no dependencies list for parent |#{parent}|"
    unless dependencies[parent][name]? 
      return throw Error "no one module resolved, name - |#{name}|, parent - |#{parent}|"
        
    dependencies[parent][name]
  
  here = this

  require = (name, parent) => 
    unless module_source = sources[name]
      resolved_name = name_resolver parent, name
      unless module_source = sources[resolved_name]
        throw Error "can`t find module source code: original_name - |#{name}|, resolved_name - |#{resolved_name}|"
    
    module_source exports = {}, module = {}, (mod_name) => require.call here, mod_name, resolved_name ? name
    module.exports ? exports

   main : require '/Users/meettya/github/browserpacker/test/fixtures/default/main.coffee'
  
my_package = my_package_raw()

console.log 'before'

console.log my_package

{ hello } = my_package.main

hello 'username_low'



console.log 'after'



