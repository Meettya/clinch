###
its test suite for bugfixes
###

vm = require 'vm'
fs = require 'fs'

fixtureRoot  = __dirname + "/fixtures"
fixturesBugxifes = fixtureRoot + '/bugfixes'

lib_path = GLOBAL?.lib_path || ''

# change to app, for test
Clinch = require "#{lib_path}app"

describe 'Clinch app bugfixes suite:', ->

  clinch_obj = package_config = null

  beforeEach ->

    clinch_obj = new Clinch

  describe 'buildPackage()', ->

    describe 'issue #18 - wrong module.exports definition', ->

      suite_file = fixturesBugxifes + '/issue_18'

      it 'example should work itself correctly in node', ->

        test_obj = require suite_file

        test_obj.should.to.be.an 'String'
        test_obj.should.to.be.eql 'module'

      
      it 'clinch should build package with module.exports test', (done) ->

        package_config = 
          package_name : 'my_package'
          bundle : 
            issue : suite_file

        res_fn = (err, code) ->
          expect(err).to.be.null

          # this is browser emulation
          vm.runInNewContext code, clinch_sandbox = {}
          {issue} = clinch_sandbox.my_package

          expect(issue).to.be.an 'String'
          expect(issue).to.be.eql 'module'
          done()

        clinch_obj.buildPackage package_config, res_fn 

      it 'clinch should build package with module.exports test with minified runtime version', (done) ->

        clinch_obj = new Clinch strict : off, runtime : on

        # looks strange, but its just <script src='./clinch_runtime.js'></script> analog
        clinch_runtime_file = "#{__dirname}/../clinch_runtime.min.js"
        clinch_runtime = fs.readFileSync clinch_runtime_file, 'utf8'
        vm.runInNewContext clinch_runtime, clinch_sandbox = {}
    
        package_config = 
          package_name : 'my_package'
          bundle : 
            issue : suite_file
          
        res_fn = (err, code) ->
          expect(err).to.be.null

          # this is browser emulation
          # this is browser emulation
          vm.runInNewContext code, clinch_sandbox
          {issue} = clinch_sandbox.my_package

          expect(issue).to.be.an 'String'
          expect(issue).to.be.eql 'module'
          done()

        clinch_obj.buildPackage package_config, res_fn  

