###
This method will calculate digests
###
_       = require 'lodash'
fs      = require 'fs'

XXHash  = require 'xxhash' # ultra-mega-super fast hasher

{rejectOnInvalidFilenameType} = require './checkers'

class DigestCalculator

  HASH_SALT = 0xCAFEBABE # not sure what it is but looks its work :)

  constructor: (@_options_={}) ->

  ###
  This method generate digest for file content
  ###
  readFileDigest : (rejectOnInvalidFilenameType (filename, cb) ->
    
    hasher = new XXHash HASH_SALT

    stream = fs.createReadStream filename
    stream.on 'data',   (data)  -> hasher.update data
    stream.on 'error',  (err)   -> cb err
    stream.on 'end',            -> cb null, hasher.digest()

    )

  ###
  This method generate digest for any data
  ###
  calculateDataDigest : (in_data) ->

    hasher = new XXHash HASH_SALT

    worked_data = if _.isString in_data
      new Buffer in_data
    else
      new Buffer in_data?.toString()

    hasher.update worked_data
    hasher.digest()


module.exports = DigestCalculator