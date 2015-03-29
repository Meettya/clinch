###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
_ = require 'lodash'

async   = require 'async'

util = require 'util'

lib_path = GLOBAL?.lib_path || ''

# change to DIContainer
DIContainer = require "#{lib_path}di_container"

# our external plugins
clinch_coffee = require 'clinch.coffee'

fixtureRoot  = __dirname + "/fixtures"
fixtures     = fixtureRoot + "/default"
fixturesFile = fixtures + "/summator"
fixturesNpm  = fixtureRoot + "/node_modules/summator"
fixturesTwoChild = fixtureRoot + '/two_children'
fixturesWithCore = fixtureRoot + '/with_core'

describe 'Gatherer:', ->

  g_obj = g_conf = null

  file_extention  = clinch_coffee.extension
  coffee_comp   = {}
  coffee_comp[file_extention] = clinch_coffee.processor

  beforeEach ->
    ###
    YES, I know it will be correctly to create object with mock etc.
    but it SHOULD work right this and now I don't care about it at all
    ###
    registry_obj = new DIContainer()
    registry_obj.addComponentsSettings 'FileProcessor' , 'third_party_compilers', coffee_comp

    g_obj = registry_obj.getComponent 'Gatherer'
    
  describe 'buildModulePack() *async*', ->

    g_conf = 
      requireless : 'lodash'

    it 'should build pack for filename', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        # console.log data
        expect(_.keys data.source_code).to.have.length 4
        done()
      g_obj.buildModulePack fixturesFile, g_conf, res_fn

    it 'should build pack for dirname', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(_.keys data.source_code).to.have.length 6
        done()
      g_obj.buildModulePack fixtures, g_conf,res_fn

    it 'should build pack for module', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        # console.log util.inspect data, true, null, true
        expect(_.keys data.source_code).to.have.length 1
        done()
      g_obj.buildModulePack fixturesNpm, g_conf, res_fn

    it 'should build some packs for some modules in parallel (without leaking)', (done) ->
      map_fn = (item, map_cb) ->
        g_obj.buildModulePack item, g_conf, (err, res) ->
          map_cb err if err
          map_cb null, res

      async.map [fixturesFile, fixtures], map_fn, (err, data) ->
        expect(err).to.be.undefined
        #console.log util.inspect data, true, null, true
        expect(_.keys data[0].source_code).to.have.length 4
        expect(_.keys data[1].source_code).to.have.length 6
        done()

    it 'should build pack for modules, used node.js core modules', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        #console.log util.inspect data, true, null, true
        expect(_.keys data.source_code).to.have.length 1
        expect(_.keys data.dependencies_tree).to.have.length 2
        done()
      g_obj.buildModulePack fixturesWithCore, g_conf, res_fn


  describe 'test buildModulePack() |requireless| options', ->

    it 'should faster build pack, if not looking for \'require\' in marked requreless module |lodash|', (done) ->
      g_conf = 
        requireless : 'lodash'

      res_fn = (err, data) ->
        expect(err).to.be.null
        #console.log _.keys data.source_code
        expect(_.keys data.source_code).to.have.length 4
        done()
      g_obj.buildModulePack fixturesFile, g_conf, res_fn

    it 'should slow build pack, if looking in huge pre-builded lib |lodash|', (done) ->

      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(_.keys data.source_code).to.have.length 4
        done()
      g_obj.buildModulePack fixturesFile, null, res_fn

  describe 'repiting buildModulePack() must return some data:', ->

    mapper = (n, par_cb) -> g_obj.buildModulePack fixturesTwoChild, null, par_cb

    check_fn = (results, done) ->
      for item in results
        summ_dep = item.dependencies_tree[fixturesTwoChild + '/summator.coffee']
        subs_dep = item.dependencies_tree[fixturesTwoChild + '/substractor.coffee']
        summ_dep.should.to.be.eql subs_dep

      done()      

    it '1 resolving ALL childrens', (done) ->

      async.times 5, mapper, (err, results) ->
        expect(err).to.be.undefined
        check_fn results, done

    it '2 resolving ALL childrens', (done) ->

      async.times 5, mapper, (err, results) ->
        expect(err).to.be.undefined
        check_fn results, done

    it '3 resolving ALL childrens', (done) ->
      
      async.times 5, mapper, (err, results) ->
        expect(err).to.be.undefined
        check_fn results, done

  describe 'resetCaches()', ->

    it 'should drop cache and return null', ->
      expect(g_obj.resetCaches()).to.be.null

  describe 'buildFunctionPack()', ->
    it 'should create pack for function', (done) ->
      data_in = ->

      res_fn = (err, data) ->
        expect(err).to.be.null

        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'object'
        
        done()

      g_obj.buildFunctionPack data_in, res_fn


