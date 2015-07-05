#!/usr/bin/env coffee

###
This is builder pack CommonJS module to browser env
###

vm      = require 'vm'
assert  = require 'assert'
util    = require 'util'
fs      = require 'fs'

Clinch        = require '../../' # it will be 'clinch' in your code
clinch_coffee = require 'clinch.coffee'

pack_config = 
  package_name : 'my_package'
  bundle : 
    main : "#{__dirname}/hello_world"

packer = new Clinch runtime : on
# register '.coffee' processor
packer.addPlugin clinch_coffee

packer.buildPackage pack_config, (err, data) ->
  if err
    console.log 'Builder, err: ', err
  else
    util.log 'all works!!!'
    console.log 'Builder, data: \n', data

    # looks strange, but its just <script src='./clinch_runtime.js'></script> analog
    clinch_runtime_file = "#{__dirname}/../../clinch_runtime.min.js"
    clinch_runtime = fs.readFileSync clinch_runtime_file, 'utf8'
    vm.runInNewContext clinch_runtime, sandbox = {}

    vm.runInNewContext data, sandbox

    {hello_world} = sandbox.my_package.main
    assert.deepEqual hello_world(), 'Hello World!', 'Somthing wrong with code!!!'

