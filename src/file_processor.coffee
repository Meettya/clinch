###
This class compile and load files
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'

XXHash  = require 'xxhash' # ultra-mega-super fast hasher

# our add-on parsers
CoffeeScript  = require 'coffee-script'
Eco           = require 'eco'
Jade          = require 'jade'

###
Checker method decorator
###
rejectOnInvalidFilenameType = (methodBody) ->
  (filename, cb) ->
    unless _.isString filename
      return cb TypeError """
                must be called with filename as String, but got:
                |filename| = |#{filename}|
                """
    methodBody.call @, filename, cb

class FileProcessor

  HASH_SALT = 0xCAFEBABE # not sure what it is but looks its work :)

  CS_BARE = yes # use bare to compile without a top-level function wrapper

  constructor: (@_options_={}) ->
    @_compilers_ = @_getAsyncCompilers @_getJadeSettings @_options_.jade
    # and add third party compilers
    _.assign @_compilers_, @_options_.third_party_compilers

  ###
  This method load one file and, if it needed, compile it
  ###
  loadFile : (rejectOnInvalidFilenameType (filename, cb) ->

    file_ext = path.extname filename
    if @_compilers_[file_ext]?
      fs.readFile filename, 'utf8', (err, data) =>
        return cb err if err
        @_compilers_[file_ext] @_stripBOM(data), filename, (err, result, must_be_parsed) ->
          return cb err if err
          # TODO! add show_filename to settings and it works here
          res = "\n// #{filename} \n" + result
          cb null, res, must_be_parsed
    else
      cb null, false
  
    )

  ###
  This method generate digest for file content
  ###
  getFileDigest : (rejectOnInvalidFilenameType (filename, cb) ->
    
    hasher = new XXHash HASH_SALT

    stream = fs.createReadStream filename
    stream.on 'data',   (data)  -> hasher.update data
    stream.on 'error',  (err)   -> cb err
    stream.on 'end',            -> cb null, hasher.digest()

    )

  ###
  This method return supported extentions
  ###
  getSupportedFileExtentions : ->
    _.keys @_compilers_

  ###
  This method from node.js lib/module
  // Remove byte order marker. This catches EF BB BF (the UTF-8 BOM)
  // because the buffer-to-string conversion in `fs.readFileSync()`
  // translates it to FEFF, the UTF-16 BOM.
  ###
  _stripBOM : (content) ->
    if content.charCodeAt(0) is 0xFEFF then content.slice(1) else content

  ###
  This internal method for Jade settings
  ###
  _getJadeSettings : (options = {})->
    # looks strange, but all ok - main options, user, add-on
    _.defaults {client: on}, options, pretty: on, self: on, compileDebug: off

  ###
  This is Async compilers list.
  @return - error, data, isRealCode (ie. may have 'require' and should to be processed) 
  ###
  _getAsyncCompilers : (jade_settings) ->

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
      content = Jade.compile data, _.assign jade_settings, {filename}
      cb null, "module.exports = #{content}"


module.exports = FileProcessor


