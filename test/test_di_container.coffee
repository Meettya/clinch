###
Test for Node only
###

inspect = GLOBAL?.inspect

lib_path = GLOBAL?.lib_path || ''

DIContainer = require "#{lib_path}di_container"

describe 'DIContainer:', ->

  r_obj = null

  beforeEach ->
    r_obj = new DIContainer()
    
  describe 'getComponent()', ->

    it 'should return known component', ->
      expect(r_obj.getComponent 'FileProcessor').to.be.an 'object'

    it 'should throw error on unknown component', ->
      expect(-> r_obj.getComponent 'IUnknown').to.throw /418/

    it 'should return component as singleton (in one DIContainer object)', ->
      first = r_obj.getComponent 'FileProcessor'
      second = r_obj.getComponent 'FileProcessor'
      
      first.should.to.be.deep.equal second

    it 'should return different component for different DIContainer objects', ->
      second_r_obj = new DIContainer()

      first = r_obj.getComponent 'FileProcessor'
      second = second_r_obj.getComponent 'FileProcessor'
      
      first.should.to.not.be.deep.equal second

  describe 'setComponentsSettings()', ->

    it 'should setup settings for known component', ->
      options = { FileProcessor : {foo : 'bar' } }
      expect(r_obj.setComponentsSettings options).to.be.an.instanceof DIContainer

    it 'should throw error on unknown component name (mistype?)', ->
      options = { IUnknown : {foo : 'bar' } }
      expect(-> r_obj.setComponentsSettings options).to.throw /mistype/




