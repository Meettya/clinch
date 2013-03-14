###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
# resolve require from [window] or by require() 
_ = @_ ? require 'lodash'

fs = require 'fs'
vm = require 'vm'

util = require 'util'

lib_path = GLOBAL?.lib_path || ''

# change to DIContainer
DIContainer = require "#{lib_path}di_container"

fixtureRoot  = __dirname + "/fixtures"
fixtures     = fixtureRoot + "/default"
fixturesFile = fixtures + "/summator"
fixturesNpm  = fixtureRoot + "/node_modules/summator"
fixturesSingle = fixtures + '/substractor'
fixturesTwoChild = fixtureRoot + '/two_children'
fixturesPrinter = fixtureRoot + '/with_printf'
fixturesReplacer = fixtureRoot + '/replacer'
fixturesWithCore = fixtureRoot + '/with_core'

describe 'Packer:', ->

  p_obj = package_config = null

  beforeEach ->
    registry_obj = new DIContainer()
    p_obj = registry_obj.getComponent 'Packer'
    
  describe 'buldPackage()', ->

    it 'should build pack for filename without \'require\'', (done) ->

      package_config = 
        bundle : 
          substractor : fixturesSingle
 
      res_fn = (err, code) ->
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        {substractor} = sandbox.my_package.substractor
        (substractor 10, 2).should.to.be.equal 8
        done()

      p_obj.buldPackage 'my_package', package_config, res_fn


    it 'should build pack for npm-like module without \'require\'', (done) ->
 
      package_config = 
        bundle : 
          summator : fixturesNpm

      res_fn = (err, code) ->
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        {summator} = sandbox.my_package.summator
        (summator 10, 2).should.to.be.equal 12
        done()

      p_obj.buldPackage 'my_package', package_config, res_fn


    it 'should build pack for file with deep dependencies', (done) ->

      package_config = 
        bundle : 
          summator : fixturesFile
        requireless : [
          'lodash'
        ]        

      res_fn = (err, code) ->
        expect(err).to.be.null

        # oh, its better than eval :)
        # yes, its create new global |my_package| - thats ok
        vm.runInThisContext code

        obj = my_package.summator
        (obj.summ_a_b_and_multiply_by_3 2, 3 ).should.to.equal 15
        (obj.summ_a_b_and_multiply_by_3_than_sub_2 2, 3 ).should.to.equal 13
        # 7*9+7*9-2 = 124
        (obj.sum_multiply_and_substracted_2_multipli 7, 9).should.to.equal 124
        # test big thing
        (obj.lowest 5,8,9,3,6).should.to.equal 3
        done()

      p_obj.buldPackage 'my_package', package_config, res_fn


    it 'should build pack, resolving ALL childrens', (done) ->
      package_config = 
        bundle : 
          summator : fixturesTwoChild 
        requireless : [
          'lodash'
        ]

      res_fn = (err, code) ->
        expect(err).to.be.null

        # console.log code

        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        {summator, substractor} = sandbox.my_package.summator
        (summator.summator 2, 3).should.to.equal 5
        (substractor.substractor 2, 3).should.to.equal -1
        done()

      p_obj.buldPackage 'my_package', package_config, res_fn

    it 'should build pack with real npm modules', (done) ->
      package_config = 
        bundle : 
          main : fixturesPrinter 
        requireless : [
          'lodash'
        ]

      res_fn = (err, code) ->
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        {Printer} = sandbox.my_package.main
        printer = new Printer '%08d'

        (printer.printFormatted 42).should.to.equal '00000042'
        (printer.printDateFormatted "Jun 9 2007", "dddd, mmmm dS, yyyy, h:MM:ss TT").
          should.to.equal 'Saturday, June 9th, 2007, 12:00:00 AM'
        done()

      p_obj.buldPackage 'my_package', package_config, res_fn

    it 'should build pack with replacement and environment (*hard work*)', (done) ->
        
      package_config = 
        bundle : 
          substractor : fixturesSingle
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
        vm.runInNewContext code, sandbox = {}

        # now we are got this back
        # yes, I know, it just stupid naming
        {substractor} = sandbox.my_package.substractor
        {summator,magic_summator} = sandbox.my_package.summator

        (substractor 10, 2).should.to.be.equal 8
        (summator 10, 5).should.to.be.equal 15
        (magic_summator 10, 5).should.to.be.equal 25
        done()

      p_obj.buldPackage 'my_package', package_config, res_fn

    it 'should build pack for modules, which use node.js core modules', (done) ->

      package_config = 
        bundle : 
          cored : fixturesWithCore
        replacement :
          'util' : fixturesWithCore + '/util_shim'

      res_fn = (err, code) ->
        expect(err).to.be.null

        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        # now we are got this back
        # yes, I know, it just stupid naming
        {formatter} = sandbox.my_package.cored

        (formatter 'hello %s!', 'world').should.to.be.equal 'hello world!'
        
        done()

      p_obj.buldPackage 'my_package', package_config, res_fn







