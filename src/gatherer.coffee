###
This class build whole codebase for path

Короче, здесь у нас модуль, который получает на вход 
путь и возвращает полный комплект из путей (для разрешения require)
и скомпилированное содерживое файлов
###

fs      = require 'fs'
path    = require 'path'
_       = require 'lodash'
async   = require 'neo-async'

util    = require 'util'

# temporary its here
detective     = require 'detective'
# for cache
LRU           = require 'lru-cache'
# and all togehter!
Resolver      = require 'async-resolve'

module.exports = class Gatherer

  # this is cache max_age, huge because we are have brutal invalidator now
  MAX_AGE = 1000 * 60 * 60 * 10 # yes, 10 hours

  # its root parent for module
  ROOT_PARENT = '.'

  # Async queue concurrency
  QUEUE_CONCURRENCY = 20

  constructor: (@_digest_calculator_, @_file_processor_, @_file_loader_, @_options_={}) ->
    @_pathfinder_ = new Resolver()
    # NB! addExtensions need list, but getSupportedFileExtentions return array, so...
    @_pathfinder_.addExtensions @_file_processor_.getSupportedFileExtentions()...

    # and its light cache with parsing results (search for require)
    @_require_cache_ = LRU max : 1000, maxAge: MAX_AGE

    # this is cache for pre-ready results
    @_hard_cache_ = LRU max : 100, maxAge: MAX_AGE

  ###
  This method reset all caches
  ###
  resetCaches : ->
    @_require_cache_.reset()
    @_hard_cache_.reset()
    null

  ###
  This is 'lite' version of packer - it buld pack from function
  used in replacement as function type
  ###
  buildFunctionPack : (raw_code, main_cb) ->

    result = 
      dependencies_tree : {}
      names_map         : {}
      source_code       : {}

    # now we are have some troubles with names_map - 
    # I think we are should use dump digest -> digest map
    # looks ugly, but for consistency its good
    digest = @_digest_calculator_.calculateDataDigest raw_code

    digest_polindrome = {}
    digest_polindrome[digest] = digest

    result.dependencies_tree[ROOT_PARENT] = digest_polindrome
    result.names_map              = digest_polindrome
    result.source_code[digest]    = "\nmodule.exports = (" + raw_code?.toString() + "\n)()\n"
    
    main_cb null, result

  ###
  This is Async version of packer

  TODO @meetya add some request blocker (if builder called in sequence)
  ###
  buildModulePack : (path_name, options={}, main_cb) =>

    step_cache_name = @_getStepCache path_name, options

    # in any case result will be same :)
    done_cb = (err, data) =>
      return main_cb err if err?
      @_hard_cache_.set step_cache_name, data
      # HACK @meettya somewhere ELSE changed 'replace' list - find out and fix properly - its quickfix only!!!
      main_cb null, _.cloneDeep data

    unless @_hard_cache_.has step_cache_name
      @_buildModulePack path_name, options, step_cache_name, done_cb
    else 
      @_verifyAndBuildModulePack options, step_cache_name, done_cb

  ###
  This method calculate step cache name
  ###
  _getStepCache: (path_name, options) =>
    @_digest_calculator_.calculateDataDigest path_name + util.inspect options

  ###
  This is verified rebuilder step
  ###
  _verifyAndBuildModulePack: (options, step_cache_name, main_cb) =>
    probably_res = @_hard_cache_.get step_cache_name

    #console.log 'probably_res'
    #console.log probably_res

    # check out changed files fist
    @_getChangedFiles probably_res.names_map, (err, changed_list) =>
      # nothing changed
      unless changed_list.length
        main_cb null, probably_res
      else
        extended_options = @_extendOptionsRequireless { options, changed : changed_list, all_files : _.keys probably_res.names_map }
        @_reBuildModulePack changed_list, extended_options, step_cache_name, (err, new_data) =>
          return main_cb err if err

          # just update our pre-res
          for changed_data in new_data
            for member_key, member_value of changed_data
              _.assign probably_res[member_key], member_value

          main_cb null, @_cleanReBuildedModulePack probably_res

  ###
  This method extend options for rebuild module pack function to avoid re-calculate unchanged chidrens
  ###
  _extendOptionsRequireless: ({options, changed, all_files}) =>
    options.unchanged = _.difference all_files, changed
    options

  ###
  This is module pack rebuilder - in case something changed
  ###
  _reBuildModulePack: (changed_list, options, step_cache_name, main_cb) =>
    #console.log 'something changed!!!'
    #console.log changed_list

    map_fn = (item, acb) =>
      @_buildModulePack item, options, step_cache_name, (err, data) =>
        return acb err if err?
        # unnided in sub-request
        delete data.dependencies_tree[ROOT_PARENT] if data?.dependencies_tree?[ROOT_PARENT]?
        acb null, data

    async.map changed_list, map_fn, main_cb

  ###
  This method recursive clean up orphan elements
  ###
  _cleanReBuildedModulePack: (raw_data, prev_used_parts=[]) =>
    # so, we are just find out used parts of dependencies tree (but for child of wiped root we are need recursion)
    used_parts = _.chain raw_data.dependencies_tree
                    .values()
                    .map (elem) -> _.values elem
                    .flatten()
                    .uniq()
                    .push '.'
                    .value()

    used_parts_dict = _.reduce used_parts, ((acc, elem) -> acc[elem] = yes; acc ), {}

    for key of raw_data.dependencies_tree when not used_parts_dict[key]
      delete raw_data.dependencies_tree[key]

    unless _.isEqual prev_used_parts, used_parts
      return @_cleanReBuildedModulePack raw_data, used_parts

    # wipe out unneeded parts (this part may be used in last step)
    for key of raw_data.names_map when not used_parts_dict[key]
      delete raw_data.names_map[key]

    for key of raw_data.source_code when not used_parts_dict[key]
      delete raw_data.source_code[key]

    raw_data


  ###
  This is fast file tester - return changed files list
  ###
  _getChangedFiles: (names_map, cb) =>
    # work vector
    vec = _.keys names_map

    some_fn = (file, acb) =>
      @_file_loader_.readCachedFileDigest file, (err, res) =>
        # if something go wrong - return false to re-read data
        return acb false if err?
        return acb res is names_map[file]

    async.reject vec, some_fn, (results) ->
      cb null, results

  ###
  internal method
  ###
  _buildModulePack : (path_name, options, step_cache_name, main_cb) =>

    # console.time '_buildModulePack'

    # then fill up chache for async logic
    pack_cache = 
      dependencies_tree : {}
      names_map : {}
      source_code : {}
      err : null
      filters : []
      requireless : []
      unchanged : []
      step_cache_name : step_cache_name

    # add filters
    if options.filters?
      pack_cache.filters = @_forceFilterToArray options.filters
    # and requireless
    if options.requireless?
      pack_cache.requireless = @_forceFilterToArray options.requireless

    if options.unchanged?
      pack_cache.unchanged = @_forceFilterToArray options.unchanged

    pack_cache.queue_obj = load_queue = async.queue @_queueFn, QUEUE_CONCURRENCY

    load_queue.drain = =>

      # console.timeEnd '_buildModulePack'

      unless pack_cache.err

        res =           
          dependencies_tree : pack_cache.dependencies_tree
          names_map : pack_cache.names_map
          source_code : pack_cache.source_code

        main_cb null, res

      else
        main_cb pack_cache.err

    load_queue.push {path_name, parent : ROOT_PARENT, pack_cache}, (err) -> pack_cache.err = err

  ###
  Oh!
  Many things here, but its price of async code
  ###
  _queueFn : ({path_name, parent, pack_cache}, queue_cb) =>

    #console.time "all #{parent} #{path_name}"

    # "- Run, Fores, run!!!""
    async.waterfall [
      # 1.resolve real filename
      (waterfall_cb) =>
        #console.time "res #{parent} #{path_name}"
        @_pathfinder_.resolveAbsolutePath path_name, path.dirname(parent), (err, data) ->
          #console.timeEnd "res #{parent} #{path_name}"
          waterfall_cb err, data
      # 2. load source and compile it to js + get some meta data
      (real_file_name, waterfall_cb) =>
        
        # save all to tree, if some data exists - its return false
        unless @_dependenciesTreeSaver {path_name, parent, real_file_name, pack_cache}
          return queue_cb() # <---- YES! we are jamping out the train

        # get all data and meta than go to next step
        #console.time "load #{parent} #{path_name}"
        @_file_processor_.loadFile real_file_name, (err, content, may_have_reqire, {digest}) ->
          return waterfall_cb err if err
          #console.timeEnd "load #{parent} #{path_name}"
          #console.log real_file_name
          #console.log digest
          waterfall_cb null, {digest, content, may_have_reqire, path_name, real_file_name}

      # 3. save data and, if it real code, search for requires in it
      ({digest, content, may_have_reqire, path_name, real_file_name}, waterfall_cb) =>
        # just ave all to result obj
        @_fileDataSaver {digest, content, real_file_name, pack_cache}

        # and add new files to queue if it have `requires`
        @_findRequiresAndAddToQueue {digest, may_have_reqire, content, real_file_name, path_name, pack_cache, waterfall_cb}
      ], (err) => 
        #console.timeEnd "all #{parent} #{path_name}"
        queue_cb err # this is the end of waterfall


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
  This method searching for requires, its just stub.
  later I re-write it to class
  to substitute detective with my own logic and acorn
  ###
  _findRequiresItself : (data) ->
    result = []
    try
      result = detective data
    catch error
      return [error]

    [null, result]

  ###
  Build composite digest for files

  its needed because some file may have different requires list by use differtent settings
  ###
  _getCompositeDigest: (step_cache_name, digest) ->
    "#{step_cache_name}_#{digest}"
    
  ###
  This method find requires in files, if they need it and 
  add to queue new files for recurse working
  ###
  _findRequiresAndAddToQueue : ({digest, may_have_reqire, content, real_file_name, path_name, pack_cache, waterfall_cb}) =>

    ###
    console.log 'path_name'
    console.log path_name
    console.log 'real_file_name'
    console.log real_file_name

    console.log 'pack_cache.unchanged'
    console.log pack_cache.unchanged
    ###

    # do not add new files if hasn`t `requires`
    return waterfall_cb() unless may_have_reqire or not @_isFilesMustBeProcessed pack_cache.requireless, path_name

    composite_digest = @_getCompositeDigest pack_cache.step_cache_name, digest
    # console.log 'composite_digest', composite_digest

    # try to get all by cache
    unless @_require_cache_.has composite_digest
      # console.log 'Requires cache miss', real_file_name
      [err, res] = @_findRequiresItself content
      # just die fast
      if err?
        err.fileName = real_file_name
        return waterfall_cb err
      else 
        @_require_cache_.set composite_digest, res
        childrens = res
    else
      # console.log 'Requires cache hit', real_file_name
      childrens = @_require_cache_.get composite_digest

    #console.log 'childrens'
    #console.log childrens

    eachFn = (child, acb) =>
      @_pathfinder_.resolveAbsolutePath child, path.dirname(real_file_name), (err, real_child_name) =>
        return acb err if err?

        # HACK @meettya inverted logic, but ok
        if @_isFilesMustBeProcessed pack_cache.unchanged, real_child_name

          pack_cache.queue_obj.push
            path_name : child
            parent : real_file_name
            pack_cache : pack_cache
            , (err) ->
              pack_cache.err = err
        else
          @_dependenciesTreeSaver { path_name: child, parent : real_file_name, real_file_name : real_child_name, pack_cache}

        acb()

    async.each childrens, eachFn, (err) =>
      return waterfall_cb err if err?
      waterfall_cb()

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
  _fileDataSaver : ({digest, content, real_file_name, pack_cache}) ->
    pack_cache.names_map[real_file_name] = digest
    pack_cache.source_code[real_file_name] ?= content
    null

  ###
  This is proceed filter
  return 'true' if file MUST be processed, 
  ie it filename NOT in list - it will be processed
  ###
  _isFilesMustBeProcessed : (filters_list, path_name) ->
    ! _.any filters_list, (filter) ->
        filter is path_name 

