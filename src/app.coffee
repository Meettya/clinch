###
This is main entry point for Clinch - API and setting here
###

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
  This internal method used to configure components in DiC
  ###

  ###
  jade = 
    pretty : on
    self : on
    compileDebug : off

  clinch_obj = new Clinch {jade, log : on}

  ###
  _configureComponents : ->

    # just use short-cut
    log = !!@_options_.log

    # set jade compiler settings
    if jade = @_options_.jade
      @_dic_obj_.setComponentsSettings FileProcessor : {jade, log}

    null


module.exports = Clinch