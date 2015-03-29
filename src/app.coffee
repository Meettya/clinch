###
This is main entry point for Clinch - API and setting here
###

_ = require 'lodash'

# its our registry
DIContainer = require "./di_container"

module.exports = class Clinch

  constructor: (@_options_={}) ->
    # for debugging 
    @_do_logging_  = console?.log? and @_options_.log is on
    @_di_cont_obj_ = new DIContainer()
    @_configureComponents()
    
  ###
  This method create browser package with given configuration
  actually its just proxy all to packer
  ###
  buildPackage : (in_settings..., main_cb) ->
    packer = @_di_cont_obj_.getComponent 'Packer'
    packer.buildPackage @_composePackageSettings(in_settings), main_cb

  ###
  This method force flush all caches
  yes, we are have three different caches
  ###
  flushCache : ->
    for component_name in ['FileLoader', 'FileProcessor', 'Gatherer']
      @_di_cont_obj_.getComponent(component_name).resetCaches()
      null
    null
  
  ###
  This method may return list of all files, used in package
  may be used for `watch` functionality on those files
  ###
  getPackageFilesList : (package_config, main_cb) ->
    bundler = @_di_cont_obj_.getComponent 'BundleProcessor'
    bundler.buildRawPackageData package_config, (err, raw_data) ->
      return main_cb err if err
      main_cb null, _.keys bundler.joinBundleSets(raw_data).names_map

  ###
  This method add separate clinch plugin, just shortcut 
  ###
  addPlugin : ({extension, processor}) ->
    @registerProcessor extension, processor

  ###
  This method add third party file processor to Clinch
  ###
  registerProcessor : (file_extention, processor_fn) ->
    # some naive checks
    unless _.isString file_extention
      throw TypeError "file extension must be a String but get |#{file_extention}|"
    unless _.isFunction processor_fn
      throw TypeError "processor must be a Function but get |#{processor_fn}|"

    processor_obj = {}
    processor_obj[file_extention] = processor_fn

    @_di_cont_obj_.addComponentsSettings 'FileProcessor' , 'third_party_compilers', processor_obj
    this

  ###
  This internal method used to configure components in DiC
  ###
  _configureComponents : ->
    ###
    set packer settings, default setting are
    
    strict        : on
    inject        : on
    runtime       : off
    cache_modules : on
    ###
    packer_settings = 
      log : !!@_options_.log

    for setting_name in ['strict', 'inject', 'runtime', 'cache_modules']
      if @_options_[setting_name]?
        packer_settings[setting_name] = @_options_[setting_name]
    @_di_cont_obj_.setComponentsSettings Packer : packer_settings

    null

  ###
  This internal method to compose bundle settings from package_name, package_config
  backward compatibility and new feature in one place
  ###
  _composePackageSettings : (in_settings) ->
    # we are may have one ore two keys, and first one may be omitted, 
    # to get second one in any case we are should reverse arguments
    in_settings.reverse()
    [ package_config, package_name ] = in_settings

    if package_name? and not package_config.package_name?
      console.info 'Depricated! Use "package_name" in package_config instead!'
      package_config.package_name = package_name

    package_config

