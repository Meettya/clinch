###
Test suite for node only
Was tested main app itself
###

fs = require 'fs'
vm = require 'vm'

fixtureRoot  = __dirname + "/fixtures"
fixturesJade = fixtureRoot + '/jade_powered'
fixturesEcon = fixtureRoot + '/econ_powered'
fixturesHandlebars = fixtureRoot + '/handlebars_powered'
fixturesWebShims = fixtureRoot + '/web_modules'
fixtureDefault = fixtureRoot + '/default'
fixturesUniqueGeneratorParent = fixtureDefault + '/unique_generator_parent'
fixturesSingle = fixtureDefault + '/substractor'
fixturesFaled = fixtureRoot + "/with_syntax_error"
fixturesFiledScbx = fixturesFaled + '/misstype_parent'


lib_path = GLOBAL?.lib_path || ''

# change to app, for test
Clinch = require "#{lib_path}app"

# our external plugins
clinch_jade   = require 'clinch.jade'
clinch_jsx    = require 'clinch.jsx'
clinch_csbx   = require 'clinch.csbx'
clinch_coffee = require 'clinch.coffee'

# for third party processor check
Eco = require 'eco'
Handlebars = require 'handlebars'

describe 'Clinch app itself:', ->

  clinch_obj = package_config = null

  beforeEach ->

    clinch_obj = new Clinch strict : off
    clinch_obj.addPlugin clinch_jade pretty : off
              .addPlugin clinch_jsx
              .addPlugin clinch_csbx
              .addPlugin clinch_coffee


  describe 'buildPackage()', ->

    it 'should build package', (done) ->

      jade_expected = """
                      <div class="message"><p>Hello Bender!!!</p></div>
                      """


       # looks strange, but its just <script src='./runtime.js'></script> analog
      jade_runtime_file = "#{__dirname}/../node_modules/jade/runtime.js"
      jade_runtime = fs.readFileSync jade_runtime_file, 'utf8'

      vm.runInNewContext jade_runtime, jade_sandbox = window : {}
      # looks starnge, but its ok for browser
      jade_sandbox.jade = jade_sandbox.window.jade

      ###
      so, we are should to stub 'fs' and 'jade'
      looks little ugly, but its fee for untouched sources, 
      think about it as taxes - nobody like it, but every should to pay
      ###
      package_config = 
        package_name : 'my_package'
        bundle : 
          JadePowered : fixturesJade
        replacement :
          fs : fixturesWebShims + '/noops'
          jade : fixturesWebShims + '/noops'
        
      res_fn = (err, code) ->
        expect(err).to.be.null

        # console.log code

        # this is browser emulation
        vm.runInNewContext code, jade_sandbox
        
        {JadePowered} = jade_sandbox.my_package
        
        jade_obj = new JadePowered()
        res = jade_obj.renderData name : 'Bender'
        res.should.to.be.equal jade_expected

        done()

      # here we are build our package, its what you need for browser
      clinch_obj.buildPackage package_config, res_fn


    it 'should not build package with defected sources (error should not be lossed)', (done) ->

      package_config = 
        package_name : 'my_package'
        bundle : 
          defected : fixturesFiledScbx

      res_fn = (err, code) ->
        expect(err).not.to.be.null
        #console.log err
        #console.log code
        expect(err).to.be.an.instanceOf SyntaxError 
        done()

      # here we are build our package, its what you need for browser
      clinch_obj.buildPackage package_config, res_fn


  describe 'buldPackage()', ->

    it 'should build package (mistype, but must be supported)', (done) ->

      package_config = 
        bundle : 
          substractor : fixturesSingle
        package_name : 'my_package'
 
      res_fn = (err, code) ->
        # console.log code
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        {substractor} = sandbox.my_package.substractor
        (substractor 10, 2).should.to.be.equal 8
        done()

      clinch_obj.buldPackage package_config, res_fn

  describe 'flushCache()', ->

    it 'should drop cache and return null', ->
      expect(clinch_obj.flushCache()).to.be.null

  describe 'getPackageFilesList()', ->

    it 'should return list of all files, used in package', (done) ->

      package_config = 
        bundle : 
          JadePowered : fixturesJade
        replacement :
          fs : fixturesWebShims + '/noops'
          jade : fixturesWebShims + '/noops'

      res_fn = (err, files) ->
        expect(err).to.be.null
        # console.log files
        files.should.to.have.length 3

        done()

      clinch_obj.getPackageFilesList package_config, res_fn  

  describe 'registerProcessor()', ->

    it 'should add new processor and use it', (done) -> 

      econ_expected = """
                      <div class="message"><p>Hello Bender!!!</p></div>
                      """

      package_config = 
        package_name : 'my_package'
        bundle : 
          EconPowered : fixturesEcon
        
      res_fn = (err, code) ->
        expect(err).to.be.null

        # console.log code

        # this is browser emulation
        vm.runInNewContext code, econ_sandbox = {}
        {EconPowered} = econ_sandbox.my_package
        
        econ_obj = new EconPowered()
        res = econ_obj.renderData name : 'Bender'
        res.should.to.be.equal econ_expected

        done()

      # add .econ processor
      clinch_obj.registerProcessor '.econ', (data, filename, cb) ->
        content = Eco.precompile data
        cb null, "module.exports = #{content}"

      # just for my test, don't look on it as an example
      # add .dummy processor to ensure .econ not rewritten
      clinch_obj.registerProcessor '.dummy', (data, filename, cb) ->
        content = Eco.precompile data
        cb null, "module.exports = function(){return 'Dummy'};"

      # here we are build our package, its what you need for browser
      clinch_obj.buildPackage package_config, res_fn    


    it 'should throw error if file extention not a String', ->
      expect(-> clinch_obj.registerProcessor 22 , -> ).to.throw TypeError

    it 'should throw error if processor not a Function', ->
      expect(-> clinch_obj.registerProcessor '.foo' , 'bar' ).to.throw TypeError

    it 'should support Handlebars precompilation', (done) ->

      res_expected = """
                      <div class="message"><p>Hello Bender!!!</p></div>
                      """


       # looks strange, but its just <script src='./runtime.js'></script> analog
      handlebars_runtime_file = "#{__dirname}/../node_modules/handlebars/dist/handlebars.runtime.js"
      handlebars_runtime = fs.readFileSync handlebars_runtime_file, 'utf8'
      vm.runInNewContext handlebars_runtime, handlebars_sandbox = window : {}

      ###
      so, we are should to stub 'fs' and 'handlebars'
      looks little ugly, but its fee for untouched sources, 
      think about it as taxes - nobody like it, but every should to pay
      ###
      package_config = 
        package_name : 'my_package'
        bundle : 
          HandlebarsPowered : fixturesHandlebars
        
      res_fn = (err, code) ->
        expect(err).to.be.null

        # console.log code

        # this is browser emulation
        vm.runInNewContext code, handlebars_sandbox
        {HandlebarsPowered} = handlebars_sandbox.my_package
        
        handlebars_obj = new HandlebarsPowered()
        res = handlebars_obj.renderData name : 'Bender'
        res.should.to.be.equal res_expected

        done()

      # add .handlebars processor
      clinch_obj.registerProcessor '.handlebars', (data, filename, cb) ->
        content = Handlebars.precompile data
        cb null, "module.exports = #{content}"

      # here we are build our package, its what you need for browser
      clinch_obj.buildPackage package_config, res_fn   


  describe 'constructor options', ->

    it 'should supress injection on "inject : off" ', (done) ->

      clinch_obj = new Clinch inject : off

      clinch_obj.addPlugin clinch_jade
                .addPlugin clinch_coffee

      package_config = 
        package_name : 'my_package'
        bundle : 
          JadePowered : fixturesJade
        replacement :
          fs : fixturesWebShims + '/noops'
          jade : fixturesWebShims + '/noops'
        
      res_fn = (err, code) ->
        expect(err).to.be.null
        vm.runInNewContext code, jade_sandbox = {}
        jade_sandbox.should.not.to.contain.keys 'my_package'
        done()

      clinch_obj.buildPackage package_config, res_fn  

  describe 'package options', ->

    it 'should supress "use strict" on "strict : off" ', (done) ->

      clinch_obj = new Clinch

      clinch_obj.addPlugin clinch_jade
                .addPlugin clinch_coffee

      package_config = 
        package_name : 'my_package'
        strict : off
        bundle : 
          JadePowered : fixturesJade
        replacement :
          fs : fixturesWebShims + '/noops'
          jade : fixturesWebShims + '/noops'
        
      res_fn = (err, code) ->
        expect(err).to.be.null
        expect(/'use strict';/.test code).to.be.false
        done()

      clinch_obj.buildPackage package_config, res_fn 

    it 'should supress injection on "inject : off" ', (done) ->

      clinch_obj = new Clinch

      clinch_obj.addPlugin clinch_jade
                .addPlugin clinch_coffee

      package_config = 
        package_name : 'my_package'
        inject : off
        bundle : 
          JadePowered : fixturesJade
        replacement :
          fs : fixturesWebShims + '/noops'
          jade : fixturesWebShims + '/noops'
        
      res_fn = (err, code) ->
        expect(err).to.be.null
        vm.runInNewContext code, jade_sandbox = {}
        jade_sandbox.should.not.to.contain.keys 'my_package'
        done()

      clinch_obj.buildPackage package_config, res_fn  

    it 'should supress injection on "inject : off" and without package name', (done) ->

      clinch_obj = new Clinch

      clinch_obj.addPlugin clinch_jade
                .addPlugin clinch_coffee

      package_config = 
        package_name : 'my_package'
        inject : off
        bundle : 
          JadePowered : fixturesJade
        replacement :
          fs : fixturesWebShims + '/noops'
          jade : fixturesWebShims + '/noops'
        
      res_fn = (err, code) ->
        expect(err).to.be.null
        vm.runInNewContext code, jade_sandbox = {}
        jade_sandbox.should.not.to.contain.keys 'JadePowered'
        done()

      clinch_obj.buildPackage package_config, res_fn

    it 'should supress build cached package on "cache_modules : off"', (done) ->

      clinch_obj = new Clinch

      clinch_obj.addPlugin clinch_coffee
  
      package_config = 
        package_name : 'my_package'
        cache_modules : off
        bundle : 
          Runtimed : fixturesUniqueGeneratorParent
        
      res_fn = (err, code) ->
        expect(err).to.be.null

        # this is browser emulation
        vm.runInNewContext code, clinch_sandbox = {}
        {Runtimed} = clinch_sandbox.my_package
        
        {generator} = Runtimed
        {generator2} = Runtimed

        expect(generator).to.not.deep.equal generator2
  
        done()

      clinch_obj.buildPackage package_config, res_fn

    # oh, I chitting a litle, but its correct detection :)
    it 'should build package with runtime version on "runtime : on"', (done) ->

      clinch_obj = new Clinch

      clinch_obj.addPlugin clinch_coffee

      package_config = 
        package_name : 'my_package'
        runtime : on
        bundle : 
          Runtimed : fixturesUniqueGeneratorParent
        
      res_fn = (err, code) ->
        expect(err).to.be.null
        expect(-> vm.runInNewContext code, clinch_sandbox = {} ).to.throw /Resolve clinch runtime library/
        done()

      clinch_obj.buildPackage package_config, res_fn
