###
Test suite for node only
###

_ = require 'lodash'

fs = require 'fs'
vm = require 'vm'

util = require 'util'

lib_path = GLOBAL?.lib_path || ''

# change to app, for test
Clinch = require "#{lib_path}app"

fixtureRoot  = __dirname + "/fixtures"
fixturesJade = fixtureRoot + '/jade_powered'
fixturesWebShims = fixtureRoot + '/web_modules'

JadePowered = require "#{fixturesJade}"

describe 'Clinch and template engines:', ->

  clinch_obj = package_config = null

  beforeEach ->
    clinch_obj = new Clinch()
    
  describe 'jade:', ->

    jade_expected = """
                    \n<div class="message">
                      <p>Hello Bender!!!</p>
                    </div>
                    """

    it 'should work in node', ->
      
      jade_obj = new JadePowered()
      res = jade_obj.renderData name : 'Bender'
      res.should.to.be.equal jade_expected

    it 'should work in browser (emulation)', (done) ->

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
        bundle : 
          JadePowered : fixturesJade
        replacement :
          fs : fixturesWebShims + '/noops'
          jade : fixturesWebShims + '/noops'
        
      res_fn = (err, code) ->
        expect(err).to.be.null

        # this is browser emulation
        vm.runInNewContext code, jade_sandbox
        {JadePowered} = jade_sandbox.my_package
        
        jade_obj = new JadePowered()
        res = jade_obj.renderData name : 'Bender'
        res.should.to.be.equal jade_expected

        done()

      # here we are build our package, its what you need for browser
      clinch_obj.buldPackage 'my_package', package_config, res_fn
