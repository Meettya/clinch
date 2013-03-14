###
This is DI Container for Clinch - its make available DI and simplify configuration. 
###
_ = require 'lodash'

# all our classes here
Packer          = require './packer'
Gatherer        = require './gatherer'
FileProcessor   = require './file_processor'
BundleProcessor = require './bundle_processor'

class DIContainer
  constructor : ->
    @_packer_           = null
    @_gatherer_         = null
    @_file_processor_   = null
    @_bundle_processor_ = null

    @_component_settings_ = @_initComponentSetting()

  ###
  This method simple setter for components settings
  chainable
  ###
  setComponentsSettings : (options = {}) ->

    for own key, value of options
      # just flat syntax 
      up_key = key.toUpperCase()

      unless @_component_settings_[up_key]
        throw Error "don't know component name |#{key}|, mistype?"

      @_component_settings_[up_key] = value

    # clear cache to re-build new objects with new settings
    @_flushComponentsChache()
    this

  ###
  This internal method to flush all objects cache
  used if settings changed
  YES, its copy-paste, but we are MUST to declare all object properties in constructor
  ###
  _flushComponentsChache : ->
    @_packer_           = null
    @_gatherer_         = null
    @_file_processor_   = null
    @_bundle_processor_ = null

    null

  ###
  This method return component by it name
  may recursive resolve dependencies
  ###
  getComponent : (component_name) ->

    up_name = component_name.toUpperCase()
    settings = @_component_settings_[up_name]

    switch up_name
      when 'FILEPROCESSOR'
        @_file_processor_ or= new FileProcessor settings
      when 'GATHERER'
        @_gatherer_ or= new Gatherer @getComponent('FileProcessor'), settings
      when 'BUNDLEPROCESSOR'
        @_bundle_processor_ or= new BundleProcessor @getComponent('Gatherer'), settings
      when 'PACKER'
        @_packer_ or= new Packer @getComponent('BundleProcessor'), settings

      else
        throw Error "418! don't know component |#{component_name}|"

  ###
  Internal initor to reduce constructor
  ###
  _initComponentSetting : ->
    PACKER          : {}
    GATHERER        : {}
    FILEPROCESSOR   : {}
    BUNDLEPROCESSOR : {}

module.exports = DIContainer
