###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
# resolve require from [window] or by require() 
_ = @_ ? require 'lodash'

fs = require 'fs'

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

describe 'BundleProcessor: (actually its not test, just try to get results)', ->

  bp_obj = package_config = null

  beforeEach ->
    registry_obj = new DIContainer()
    bp_obj = registry_obj.getComponent 'BundleProcessor'

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
    
  describe 'buildRawPackageData()', ->

    it 'should build pack', (done) ->
      
      res_fn = (err, code) ->
        console.log err if err
        #console.log util.inspect code, true, null, true
        #console.log code

        done()

      bp_obj.buildRawPackageData package_config, res_fn


  describe 'replaceDependenciesInRawPackageData()', ->

    it 'should replace dependencies', (done) ->

      res_fn = (err, code) ->
        console.log err if err

        res = bp_obj.replaceDependenciesInRawPackageData code

        #console.log util.inspect res, true, null, true
        #console.log code

        done()

      bp_obj.buildRawPackageData package_config, res_fn


  describe 'joinBundleSets()', ->

    it 'should join all into flat structure', (done) ->

      res_fn = (err, code) ->
        console.log err if err

        pre_res = bp_obj.replaceDependenciesInRawPackageData code

        res = bp_obj.joinBundleSets pre_res

        # console.log util.inspect res, true, null, true

        done()

      bp_obj.buildRawPackageData package_config, res_fn


  describe 'changePathsToHashesInJoinedSet()', ->

    it 'should join all into flat structure', (done) ->

      res_fn = (err, code) ->
        console.log err if err

        pre_res = bp_obj.joinBundleSets bp_obj.replaceDependenciesInRawPackageData code

        res = bp_obj.changePathsToHashesInJoinedSet pre_res

        #console.log util.inspect res, true, null, true

        done()

      bp_obj.buildRawPackageData package_config, res_fn

  describe 'buildAll()', ->

    it 'should build all data in one touch', (done) ->

      res_fn = (err, code) ->
        console.log err if err
        #console.log util.inspect code, true, null, true
        done()

      bp_obj.buildAll package_config, res_fn

    it 'should build pack for modules, used node.js core modules', (done) ->

      package_config = 
        bundle : 
          cored : fixturesWithCore
        replacement :
          'util' : fixturesWithCore + '/util_shim'

      res_fn = (err, code) ->
        console.log err if err
        # console.log util.inspect code, true, null, true
        done()

      bp_obj.buildAll package_config, res_fn





