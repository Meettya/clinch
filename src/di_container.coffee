###
This is DI Container for Clinch - its make available DI and simplify configuration. 
###
_ = require 'lodash'

# all our classes here
Packer          = require './packer'
Gatherer        = require './gatherer'
FileProcessor   = require './file_processor'
BundleProcessor = require './bundle_processor'

# for debug
# util = require 'util'

class DIContainer
  constructor : ->
    @_packer_           = null
    @_gatherer_         = null
    @_file_processor_   = null
    @_bundle_processor_ = null

    @_component_settings_ = @_initComponentSetting()

  ###
  This method simple setter for components settings
  its wipe out old values
  chainable
  ###
  setComponentsSettings : (options = {}) ->

    for own key, value of options

      up_key = @_upperCaseWithExistenceCheck key
      @_component_settings_[up_key] = value

    # clear cache to re-build new objects with new settings
    @_flushComponentsChache()
    this

  ###
  This method add some deep settings to components settings
  only overwrite old deep settings, but not all key
  chainable
  ###
  addComponentsSettings : (component_name, path..., new_value_obj) ->

    up_key = @_upperCaseWithExistenceCheck component_name
    # we are use _.reduce by side-effect, in that step new value will be injected
    last_path_idx = path.length - 1

    deep_walker = (accumulator, step_val, idx) ->
      # ensure deep bulder may use object
      unless accumulator[step_val]
        accumulator[step_val] = {}

      # just inject new value
      if idx is last_path_idx
        for [key, value] in _.pairs new_value_obj
          accumulator[step_val][key] = value
          null
      # or go deeper
      else
        accumulator = accumulator[step_val]

    _.reduce path, deep_walker, @_component_settings_[up_key]

    # clear cache to re-build new objects with new settings
    @_flushComponentsChache()
    this
    
  ###
  This method return component by it name
  may recursive resolve dependencies
  ###
  getComponent : (component_name) ->

    up_name = @_upperCaseWithExistenceCheck component_name
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
  This internal method to check is uppercased name exists in @_component_settings_
  return uppercased name or throw error
  ###
  _upperCaseWithExistenceCheck : (key) ->
    # just flat syntax 
    up_key = key.toUpperCase()

    unless @_component_settings_[up_key]
      throw Error "don't know component name |#{key}|, mistype?"

    up_key

  ###
  Internal initor to reduce constructor
  ###
  _initComponentSetting : ->
    PACKER          : {}
    GATHERER        : {}
    FILEPROCESSOR   : {}
    BUNDLEPROCESSOR : {}

module.exports = DIContainer
