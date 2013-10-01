###
Test suite for node only
Was tested main app itself
###

fs = require 'fs'
vm = require 'vm'

fixtureRoot  = __dirname + "/fixtures"
fixturesWebShims = fixtureRoot + '/web_modules'
fixtureDefault = fixtureRoot + '/default'
fixtureSimply = fixtureDefault + '/substractor'
fixturesJade = fixtureRoot + '/jade_powered'

fixturesNpm  = fixtureRoot + "/node_modules/summator"
fixturesTwoChild = fixtureRoot + '/two_children'
fixturesReplacer = fixtureRoot + '/replacer'

lib_path = GLOBAL?.lib_path || ''

# change to app, for test
Clinch = require "#{lib_path}app"

describe 'Clinch with runtime lib:', ->

  clinch_obj = package_config = null

  beforeEach ->

    clinch_obj = new Clinch strict : off, runtime : on, jade : pretty : off

  describe 'buldPackage()', ->

    it 'should build package with runtime version', (done) ->

      # looks strange, but its just <script src='./clinch_runtime.js'></script> analog
      clinch_runtime_file = "#{__dirname}/../clinch_runtime.js"
      clinch_runtime = fs.readFileSync clinch_runtime_file, 'utf8'
      vm.runInNewContext clinch_runtime, clinch_sandbox = {}
  
      package_config = 
        package_name : 'my_package'
        bundle : 
          Runtimed : fixtureSimply
        
      res_fn = (err, code) ->
        expect(err).to.be.null

        # this is browser emulation
        vm.runInNewContext code, clinch_sandbox
        {Runtimed} = clinch_sandbox.my_package
        
        {substractor} = Runtimed
        res = substractor 20, 5
        res.should.to.be.equal 15
        
        done()

      clinch_obj.buldPackage package_config, res_fn  

    # oh, I chitting a litle, but its correct detection :)
    it 'should build package with runtime version ("on" in package options)', (done) ->

      clinch_obj = new Clinch strict : off, jade : pretty : off

      package_config = 
        package_name : 'my_package'
        runtime : on
        bundle : 
          Runtimed : fixtureSimply
        
      res_fn = (err, code) ->
        expect(err).to.be.null
        expect(-> vm.runInNewContext code, clinch_sandbox = {} ).to.throw /Resolve clinch runtime library/
        done()

      clinch_obj.buldPackage package_config, res_fn

    it 'should throw error if runtime library not loaded', (done) ->

      package_config = 
        package_name : 'my_package'
        bundle : 
          Runtimed : fixtureSimply
        
      res_fn = (err, code) ->
        expect(err).to.be.null
        expect(-> vm.runInNewContext code, clinch_sandbox = {} ).to.throw /Resolve clinch runtime library/
        done()

      clinch_obj.buldPackage package_config, res_fn

    it 'should build difficult package', (done) ->

      jade_expected = """
                      <div class="message"><p>Hello Bender!!!</p></div>
                      """


       # looks strange, but its just <script src='./runtime.js'></script> analog
      jade_runtime_file = "#{__dirname}/../node_modules/jade/runtime.js"
      jade_runtime = fs.readFileSync jade_runtime_file, 'utf8'

      vm.runInNewContext jade_runtime, jade_sandbox = window : {}
      # looks starnge, but its ok for browser
      jade_sandbox.jade = jade_sandbox.window.jade

      clinch_runtime_file = "#{__dirname}/../clinch_runtime.js"
      clinch_runtime = fs.readFileSync clinch_runtime_file, 'utf8'
      vm.runInNewContext clinch_runtime, jade_sandbox

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
      clinch_obj.buldPackage package_config, res_fn   

    it 'should build pack with replacement and environment (*hard work*)', (done) ->

      clinch_runtime_file = "#{__dirname}/../clinch_runtime.js"
      clinch_runtime = fs.readFileSync clinch_runtime_file, 'utf8'
      vm.runInNewContext clinch_runtime, sandbox = {}
        
      package_config = 
        package_name : 'my_package'
        bundle : 
          substractor : fixtureSimply
          summator : fixturesNpm
        environment : 
          printer : fixturesTwoChild
        replacement :
          './power' : fixturesReplacer
        requireless : [
          'lodash'
        ]

      res_fn = (err, code) ->
        expect(err).to.be.null
        # oh, its better than eval :)

        #console.log code

        vm.runInNewContext code, sandbox

        # now we are got this back
        # yes, I know, it just stupid naming
        {substractor} = sandbox.my_package.substractor
        {summator,magic_summator} = sandbox.my_package.summator

        (substractor 10, 2).should.to.be.equal 8
        (summator 10, 5).should.to.be.equal 15
        (magic_summator 10, 5).should.to.be.equal 25
        done()

      clinch_obj.buldPackage package_config, res_fn

    it 'should build package with minified runtime version', (done) ->

      # looks strange, but its just <script src='./clinch_runtime.js'></script> analog
      clinch_runtime_file = "#{__dirname}/../clinch_runtime.min.js"
      clinch_runtime = fs.readFileSync clinch_runtime_file, 'utf8'
      vm.runInNewContext clinch_runtime, clinch_sandbox = {}
  
      package_config = 
        package_name : 'my_package'
        bundle : 
          Runtimed : fixtureSimply
        
      res_fn = (err, code) ->
        expect(err).to.be.null

        # this is browser emulation
        vm.runInNewContext code, clinch_sandbox
        {Runtimed} = clinch_sandbox.my_package
        
        {substractor} = Runtimed
        res = substractor 20, 5
        res.should.to.be.equal 15
        
        done()

      clinch_obj.buldPackage package_config, res_fn  
