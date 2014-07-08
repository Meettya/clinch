###
This class compile and load files
###

path    = require 'path'
_       = require 'lodash'

# our add-on parsers
CoffeeScript  = require 'coffee-script'
Eco           = require 'eco'
Jade          = require 'jade'
React         = require 'react-tools'

# for compiled cache
LRU     = require 'lru-cache'

{rejectOnInvalidFilenameType} = require './checkers'
{queueSomeRequest}            =  require './queuficator'


module.exports = class FileProcessor

  CS_BARE = yes # use bare to compile without a top-level function wrapper

  # this is cache max_age, huge because we are have brutal invalidator now
  MAX_AGE = 1000 * 60 * 60 * 10 # yes, 10 hours

  constructor: (@_file_loader_, @_options_={}) ->
    # this big cache for all our files, work on size and so on
    @_compiled_cache_ = LRU max : 1000, maxAge: MAX_AGE

    @_compilers_ = @_getAsyncCompilers @_getCompillersSettings @_options_
    # and add third party compilers
    _.assign @_compilers_, @_options_.third_party_compilers

  ###
  This method load one file and, if it needed, compile it
  ###
  loadFile : (rejectOnInvalidFilenameType queueSomeRequest (filename, cb) ->

    file_ext = path.extname filename
    if @_compilers_[file_ext]?
      @_file_loader_.getFileWithMeta filename, (err, data) =>
        return cb err if err

        digest = data.digest
        # will check by digest only
        unless @_compiled_cache_.has digest
          #console.log 'FileProcessor cache miss'
          content = data.content
          @_compilers_[file_ext] @_stripBOM(content), filename, (err, result, must_be_parsed) =>
            return cb err if err
            # TODO! add show_filename to settings and it works here
            res = "\n// #{filename} \n" + result
            @_compiled_cache_.set digest, { must_be_parsed, compiled_data : res }
            cb null, res, must_be_parsed, {digest}
        else
          #console.log 'FileProcessor cache hit'

          res = @_compiled_cache_.get digest
          cb null, res.compiled_data, res.must_be_parsed, {digest}
    else
      # TODO @add log level 
      console.warn "missing |#{file_ext}| processor for file |#{filename}|"
      cb null, false
  
    )

  ###
  This method return supported extentions
  ###
  getSupportedFileExtentions : ->
    _.keys @_compilers_

  ###
  This method reset all caches
  ###
  resetCaches : ->
    @_compiled_cache_.reset()
    null

  ###
  This method from node.js lib/module
  // Remove byte order marker. This catches EF BB BF (the UTF-8 BOM)
  // because the buffer-to-string conversion in `fs.readFileSync()`
  // translates it to FEFF, the UTF-16 BOM.
  ###
  _stripBOM : (content) ->
    if content.charCodeAt(0) is 0xFEFF then content.slice(1) else content

  ###
  This method return whole compillers settings
  ###
  _getCompillersSettings: (options={}) ->
    jade_settings  : @_getJadeSettings   options.jade
    react_settings : @_getReactSettings  options.react

  ###
  This internal method for Jade settings
  ###
  _getJadeSettings : (options = {})->
    # looks strange, but all ok - main options, user, add-on
    _.defaults options, pretty: on, self: on, compileDebug: off

  ###
  This internal method for React settings
  ###
  _getReactSettings : (options = {})->
    _.defaults options, harmony: off

  ###
  This is Async compilers list.
  @return - error, data, isRealCode (ie. may have 'require' and should to be processed) 
  ###
  _getAsyncCompilers : ({jade_settings, react_settings}) ->

    '.js'     : (data, filename, cb) ->
      cb null, data, yes

    '.json'   : (data, filename, cb) ->
      cb null, "module.exports = #{data}"

    '.coffee' : (data, filename, cb) ->
      content = CoffeeScript.compile data, bare: CS_BARE
      cb null, content, yes
    
    '.eco'    : (data, filename, cb) ->
      content = Eco.precompile data
      cb null, "module.exports = #{content}"

    '.jade'   : (data, filename, cb) ->
      content = Jade.compileClient data, _.assign jade_settings, {filename}
      cb null, "module.exports = #{content}"

    '.jsx'    : (data, filename, cb) ->
      content = React.transform data, react_settings
      cb null, content, yes

    '.csbx'    : (data, filename, cb) ->
      pre_content = CoffeeScript.compile data, bare: CS_BARE
      content     = React.transform pre_content, react_settings
      cb null, content, yes


