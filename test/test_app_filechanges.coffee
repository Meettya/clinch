###
This test to ensure that clinch recognize files changes

I should to be know about my optimization still support on-the-fly changes
###

_ = require 'lodash'

fs = require 'fs-extra'
vm = require 'vm'

# we are will create temporary copy for our test
# Automatically track and cleanup files at exit
temp = require('temp') #.track()

fixtureRoot  = __dirname + "/fixtures"
fixturesJade = fixtureRoot + '/jade_powered'
fixturesEcon = fixtureRoot + '/econ_powered'
fixturesHandlebars = fixtureRoot + '/handlebars_powered'
fixturesWebShims = fixtureRoot + '/web_modules'
fixtureDefault = fixtureRoot + '/default'
fixturesUniqueGeneratorParent = fixtureDefault + '/unique_generator_parent'
fixturesSingle = fixtureDefault + '/substractor'

lib_path = GLOBAL?.lib_path || ''

# change to app, for test
Clinch = require "#{lib_path}app"

# for third party processor check
Eco = require 'eco'
Handlebars = require 'handlebars'

describe 'Clinch support file changes:', ->

  clinch_obj = package_config = null
  tempFixteresRoot = tempfixtureDefault = tempfixturesSingle = tempfixturesSingleNew = null

  copyTempFiles = (tmp_root, cb) ->
    fs.copy fixtureDefault, "#{tmp_root}/default", (err) ->
      return cb Error err if err?
      cb null, yes

  createTempDir = (cb) ->
    temp.mkdir 'clinch_test', cb

  changeFileContent = (src_path, dst_path, cb) ->
    reader = fs.createReadStream "#{src_path}.js"
    writer = fs.createWriteStream "#{dst_path}.js"
    writer.on 'finish', cb
    reader.pipe writer

  beforeEach (done) ->

    clinch_obj = new Clinch
    createTempDir (err, tmp_root) ->
      throw Error err if err?

      tempFixteresRoot      = tmp_root
      tempfixtureDefault    = tempFixteresRoot + '/default'
      tempfixturesSingle    = tempfixtureDefault + '/substractor'
      tempfixturesSingleNew = tempfixtureDefault + '/substractor_new'

      copyTempFiles tmp_root, (err, isOk) ->
        throw Error err if err?
        if isOk then done()

  it 'should re-build package if file changes', (done) ->

    package_config = 
      bundle : 
        substractor : tempfixturesSingle
      package_name : 'my_package'

    res_fn2 = (err, code) ->
      # console.log code
      expect(err).to.be.null
      # oh, its better than eval :)
      vm.runInNewContext code, sandbox = {}

      {substractor, substractor_new} = sandbox.my_package.substractor
      (substractor 10, 2).should.to.be.equal 8

      (substractor_new 10, 2).should.to.be.equal 18

      done()

    second_step = ->
      clinch_obj.buildPackage package_config, res_fn2

    changes_prepare = ->
      changeFileContent tempfixturesSingleNew, tempfixturesSingle, second_step

    res_fn = (err, code) ->
      # console.log code
      expect(err).to.be.null
      # oh, its better than eval :)
      vm.runInNewContext code, sandbox = {}

      {substractor} = sandbox.my_package.substractor
      (substractor 10, 2).should.to.be.equal 8

      # Mac OS X mtime granularity 1000 ms :(
      setTimeout changes_prepare, 1100

    clinch_obj.buildPackage package_config, res_fn
