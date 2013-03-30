###
This method will load file, cache result and so on
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
async   = require 'async'

XXHash  = require 'xxhash' # ultra-mega-super fast hasher

LRU     = require 'lru-cache'


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


class FileLoader

  HASH_SALT = 0xCAFEBABE # not sure what it is but looks its work :)

  # this is cache max_age, huge because we are have brutal invalidator now
  MAX_AGE = 1000 * 60 * 60 * 10 # yes, 10 hours

  constructor: (@_options_={}) ->
    # this big cache for all our files, work on size and so on
    @_file_cache_ = LRU max : 1000, maxAge: MAX_AGE

  ###
  This method try to get file content from hash or give up and read it from disk
  ###
  getFileContent : (rejectOnInvalidFilenameType (filename, cb) ->
    @getFileWithMeta filename, (err, data) ->
      return cb err if err
      cb null, data.content
    )

  ###
  This method, get all - content and meta for filename
  ###
  getFileWithMeta : (rejectOnInvalidFilenameType (filename, cb) ->

    # first step - see to _file_cache_ or just load all
    unless @_file_cache_.has filename
      console.log "cache miss #{filename}"
      @_loadAllFileData filename, (err, data) =>
        return cb err if err
        # save all to cache
        @_file_cache_.set filename, data
        return cb null, data
    # or if file in cache - try to use it, with multi-level validation
    else
      console.log "cache exist #{filename}"
      cached_file = @_file_cache_.get filename
      # first step - compare meta
      @readFileMeta filename, (err, meta) =>
        return cb err if err
        # if file not changed - just return it
        if cached_file.meta.mtime is meta.mtime
          console.log 'mtime hit'
          return cb null, cached_file
        # or try to compare digests
        else
          @readFileDigest filename, (err, digest) =>
            return cb err if err
            # if file not changed - just return it
            if cached_file.digest is digest
              console.log 'digest hit'
              # update meta part
              cached_file.meta = meta
              @_file_cache_.set filename, cached_file
              return cb null, cached_file
            # ok, all go wrong - just re-read file content
            else
              @readFile filename, (err, content) =>
                return cb err if err
                # update all file data
                new_file = {meta, digest, content}
                @_file_cache_.set filename, new_file
                return cb null, new_file
    )

  ###
  This internal method to load all file data
  ###
  _loadAllFileData : (filename, step_cb) ->
    async.parallel
      meta : (parallel_cb) =>
        @readFileMeta filename, parallel_cb
      digest : (parallel_cb) =>
        @readFileDigest filename, parallel_cb
      content : (parallel_cb) =>
        @readFile filename, parallel_cb
      , step_cb # and parallel and, send all to next step

  ###
  This method just read a file, from disk
  ###
  readFile : (rejectOnInvalidFilenameType (filename, cb) ->
    fs.readFile filename, 'utf8', (err, data) ->
      return cb err if err
      cb null, data
    )

  ###
  This method read all file meta
  ###
  readFileMeta : (rejectOnInvalidFilenameType (filename, cb) ->
    fs.stat filename, (err, stats) ->
      return cb err if err
      cb null, mtime : +stats.mtime
    )

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


module.exports = FileLoader