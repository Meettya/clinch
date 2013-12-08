#!/usr/bin/env coffee

###
This is builder pack CommonJS module to browser env
###

fs = require 'fs'

root_dir = "#{__dirname}/.."

Clinch = require "#{root_dir}/../../" # it will be 'clinch' in your code
packer = new Clinch()


fixturesWebShims = "#{root_dir}/web_modules"
fixturesJadePowered = "#{root_dir}/jade_powered"

package_config = 
  bundle : 
    JadePowered : fixturesJadePowered
  replacement :
    fs : fixturesWebShims + '/noops'
    jade : fixturesWebShims + '/noops'


packer.buildPackage 'my_package', package_config, (err, data) ->
  if err
    console.log 'Builder, err: ', err
  else
    fs.writeFile "#{fixturesJadePowered}/result.js", data, 'utf8', (err) ->
      return console.log err if err
      console.log 'File saved!'
