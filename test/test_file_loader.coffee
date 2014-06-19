###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
# resolve require from [window] or by require() 
_ = @_ ? require 'lodash'

lib_path = GLOBAL?.lib_path || ''

# change to DIContainer
DIContainer = require "#{lib_path}di_container"

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
    ###
    YES, I know it will be correctly to create object with mock etc.
    but it SHOULD work right this and now I don't care about it at all
    ###
    registry_obj = new DIContainer()
    fl_obj = registry_obj.getComponent 'FileLoader'
    
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

  describe 'getFileWithMeta() *async*', ->

    it 'should get file from disk on empty cache', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'object'
        data.should.to.have.keys ['meta', 'digest', 'content']
        #console.log data
        done()
      fl_obj.getFileWithMeta fixturesCoffee, res_fn

    it 'should get file from cache', (done) ->
      res_fn2 = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'object'
        data.should.to.have.keys ['meta', 'digest', 'content']
        #console.log data
        done()

      res_fn1 = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'object'
        data.should.to.have.keys ['meta', 'digest', 'content']
        #console.log data
        fl_obj.getFileWithMeta fixturesCoffee, res_fn2

      fl_obj.getFileWithMeta fixturesCoffee, res_fn1

    it 'should use queue for some request in one time', (done) ->
     
      cicle_numbers = 10000

      all_done = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'object'
        data.should.to.have.keys ['meta', 'digest', 'content']
        #console.log data
        done()

      one_done = _.after cicle_numbers, all_done

      _.times cicle_numbers, -> fl_obj.getFileWithMeta fixturesCoffee, one_done

  describe 'resetCaches()', ->

    it 'should drop cache and return null', ->
      expect(fl_obj.resetCaches()).to.be.null

