###
This is simple test case for Jade-powered template engine
must work in node AND in browser
may be used as example
###

###
this two must be reqiured for node
if you prefer have all require() in file head (an I think it good habit)
- you need to REPLACE it in clinch settings, not exclude!!!
###
fs = require 'fs'
jade = require 'jade'

module.exports = class JadePowered
  # empty in example
  constructor : ->

  ###
  This method render results with jade template and given data
  Its dual-headed version, works in node and in browser
  ###
  renderData : (data) ->

    # clinch will emulate module, but NOT emulate module.id
    template_fn = if module.id

      # if we are here - its node env and we are should build template
      template_name = "#{__dirname}/template.jade"
      template = fs.readFileSync template_name, 'utf8'

      # its very close to clinch default settings for jade
      options = 
        pretty : on
        self : on
        filename : template_name

      jade.compile template, options

    # unless module.id  - its clinched (browser version) code
    else
      # just require it and it will be done
      require './template'


    res = template_fn data