###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
# resolve require from [window] or by require() 
_ = @_ ? require 'lodash'

lib_path = GLOBAL?.lib_path || ''

FileProcessor = require "#{lib_path}file_processor"

fixtureRoot     = __dirname   + "/fixtures"
fixtures        = fixtureRoot + "/default"
fixturesCoffee  = fixtures    + "/summator.coffee"
fixturesJson    = fixtures    + "/json_id.json"
fixturesJs      = fixtures    + "/substractor.js"
fixturesMd      = fixtures    + "/readme.md"
fixturesErr     = fixtures    + "/unexistanse.js"
#TODO! add eco test


describe 'FileProcessor:', ->

  fp_obj = null

  beforeEach ->
    fp_obj = new FileProcessor()
    
  describe 'loadFile() *async*', ->

    it 'should load CoffeeScript file', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'string'
        # console.log data
        done()
      fp_obj.loadFile fixturesCoffee, res_fn

    it 'should load JSON file', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'string'
        done()
      fp_obj.loadFile fixturesJson, res_fn

    it 'should load JS file', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'string'
        done()
      fp_obj.loadFile fixturesJs, res_fn

    it 'should return "false" on unknown format', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.be.false
        done()
      fp_obj.loadFile fixturesMd, res_fn

    it 'should return error if file read fail', (done) ->
      res_fn = (err, data) ->
        expect(err).to.not.be.null
        err.code.should.to.equal 'ENOENT'
        done()
      fp_obj.loadFile fixturesErr, res_fn

  describe 'getSupportedFileExtentions()', ->

    it 'should return array of supported file extentions', ->
      res = fp_obj.getSupportedFileExtentions()
      expect(res).not.to.be.empty

