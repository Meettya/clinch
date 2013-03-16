###
This is main entry point for Clinch - API and setting here
###

_ = require 'lodash'

# its our registry
DIContainer = require "./di_container"

class Clinch 
  constructor: (@_options_={}) ->
    # for debugging 
    @_do_logging_ = if @_options_.log? and @_options_.log is on and console?.log? then yes else no
    @_dic_obj_ = new DIContainer()
    @_configureComponents()
    
  ###
  This method create browser package with given configuration
  actually its just proxy all to packer
  ###
  buldPackage : (package_name, package_config, main_cb) ->
    packer = @_dic_obj_.getComponent 'Packer'
    packer.buldPackage package_name, package_config, main_cb

  ###
  This method force flush cache
  ###
  flushCache : ->
    gatherer = @_dic_obj_.getComponent 'Gatherer'
    gatherer.resetCaches()


  ###
  This method add third party file processor to Clinch
  ###
  registerProcessor : (file_extention, processor_fn) ->
    # some naive checks
    unless _.isString file_extention
      throw TypeError "file extention must be a String but get |#{file_extention}|"
    unless _.isFunction processor_fn
      throw TypeError "processor must be a Function but get |#{processor_fn}|"

    processor_obj = {}
    processor_obj[file_extention] = processor_fn

    @_dic_obj_.addComponentsSettings 'FileProcessor' , 'third_party_compilers', processor_obj

  ###
  This internal method used to configure components in DiC
  ###
  _configureComponents : ->
    # just use short-cut
    log = !!@_options_.log

    ###
    set jade compiler settings for jade.compile()
    jade = 
      pretty : on
      self : on
      compileDebug : off
    ###
    if jade = @_options_.jade
      @_dic_obj_.setComponentsSettings FileProcessor : {jade, log}

    ###
    set packer settings
    strict : on
    inject : on
    ###
    packer_settings = {log}
    for setting_name in ['strict', 'inject']
      if @_options_[setting_name]?
        packer_settings[setting_name] = @_options_[setting_name]
    @_dic_obj_.setComponentsSettings Packer : packer_settings

    null


module.exports = Clinch