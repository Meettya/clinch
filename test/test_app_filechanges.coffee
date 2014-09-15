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
fixturesTwoChild  = fixtureRoot + '/two_children'

lib_path = GLOBAL?.lib_path || ''

# change to app, for test
Clinch = require "#{lib_path}app"

# for third party processor check
Eco = require 'eco'
Handlebars = require 'handlebars'

# Mac OS X mtime granularity 1000 ms :(
TIMEOUT = 1100

describe 'Clinch support file changes:', ->

  clinch_obj = package_config = null
  tempFixteresRoot = tempfixtureDefault = tempfixturesSingle = tempfixturesSingleNew = null
  tempFixturesTwoChild = tempFixturesTwoChildIndex = tempFixturesTwoChildIndexNew = tempFixturesTwoChildIndexRes = tempFixturesTwoChildRemove = null

  copyTempFiles = (scr_dir, tmp_root, dirname, cb) ->
    fs.copy scr_dir, "#{tmp_root}/#{dirname}", (err) ->
      return cb Error err if err?
      cb null, yes

  createTempDir = (cb) ->
    temp.mkdir 'clinch_test', cb

  changeFileContent = (src_path, dst_path, ext, cb) ->
    #console.log 'changeFileContent, src_path, dst_path, ext'
    #console.log src_path, dst_path, ext
    reader = fs.createReadStream "#{src_path}.#{ext}"
    writer = fs.createWriteStream "#{dst_path}.#{ext}"
    writer.on 'finish', cb
    reader.pipe writer

  describe 'for one file', ->

    beforeEach (done) ->

      clinch_obj = new Clinch
      createTempDir (err, tmp_root) ->
        throw Error err if err?

        tempFixteresRoot      = tmp_root
        tempfixtureDefault    = tempFixteresRoot + '/default'
        tempfixturesSingle    = tempfixtureDefault + '/substractor'
        tempfixturesSingleNew = tempfixtureDefault + '/substractor_new'

        copyTempFiles fixtureDefault, tmp_root, 'default', (err, isOk) ->
          throw Error err if err?
          if isOk then done()

    it 'should re-build package if file changes', (done) ->

      @timeout 2000

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
        changeFileContent tempfixturesSingleNew, tempfixturesSingle, 'js', second_step

      res_fn = (err, code) ->
        # console.log code
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        {substractor} = sandbox.my_package.substractor
        (substractor 10, 2).should.to.be.equal 8

        # Mac OS X mtime granularity 1000 ms :(
        setTimeout changes_prepare, TIMEOUT

      clinch_obj.buildPackage package_config, res_fn

  describe 'for main file in deep structure', ->

    beforeEach (done) ->

      clinch_obj = new Clinch
      createTempDir (err, tmp_root) ->
        throw Error err if err?

        tempFixteresRoot              = tmp_root
        tempFixturesTwoChild          = tempFixteresRoot + '/two_children'
        tempFixturesTwoChildIndex     = tempFixturesTwoChild + '/index'
        tempFixturesTwoChildIndexNew  = tempFixturesTwoChild + '/index_new'
        tempFixturesTwoChildIndexRes  = tempFixturesTwoChild + '/index_reserve'
        tempFixturesTwoChildRemove    = tempFixturesTwoChild + '/processor.coffee'

        copyTempFiles fixturesTwoChild, tmp_root, 'two_children', (err, isOk) ->
          throw Error err if err?
          if isOk then done()

    it 'should re-build package if file changes (add some requires)', (done) ->

      @timeout 2000

      package_config = 
        bundle : 
          app : tempFixturesTwoChild
        package_name : 'my_package'

      res_fn2 = (err, code) ->
        # console.log code
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        #console.log 'res_fn2'
        #console.log code

        {substractor, processor} = sandbox.my_package.app
        (substractor.substractor 10, 2).should.to.be.equal 8

        #console.log 'processor.process 10,2'
        #console.log processor.process 10, 2

        (processor.process 10, 2).should.to.be.equal 20

        done()

      second_step = ->
        clinch_obj.buildPackage package_config, res_fn2

      changes_prepare = ->
        changeFileContent tempFixturesTwoChildIndexNew, tempFixturesTwoChildIndex, 'coffee', second_step

      res_fn = (err, code) ->
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        # console.log inspect sandbox.app

        {substractor} = sandbox.my_package.app.substractor
        (substractor 10, 2).should.to.be.equal 8

        expect(sandbox.my_package.processor).to.be.undefined
        
        # Mac OS X mtime granularity 1000 ms :(
        setTimeout changes_prepare, TIMEOUT

      clinch_obj.buildPackage package_config, res_fn

    it 'should re-build package if file changes (remove some requires)', (done) ->

      @timeout 3000

      package_config = 
        bundle : 
          app : tempFixturesTwoChild
        package_name : 'my_package'

      res_fn2 = (err, code) ->
        # console.log code
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        {substractor, processor} = sandbox.my_package.app
        (substractor.substractor 10, 2).should.to.be.equal 8

        (processor.process 10, 2).should.to.be.equal 20

        # Mac OS X mtime granularity 1000 ms :(
        setTimeout changes_prepare2, TIMEOUT

      res_fn3 = (err, code) ->
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        #console.log 'res_fn3'
        #console.log code

        {substractor} = sandbox.my_package.app.substractor
        (substractor 10, 2).should.to.be.equal 8

        expect(sandbox.my_package.processor).to.be.undefined

        done()

      second_step = ->
        clinch_obj.buildPackage package_config, res_fn2

      third_step = ->
        clinch_obj.buildPackage package_config, res_fn3

      changes_prepare = ->
        changeFileContent tempFixturesTwoChildIndexNew, tempFixturesTwoChildIndex, 'coffee', second_step

      changes_prepare2 = ->
        changeFileContent tempFixturesTwoChildIndexRes, tempFixturesTwoChildIndex, 'coffee', remove_unused

      remove_unused = ->
        # console.log 'remove file'
        fs.remove tempFixturesTwoChildRemove, (err) ->
          return err if err?
          third_step()

      res_fn = (err, code) ->
        expect(err).to.be.null
        # oh, its better than eval :)
        vm.runInNewContext code, sandbox = {}

        # console.log inspect sandbox.app

        {substractor} = sandbox.my_package.app.substractor
        (substractor 10, 2).should.to.be.equal 8

        expect(sandbox.my_package.processor).to.be.undefined
        
        # Mac OS X mtime granularity 1000 ms :(
        setTimeout changes_prepare, TIMEOUT

      clinch_obj.buildPackage package_config, res_fn
