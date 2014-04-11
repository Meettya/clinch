###
Test suite for node only
###

_ = require 'lodash'

fs = require 'fs'
vm = require 'vm'

util = require 'util'

lib_path = GLOBAL?.lib_path || ''

require('node-jsx').install extension: '.jsx'

jsdom = require 'jsdom'

# change to app, for test
Clinch = require "#{lib_path}app"

fixtureRoot  = __dirname + "/fixtures"
fixturesJade = fixtureRoot + '/jade_powered'
fixturesReact = fixtureRoot + '/react_powered'
fixturesWebShims = fixtureRoot + '/web_modules'

JadePowered = require "#{fixturesJade}"

React = ReactTestUtils = document = window = null

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
      clinch_obj.buildPackage 'my_package', package_config, res_fn

  describe 'react:', ->

    react_expected = """
                    \n<div class="message">
                      <p>Hello Bender!!!</p>
                    </div>
                    """

    beforeEach ->
      global.window     = jsdom.jsdom().createWindow '<html><body></body></html>'
      global.document   = global.window.document
      global.navigator  = global.window.navigator

      React  = require "react/addons"
      ReactTestUtils = React.addons.TestUtils

    afterEach ->
      delete global.window
      delete global.document
      delete global.navigator

    it 'should display the window objects', ->
      global.window.should.exist
      global.document.should.exist
      

    it 'should work in node (as `coffee`)', ->
      ReactPowered = require "#{fixturesReact}/component.coffee"
      greater = ReactTestUtils.renderIntoDocument ReactPowered name : 'Bender'
      expect(greater.refs.p.props.children).to.be.equal "Hello Bender!!!" 

    it 'should work in node (as `jsx`)', ->
      ReactPowered = require "#{fixturesReact}/component.jsx"
      greater = ReactTestUtils.renderIntoDocument ReactPowered name : 'Bender'
      expect(greater.refs.p.props.children).to.be.eql ["Hello ", "Bender", "!!!"]

