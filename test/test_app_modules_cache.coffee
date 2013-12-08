###
Test suite for node only
Was tested main app itself
###

fs = require 'fs'
vm = require 'vm'

fixtureRoot  = __dirname + "/fixtures"
fixtureDefault = fixtureRoot + '/default'
fixturesUniqueGeneratorParent = fixtureDefault + '/unique_generator_parent'

lib_path = GLOBAL?.lib_path || ''

# change to app, for test
Clinch = require "#{lib_path}app"

describe 'Clinch and its modules cache:', ->

  clinch_obj = package_config = null

  describe 'buildPackage() with modules cache on (by default)', ->

    beforeEach ->

      clinch_obj = new Clinch runtime : on

    it 'should build cached package', (done) ->

      # looks strange, but its just <script src='./clinch_runtime.js'></script> analog
      clinch_runtime_file = "#{__dirname}/../clinch_runtime.js"
      clinch_runtime = fs.readFileSync clinch_runtime_file, 'utf8'
      vm.runInNewContext clinch_runtime, clinch_sandbox = {}
  
      package_config = 
        package_name : 'my_package'
        bundle : 
          Runtimed : fixturesUniqueGeneratorParent
        
      res_fn = (err, code) ->
        expect(err).to.be.null

        # this is browser emulation
        vm.runInNewContext code, clinch_sandbox
        {Runtimed} = clinch_sandbox.my_package

        {generator} = Runtimed
        {generator2} = Runtimed

        expect(generator).to.deep.equal generator2
  
        done()

      clinch_obj.buildPackage package_config, res_fn  

  describe 'buildPackage() with modules cache off', ->

    it 'should not build cached package ("off" in clinch options)', (done) ->

      clinch_obj = new Clinch runtime : on, cache_modules : off

      # looks strange, but its just <script src='./clinch_runtime.js'></script> analog
      clinch_runtime_file = "#{__dirname}/../clinch_runtime.js"
      clinch_runtime = fs.readFileSync clinch_runtime_file, 'utf8'
      vm.runInNewContext clinch_runtime, clinch_sandbox = {}
  
      package_config = 
        package_name : 'my_package'
        bundle : 
          Runtimed : fixturesUniqueGeneratorParent
        
      res_fn = (err, code) ->
        expect(err).to.be.null

        # this is browser emulation
        vm.runInNewContext code, clinch_sandbox
        {Runtimed} = clinch_sandbox.my_package
        
        {generator} = Runtimed
        {generator2} = Runtimed

        expect(generator).to.not.deep.equal generator2
  
        done()

      clinch_obj.buildPackage package_config, res_fn
