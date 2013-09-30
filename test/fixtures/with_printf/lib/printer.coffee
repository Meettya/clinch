###
This module is example for full concept
Pointless, but funny
###

{sprintf} = require 'sprintf-js'
dateFormat = require 'dateformat'

class Printer
  constructor: (@_format_) ->

  printFormatted : (data) ->
    sprintf @_format_, data

  printDateFormatted : (date, mask) ->
    dateFormat date, mask

module.exports = Printer

