###
This method will calculate digests
###
_         = require 'lodash'
fs        = require 'fs'
crypto    = require 'crypto'    # standart module
shorthash = require 'shorthash' # to shorten our hex hashes

{rejectOnInvalidFilenameType} = require './checkers'

class DigestCalculator

  HASH_TYPE   = 'md5'
  DIGEST_TYPE = 'hex'

  constructor: (@_options_={}) ->

  ###
  This method generate digest for file content
  ###
  readFileDigest : (rejectOnInvalidFilenameType (filename, cb) ->
    
    hasher = crypto.createHash HASH_TYPE

    stream = fs.createReadStream filename
    stream.on 'data',   (data)  -> hasher.update data
    stream.on 'error',  (err)   -> cb err
    stream.on 'end',            -> cb null, shorthash.unique hasher.digest DIGEST_TYPE

    )

  ###
  This method generate digest for any data
  ###
  calculateDataDigest : (in_data) ->

    hasher = crypto.createHash HASH_TYPE

    unless _.isString in_data
      in_data = in_data?.toString()

    hasher.update in_data, 'utf8'
    shorthash.unique hasher.digest DIGEST_TYPE

module.exports = DigestCalculator