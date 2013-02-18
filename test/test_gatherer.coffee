###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
_ = require 'lodash'

async   = require 'async'

util = require 'util'

lib_path = GLOBAL?.lib_path || ''

Gatherer = require "#{lib_path}gatherer"

fixtureRoot  = __dirname + "/fixtures"
fixtures     = fixtureRoot + "/default"
fixturesFile = fixtures + "/summator"
fixturesNpm  = fixtureRoot + "/node_modules/summator"
fixturesTwoChild = fixtureRoot + '/two_children'

describe 'Gatherer:', ->

  g_obj = null

  beforeEach ->
    g_obj = new Gatherer()
    
  describe 'buildModulePack() *async*', ->

    it 'should build pack for filename', (done) ->
      g_obj.addRequireless /lodash/
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(_.keys data.source_code).to.have.length 4
        done()
      g_obj.buildModulePack fixturesFile, res_fn

    it 'should build pack for dirname', (done) ->
      g_obj.addRequireless /lodash/
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(_.keys data.source_code).to.have.length 6
        done()
      g_obj.buildModulePack fixtures, res_fn

    it 'should build pack for module', (done) ->
      g_obj.addRequireless /lodash/
      res_fn = (err, data) ->
        expect(err).to.be.null
        # console.log util.inspect data, true, null, true
        expect(_.keys data.source_code).to.have.length 1
        done()
      g_obj.buildModulePack fixturesNpm, res_fn

    it 'should build some packs for some modules in parallel (without leaking)', (done) ->
      g_obj.addRequireless /lodash/
      map_fn = (item, map_cb) ->
        g_obj.buildModulePack item, (err, res) ->
          map_cb err if err
          map_cb null, res

      async.map [fixturesFile, fixtures], map_fn, (err, data) ->
        expect(err).to.be.null
        #console.log util.inspect data, true, null, true
        expect(_.keys data[0].source_code).to.have.length 4
        expect(_.keys data[1].source_code).to.have.length 6
        done()

  describe 'addFilters()', ->

    it 'should add filter items as RegExp', ->
      g_obj.addFilters /lodash/, /underscore/
      g_obj.getFilters().should.be.eql [/lodash/, /underscore/]

    it 'should add filter items as String', ->
      g_obj.addFilters 'lodash', 'underscore'
      g_obj.getFilters().should.be.eql [/lodash/, /underscore/]

  describe 'addRequireless()', ->

    it 'should add filter items as RegExp', ->
      g_obj.addRequireless /lodash/, /underscore/
      g_obj.getRequireless().should.be.eql [/lodash/, /underscore/]

    it 'should add filter items as String', ->
      g_obj.addRequireless 'lodash', 'underscore'
      g_obj.getRequireless().should.be.eql [/lodash/, /underscore/]

    it 'should faster build pack, if not looking for \'require\' in marked requreless module |lodash|', (done) ->
      g_obj.addRequireless 'lodash'

      res_fn = (err, data) ->
        expect(err).to.be.null
        #console.log _.keys data.source_code
        expect(_.keys data.source_code).to.have.length 4
        done()
      g_obj.buildModulePack fixturesFile, res_fn

    it 'should slow build pack, if looking in huge pre-builded lib |lodash|', (done) ->

      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(_.keys data.source_code).to.have.length 4
        done()
      g_obj.buildModulePack fixturesFile, res_fn

  describe 'repiting buildModulePack() must return some data:', ->

    mapper = (n, par_cb) -> g_obj.buildModulePack fixturesTwoChild, par_cb

    check_fn = (results, done) ->
      for item in results
        summ_dep = item.dependencies_tree[fixturesTwoChild + '/summator.coffee']
        subs_dep = item.dependencies_tree[fixturesTwoChild + '/substractor.coffee']
        summ_dep.should.to.be.eql subs_dep

      done()      

    it '1 resolving ALL childrens', (done) ->

      async.times 5, mapper, (err, results) ->
        expect(err).to.be.null
        check_fn results, done

    it '2 resolving ALL childrens', (done) ->

      async.times 5, mapper, (err, results) ->
        expect(err).to.be.null
        check_fn results, done

    it '3 resolving ALL childrens', (done) ->
      
      async.times 5, mapper, (err, results) ->
        expect(err).to.be.null
        check_fn results, done


