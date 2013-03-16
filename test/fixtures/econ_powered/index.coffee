###
This is simple test case for Econ-powered template engine 
(like eco, but external processor)
must work in browser only
may be used as example
###

module.exports = class EconPowered
  # empty in example
  constructor : ->

  ###
  This method render results with jade template and given data
  Its dual-headed version, works in node and in browser
  ###
  renderData : (data) ->

    template_fn = require './template'

    res = template_fn data