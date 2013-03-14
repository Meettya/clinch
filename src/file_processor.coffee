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
    @_compillers_ = @_getAsyncCompilers()

  ###
  This method load one file and, if it needed, compile it
  ###
  loadFile : (rejectOnInvalidFilenameType (filename, cb) ->

    file_ext = path.extname filename
    if @_compillers_[file_ext]?
      @_compillers_[file_ext] filename, (err, data, must_be_parsed) ->
        return cb err if err
        cb null, data, must_be_parsed
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
    _.keys @_compillers_

  ###
  This method from node.js lib/module
  // Remove byte order marker. This catches EF BB BF (the UTF-8 BOM)
  // because the buffer-to-string conversion in `fs.readFileSync()`
  // translates it to FEFF, the UTF-16 BOM.
  ###
  _stripBOM : (content) ->
    if content.charCodeAt(0) is 0xFEFF then content.slice(1) else content

  ###
  This is Async compilers list.
  @return - error, data, isRealCode (ie. may have 'require' and need to be processed) 
  ###
  _getAsyncCompilers : ->
    # dont want to bind all callbacks
    stripBOM = @_stripBOM
    jade_settings = @_options_.jade or {}

    '.js'     : (filename, cb) ->
      fs.readFile filename, 'utf8', (err, data) ->
        return cb err if err
        res = "\n// #{filename} \n" + stripBOM(data)
        cb null, res, yes

    '.json'   : (filename, cb) ->
      fs.readFile filename, 'utf8', (err, data) ->
        return cb err if err
        res = "\n// #{filename} \n" + "module.exports = #{stripBOM(data)}"
        cb null, res

    '.coffee' : (filename, cb) ->
      fs.readFile filename, 'utf8', (err, data) ->
        return cb err if err
        res = "\n// #{filename} \n" + CoffeeScript.compile(stripBOM(data), bare: CS_BARE)
        cb null, res, yes
    
    '.eco'    : (filename, cb) ->
      fs.readFile filename, 'utf8', (err, data) ->
        return cb err if err
        content = Eco.precompile stripBOM(data)
        res = "\n// #{filename} \n" +  "module.exports = #{content}"
        cb null, res       

    '.jade'   : (filename, cb) ->
      fs.readFile filename, 'utf8', (err, data) ->
        return cb err if err

        options = 
          client: on
          filename : filename

        add_on_options = 
          pretty : on
          self : on
          compileDebug : off  

        # looks strange, but all ok - main options, user, add-on
        _.defaults options, jade_settings, add_on_options

        content = Jade.compile stripBOM(data), options
        res = "\n// #{filename} \n" +  "module.exports = #{content}"
        cb null, res



module.exports = FileProcessor


