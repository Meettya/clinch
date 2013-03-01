###
This example must test code, uses core modules
###

util = require 'util'

formatter = (format, args...) ->

  util.format format, args...

module.exports = {
  formatter
}