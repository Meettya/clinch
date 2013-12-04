###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
# resolve require from [window] or by require() 
_ = @_ ? require 'lodash'

lib_path = GLOBAL?.lib_path || ''

DigestCalculator = require "#{lib_path}digest_calculator"

fixtureRoot     = __dirname   + "/fixtures"
fixtures        = fixtureRoot + "/default"
fixturesCoffee  = fixtures    + "/summator.coffee"

describe 'DigestCalculator:', ->

  test_obj = null

  beforeEach ->
    test_obj = new DigestCalculator
    
  describe 'readFileDigest() *async*', ->

    it 'should calculate digest by file content', (done) ->
      res_fn = (err, data) ->
        expect(err).to.be.null
        expect(data).to.not.be.null
        expect(data).to.not.be.undefined
        data.should.to.be.a 'number'
        # console.log data
        done()
      test_obj.readFileDigest fixturesCoffee, res_fn

  describe 'calculateDataDigest()', ->

    it 'should calculate digest for data as string', ->
      in_data = 'just string'
      res = test_obj.calculateDataDigest in_data

      expect(res).to.not.be.null
      expect(res).to.not.be.undefined
      res.should.to.be.a 'number'

    it 'should calculate digest for data as function', ->
      in_data = -> {}
      res = test_obj.calculateDataDigest in_data

      expect(res).to.not.be.null
      expect(res).to.not.be.undefined
      res.should.to.be.a 'number'

    it 'should calculate digest for data as object', ->
      in_data = { 'a' : 'c', d : -> 'foo' }
      res = test_obj.calculateDataDigest in_data

      expect(res).to.not.be.null
      expect(res).to.not.be.undefined
      res.should.to.be.a 'number'
