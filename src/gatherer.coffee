###
This class build whole codebase for path

Короче, здесь у нас модуль, который получает на вход 
путь и возвращает полный комплект из путей (для разрешения require)
и скомпилированное содерживое файлов

Над форматом  сильно много думать, думаеццо надо в комплекте с ресолвингом
решать, как будет удобнее, так что пока формат ПЛАВАЮЩИЙ!!! 
Был предупрежден? Свободен!
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
async   = require 'async'

# temporary its here
detective = require 'detective'

# for cache
#TODO may be change to LRU later
AsyncCache = require 'async-cache'

LRU     = require 'lru-cache'

# for debug purposes 
util = require 'util'

# and all togehter!
Resolver      = require 'async-resolve'
FileProcessor  = require './file_processor'

class Gatherer

  # this is cache max_age, huge because we are have brutal invalidator now
  MAX_AGE = 1000 * 60 * 60 * 10 # yes, 10 hours

  constructor: (@_options_={}) ->
    @_file_processor_ = new FileProcessor()

    @_pathfinder_ = new Resolver()
    @_pathfinder_.addExtensions '.coffee', '.eco', '.jade'

    # its heavy cache with file content
    @_loader_cache_ = @_buildLoaderCache()
    # and its light cache with parsing results (search for require)
    @_require_cache_ = LRU max : 1000, maxAge: MAX_AGE

  ###
  This method reset all caches
  ###
  resetCaches : ->
    @_loader_cache_.reset()
    @_require_cache_.reset()
    null

  ###
  This is Async version of packer
  ###
  buildModulePack : (path_name, options={}, main_cb) ->
   
    #console.log 'buildModulePack options', options
    # then fill up chache for async logic
    pack_cache = 
      dependencies_tree : {}
      names_map : {}
      source_code : {}
      err : null
      filters : []
      requireless : []

    # add filters
    if options.filters?
      pack_cache.filters = @_forceFilterToArray options.filters
    # and requireless
    if options.requireless?
      pack_cache.requireless = @_forceFilterToArray options.requireless

    pack_cache.queue_obj = load_queue = async.queue @_queueFn, 50 # by now for ensure all ok

    load_queue.drain = =>
      unless pack_cache.err
        main_cb null, 
          dependencies_tree : pack_cache.dependencies_tree
          names_map : pack_cache.names_map
          source_code : pack_cache.source_code
      else
        main_cb pack_cache.err

    load_queue.push 
      path_name : path_name
      parent    : '.'
      pack_cache : pack_cache
      , (err) ->
        pack_cache.err = err
  ###
  Oh!
  Many things here, but its price of async code
  ###
  _queueFn : ({path_name, parent, pack_cache}, queue_cb) =>

    # "- Run, Fores, run!!!""
    async.waterfall [
      # 1.resolve real filename
      (waterfall_cb) =>
        @_pathfinder_.resolveAbsolutePath path_name, path.dirname(parent), waterfall_cb
      # 2. load source and compile it to js + get some meta data
      (real_file_name, waterfall_cb) =>
        # save all to tree, if some data exists - its return false
        unless @_dependenciesTreeSaver {path_name, parent, real_file_name, pack_cache}
          return queue_cb() # <---- YES! we are jamping out the train

        # get all data and meta than go to next step
         @_getFromCacheWithValidation real_file_name, (err, data) ->
          return waterfall_cb err if err
          waterfall_cb null, data.digest, data.content, {path_name, real_file_name}

      # 3. save data and, if it real code, search for requires in it
      (digest, content, {real_file_name, path_name}, waterfall_cb) =>
        [data, may_have_reqire] = content

        # just ave all to result obj
        @_fileDataSaver {digest, data, real_file_name, pack_cache}

        # and add new files to queue if it have `requires`
        @_findRequiresAndAddToQueue {may_have_reqire, data, real_file_name, path_name, pack_cache}

        # all done
        waterfall_cb()
      ], (err) => queue_cb err # this is the end of waterfall

  ###
  This internal method for loaders cache, to slow get it from disk
  YES, it will be needed to implement cache invalidator :(
  ###
  _buildLoaderCache : () ->
    new AsyncCache
      # options passed directly to the internal lru cache
      max: 100
      maxAge: MAX_AGE
      # method to load a thing if it's not in the cache.
      # key must be unique in the context of this cache.
      load : (key, cb) =>
        @_getFileDataAndMeta key, cb


  ###
  This is converter for ensure filter is Array
  @arg may be one value or Array
  ###
  _forceFilterToArray : (first_filter, other_filters...) -> 
    # 
    filters_list = unless _.isArray first_filter
      [first_filter].concat other_filters
    else
      first_filter

  ###
  This method get data and meta from cache with cache validation
  At now try to use re-calculated file hash
  ###
  _getFromCacheWithValidation : (real_file_name, meth_cb) ->
    # just get current data and all data from cache, and compare caches
    async.parallel

      current_digest : (parallel_cb) =>
        @_file_processor_.getFileDigest real_file_name, parallel_cb

      all_data : (parallel_cb) =>
        @_loader_cache_.get real_file_name, parallel_cb

    , (err, data) =>
      return meth_cb err if err

      # ok, now compare current file digest and cached
      if data.current_digest is data.all_data.digest
        # just return if all ok
        meth_cb null, data.all_data
      else
        # console.log 'data.current_digest and data.all_data.digest missmatch, ', data.current_digest, data.all_data.digest
        # or reset all caches and re-read data
        @resetCaches()
        @_loader_cache_.get real_file_name, meth_cb

  ###
  This method searching for requires, its just stub.
  later I re-write it to class
  to substitute detective with my own logic and acorn
  ###
  _findRequiresItself : (data) ->
    detective data
  ###
  This method find requires in files, if they need it and 
  add to queue new files for recurse working
  ###
  _findRequiresAndAddToQueue : ({may_have_reqire, data, real_file_name, path_name, pack_cache}) =>
    # and add new files to queue if it have `requires`
    if may_have_reqire is yes and @_isFilesMustBeProcessed pack_cache.requireless, path_name

      # try to get all by cache
      childrens = unless @_require_cache_.has real_file_name
        #console.log 'cache miss', real_file_name
        res = @_findRequiresItself data
        @_require_cache_.set real_file_name, res
        res
      else
        #console.log 'cache hit', real_file_name
        @_require_cache_.get real_file_name

      for child in childrens

        pack_cache.queue_obj.push
          path_name : child
          parent : real_file_name
          pack_cache : pack_cache
          , (err) ->
            pack_cache.err = err

        null
    null

  ###
  This method get content and meta for filename
  ###
  _getFileDataAndMeta : ( real_file_name, step_cb ) ->

    # get content and digest, it simplest do it parallel
    async.parallel
      # 2.1 get file digest 
      digest : (parallel_cb) =>
        @_file_processor_.getFileDigest real_file_name, parallel_cb
      # 2.2 get file content and its (content) properties
      content : (parallel_cb) =>
        @_file_processor_.loadFile real_file_name, parallel_cb
      , step_cb # and parallel and, send all to next step

  ###
  This part-method handle save to tree
  if file exists or unnided - return false
  ###
  _dependenciesTreeSaver : ({path_name, parent, real_file_name, pack_cache}) =>

    dep_tree_par = pack_cache.dependencies_tree[parent] ?= {}
    # avoid unneeded work, BUT do not do that - 'or pack_cache.names_map[real_file_name]?'
    # or you got 'race conditions'-like problem and all go wrong
    # 'repiting buildModulePack() must return some data' test case about it
    if dep_tree_par[path_name]?
      return false
    # try on filter each path state (alias)
    unless @_isFilesMustBeProcessed pack_cache.filters, path_name
      # dependencies itself exists, but filtered out
      dep_tree_par[path_name] = null
      return false 

    # and another one problem - node.js core modules, 
    # which returned by `resolve` as one name, not absolute path
    if @_pathfinder_.isCoreModule real_file_name
      # just save dependencies, but do not proceed code
      dep_tree_par[path_name] = null
      return false    

    dep_tree_par[path_name] = real_file_name
    true

  ###
  This method save data
  void return
  ###
  _fileDataSaver : ({digest, data, real_file_name, pack_cache}) ->
    pack_cache.names_map[real_file_name] = digest
    pack_cache.source_code[real_file_name] ?= data
    null

  ###
  This is proceed filter
  return 'true' if file MUST be processed, 
  ie it filename NOT in list - it will be processed
  ###
  _isFilesMustBeProcessed : (filters_list, path_name) ->
    ! _.any filters_list, (filter) ->
        filter is path_name 

module.exports = Gatherer

