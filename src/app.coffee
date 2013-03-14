###
This is main entry point for Clinch - API and setting here
###

# its our registry
DIContainer = require "./di_container"

class Clinch 
  constructor: (@_options_={}) ->
    # for debugging 
    @_do_logging_ = if @_options_.log? and @_options_.log is on and console?.log? then yes else no
    @_registry_obj_ = new DIContainer()
    
  ###
  This method create browser package with given configuration
  actually its just proxy all to packer
  ###
  buldPackage : (args...) ->
    packer = @_registry_obj_.getComponent 'Packer'
    packer.buldPackage args...

  ###
  This method force flush cache
  ###
  flushCache : ->
    gatherer = @_registry_obj_.getComponent 'Gatherer'
    gatherer.resetCaches()

module.exports = Clinch