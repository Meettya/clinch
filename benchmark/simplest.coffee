#!/usr/bin/env coffee

###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
# resolve require from [window] or by require() 
_ = @_ ? require 'lodash'

fs = require 'fs'

fixtureRoot       = __dirname + '/../test' + "/fixtures"
fixtures          = fixtureRoot + "/default"
fixturesSingle    = fixtures + '/substractor'
fixturesTwoChild  = fixtureRoot + '/two_children'

# change to app, for test
lib_path = '../src/'
Clinch = require "#{lib_path}app"
clinch_obj = new Clinch

package_config = 
  package_name : 'my_package'
  bundle :
    printer     : fixturesTwoChild

console.time 'general'
console.time 'first'

clinch_obj.buildPackage package_config, (err, code) ->
  if err? 
    return console.error err

  console.timeEnd 'first'
  console.log "-> first ok!\n"
  console.time 'second'

  clinch_obj.buildPackage package_config, (err, code) ->
    if err? 
      return console.error err

    console.timeEnd 'second'
    console.log "-> second ok!\n"
    console.timeEnd 'general'
    console.log "-> all ok!\n"


