###
This is simple test case for Handlebars-powered template engine 
must work in browser only (or browser emulation, see /test/test_app)
may be used as example
###

module.exports = class HandlebarsPowered
  # empty in example
  constructor : ->

  ###
  This method render results with Handlebars template and given data
  ###
  renderData : (data) ->
    # get precompiled template
    template_fn = require './template'
    # add it to Handlebars mmm... stack?
    template = Handlebars.template template_fn
    # profit!
    res = template data