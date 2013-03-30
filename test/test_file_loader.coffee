###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
# resolve require from [window] or by require() 
_ = @_ ? require 'lodash'

lib_path = GLOBAL?.lib_path || ''

FileLoader = require "#{lib_path}file_loader"

fixtureRoot     = __dirname   + "/fixtures"
fixtures        = fixtureRoot + "/default"
fixturesCoffee  = fixtures    + "/summator.coffee"
fixturesJson    = fixtures    + "/json_id.json"
fixturesJs      = fixtures    + "/substractor.js"
fixturesMd      = fixtures    + "/readme.md"
fixturesErr     = fixtures    + "/unexistanse.js"


describe 'FileLoader:', ->

  fl_obj = null

  beforeEach ->
    fl_obj = new FileLoader
    
  describe 'readFile() *async*', ->

    it 'should load file', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'string'
        #console.log data
        done()
      fl_obj.readFile fixturesCoffee, res_fn

  describe 'readFileMeta() *async*', ->

    it 'should calculate digest by file content', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'object'
        data.mtime.should.to.be.a 'number'
        # console.log data
        done()
      fl_obj.readFileMeta fixturesCoffee, res_fn

  describe 'readFileDigest() *async*', ->

    it 'should calculate digest by file content', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'number'
        # console.log data
        done()
      fl_obj.readFileDigest fixturesCoffee, res_fn

  describe 'getFileContent() *async*', ->

    it 'should get file from disk on empty cache', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'string'
        #console.log data
        done()
      fl_obj.getFileContent fixturesCoffee, res_fn

    it 'should get file from cache', (done) ->
      res_fn2 = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'string'
        #console.log data
        done()

      res_fn1 = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'string'
        #console.log data
        fl_obj.getFileContent fixturesCoffee, res_fn2

      fl_obj.getFileContent fixturesCoffee, res_fn1
