###
Test suite for node AND browser in one file
So, we are need some data from global
Its so wrong, but its OK for test
###
# resolve require from [window] or by require() 
_ = @_ ? require 'lodash'

util = require 'util'

async = require 'async'

fs = require 'fs'

fixtureRoot  = __dirname + '/../test' + "/fixtures"
fixtures     = fixtureRoot + "/default"
fixturesFile = fixtures + "/summator"
fixturesNpm  = fixtureRoot + "/node_modules/summator"
fixturesSingle = fixtures + '/substractor'
fixturesTwoChild = fixtureRoot + '/two_children'
fixturesPrinter = fixtureRoot + '/with_printf'
fixturesReplacer = fixtureRoot + '/replacer'
fixturesWithCore = fixtureRoot + '/with_core'
fixturesWebShims = fixtureRoot + '/web_modules'
fixturesFaled = fixtureRoot + "/with_syntax_error"

# change to app, for test
lib_path = '../src/'
Clinch = require "#{lib_path}app"
clinch_obj = new Clinch


package_config = 
  package_name : 'my_package'
  bundle : 
    substractor : fixturesSingle
    summator    : fixturesNpm
    main        : fixturesPrinter
    cored       : fixturesWithCore
  environment : 
    printer : fixturesTwoChild
  replacement :
    './power' : fixturesReplacer
  requireless : [
    'lodash'
  ]

step_fn = (n, next) ->
  console.time "step_#{n}"

  clinch_obj.buildPackage package_config, (err, code) ->

    console.timeEnd "step_#{n}"
    next err, code

console.time 'general'

idx = 0
save_fn = (data, acb) ->
  fs.writeFile "data_#{idx++}.js", data, encoding :'utf8', acb

async.timesSeries 10, step_fn, (err, res) ->

  console.log "is result same -", _.isEqual res[0], res[1]

  # sametime its show not same result, but its only file resolutions order, nothing more
  ###
  unless _.isEqual res[0], res[1]

    async.each res, save_fn, (err) ->
      return console.log err if err?
      console.log 'all_saved!'
  ###
  

  console.log "\ndone steps #{res.length}"
  console.timeEnd 'general'

