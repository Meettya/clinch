###
This is command library

to wipe out Cakefile from realization 
###

path          = require 'path'
fs            = require 'fs'
{spawn, exec} = require 'child_process'

# add color to console
module.exports = require './colorizer'

###
Just proc extender
###
proc_extender = (cb, proc) =>
  proc.stderr.on 'data', (buffer) -> console.log "#{buffer}".error
  # proc.stdout.on 'data', (buffer) -> console.log  "#{buffer}".info
  proc.on        'exit', (status) ->
    process.exit(1) if status != 0
    cb() if typeof cb is 'function' 
  null

# Run a CoffeeScript through our node/coffee interpreter.
run_coffee = (args, cb) =>
  proc_extender cb, spawn 'node', ['./node_modules/.bin/coffee'].concat args

###
Generate array of files from directory, selected on filter as RegExp
###
make_files_list = (in_dir, filter_re) ->
  for file in fs.readdirSync in_dir when file.match filter_re
    path.join in_dir, file 

###
CoffeeScript-to-JavaScript builder
###
build_coffee = (cb, source_dir, result_dir, filter) ->
  files = make_files_list source_dir, filter
  run_coffee ['-c', '-o', result_dir].concat(files), ->
    console.log ' -> build done'.info
    cb() if typeof cb is 'function' 
  null


module.exports = 
  build_coffee        : build_coffee


