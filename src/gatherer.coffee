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

# for debug purposes 
util = require 'util'

# and all togehter!
Resolver      = require 'async-resolve'
FileProcessor  = require './file_processor'

class Gatherer

  constructor: (@_options_={}) ->
    @_file_processor_ = new FileProcessor()

    @_pathfinder_ = new Resolver()
    @_pathfinder_.addExtensions '.coffee', '.eco'

    @_filter_list_      = []
    @_requireless_list_ = []


  ###
  This is filter setter, list of regexps, matched file will be EXCLUDED
  ###
  addFilters : (filter_list...) -> 
    @_filter_list_ = @_filter_list_.concat _.map filter_list, (val) ->
      if _.isRegExp val then val else new RegExp val
    this

  ###
  This method will set lists of files to exclude it from require-loockup
  Its needed for speedup bundle bulder with hige pre-bilded packages, like |lodash| 
  ###
  addRequireless : (requireless_list...) ->
    @_requireless_list_ = @_requireless_list_.concat _.map requireless_list, (val) ->
      if _.isRegExp val then val else new RegExp val
    this   

  ###
  This method return actual filter list
  ###
  getFilters : ->
    @_filter_list_

  getRequireless : ->
    @_requireless_list_

  ###
  This is Async version of packer
  ###
  buildModulePack : (path_name, main_cb) ->
    # then fill up chache for async logic
    pack_cache = 
      dependencies_tree : {}
      names_map : {}
      source_code : {}
      main_cb : main_cb # I need it in queue_fn to add new files to queue

    pack_cache.queue_obj = load_queue = async.queue @_queueFn, 50 # by now for ensure all ok

    load_queue.drain = =>
      main_cb null, 
        dependencies_tree : pack_cache.dependencies_tree
        names_map : pack_cache.names_map
        source_code : pack_cache.source_code

    load_queue.push 
      path_name : path_name
      parent    : '.'
      pack_cache : pack_cache
      , (err) ->
        main_cb err if err

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
        @_getFileDataAndMeta real_file_name, path_name, waterfall_cb

      # 3. save data and, if it real code, search for requires in it
      ({digest, content, real_file_name, path_name}, waterfall_cb) =>
        [data, may_have_reqire] = content

        # just ave all to result obj
        @_fileDataSaver {digest, data, real_file_name, pack_cache}

        # and add new files to queue if it have `requires`
        @_findRequiresAndAddToQueue {may_have_reqire, data, real_file_name, path_name, pack_cache}

        # all done
        waterfall_cb()
      ], (err) => queue_cb err # this is the end of waterfall

  ###
  This method searching for requires, its just stub.
  later I re-write it to class
  to subsitute detective with myown logic and acorn
  ###
  _findRequiresItself : (data) ->
    detective data
  ###
  This method find requires in files, if they need it and 
  add to queue new files for recurse working
  ###
  _findRequiresAndAddToQueue : ({may_have_reqire, data, real_file_name, path_name, pack_cache}) =>
    # and add new files to queue if it have `requires`
    if may_have_reqire is yes and @_isFilesMustBeProcessed @_requireless_list_, path_name, real_file_name
      for child in @_findRequiresItself data

        pack_cache.queue_obj.push
          path_name : child
          parent : real_file_name
          pack_cache : pack_cache
          , (err) ->
            pack_cache.main_cb err if err

        null
    null

  ###
  This method get content and meta for filename
  ###
  _getFileDataAndMeta : ( real_file_name, path_name, waterfall_cb ) ->

    # get content and digest, it simplest do it parallel
    async.parallel
      # 2.1 get file digest 
      digest : (parallel_cb) =>
        @_file_processor_.getFileDigest real_file_name, parallel_cb
      # 2.2 get file content and its (content) properties
      content : (parallel_cb) =>
        @_file_processor_.loadFile real_file_name, parallel_cb
      # 2.3 just re-send data to next step
      real_file_name : (parallel_cb) ->
        parallel_cb null, real_file_name
      # 2.4 just re-send data to next step
      path_name : (parallel_cb) ->
        parallel_cb null, path_name

      , waterfall_cb # and parallel and, send all to next step

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
    unless @_isFilesMustBeProcessed @_filter_list_, path_name, real_file_name
      # dependencies itself exists, but filtered out
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
  _isFilesMustBeProcessed : (filters_list, files_list...) ->
   ! _.any files_list, (filename) ->
     _.any filters_list, (filter_re) ->
      filter_re.test filename 


module.exports = Gatherer

