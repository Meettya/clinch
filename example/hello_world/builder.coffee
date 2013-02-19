#!/usr/bin/env coffee

###
This is builder pack CommonJS module to browser env
###

vm = require 'vm'
assert = require 'assert'
util = require 'util'

Clinch = require '../../' # it will be 'clinch' in your code

pack_config = 
  bundle : 
    main : "#{__dirname}/hello_world"

packer = new Clinch()

packer.buldPackage 'my_package', pack_config, (err, data) ->
  if err
    console.log 'Builder, err: ', err
  else
    util.log 'all works!!!'
    #console.log 'Builder, data: \n', data

    vm.runInNewContext data, sandbox = {}

    {hello_world} = sandbox.my_package.main
    assert.deepEqual hello_world(), 'Hello World!', 'Somthing wrong with code!!!'

