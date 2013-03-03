###
This class process raw data parts from Gatherer:
 - replace modules with replacers
 - clean up dependencies tree
 - re-build structure for packer

Короче, это пре-процессор для пакера, много лишних телодвижений нужно сделать с кодом
и это превращается в кашу, так что тут мы все подготавливаем 
и красиво уложеным отдаем пакеру на финальную упаковку и завязывание бантиков
###

_       = require 'lodash'
async   = require 'async'

util = require 'util'

Gatherer      = require './gatherer'

class BundleProcessor
  constructor: (@_options_={}) ->
    # for debugging 
    @_do_logging_ = if @_options_.log? and @_options_.log is on and console?.log? then yes else no
    @_gatherer_ = new Gatherer()

  flushGathererCache : ->
    @_gatherer_.resetCaches()

  ###
  This META-method bulid package and process it in one touch
  ###
  buildAll : ( package_config, method_cb) ->

    @buldRawPackageData  package_config, (err, code) =>
      return method_cb err if err
      method_cb null, @changePathsToHashesInJoinedSet @joinBundleSets @replaceDependenciesInRawPackageData code


  ###
  BENCHMARK IMPROVE!!!
  On simply test data I got about 97% of time in this method and 3% at all other
  So, to speed up all process we are need to cache THIS part - buldRawPackageData
  ###
  ###
  This method will build raw package data
  ###
  buldRawPackageData : ( package_config, method_cb) ->

    {liberal_gatherer, strict_gatherer} = @_buildGatherers package_config

    async.parallel
      bundle : (par_cb) =>  
        @_compileBundleSet strict_gatherer, package_config.bundle, par_cb
      environment : (par_cb) =>
        @_compileBundleSet strict_gatherer, package_config.environment, par_cb
      replacement : (par_cb) =>
        @_compileBundleSet liberal_gatherer, package_config.replacement, par_cb

      , (err, data) ->
        return method_cb err if err
        method_cb null, data
  
  ###
  This method replace filtered dependencies in raw data to 'replacement' content 
  Yes, sync - nothing async here
  ###
  replaceDependenciesInRawPackageData : (package_data) ->
    # if no 'replacement' - just return untoched
    unless package_data.replacement.length
      return package_data

    replacement_dict = _.reduce package_data.replacement, (memo, val) ->
      [memo[val.package_name]] = _.values val.dependencies_tree['.']
      memo
    , {}

    # yes, looks ugly, but I dont know how prettify it on deep structure
    replace_processor = (bundle_pack) ->
      _.each bundle_pack, (bundle_item) ->
        _.each _.values(bundle_item.dependencies_tree), (out_val) ->
          for dep_key of out_val when replacement_dict[dep_key]?
            out_val[dep_key] = replacement_dict[dep_key]
            null

    for item in [package_data.bundle, package_data.environment]
      replace_processor item

    package_data

  ###
  This method join bundle sets to flat structure
  ###
  joinBundleSets : (package_data) ->

    result_obj = 
          source_code : {}
          dependencies_tree : {}
          names_map : {}
          members : {}

    reduce_fn = (memo, val) ->
      [memo.members[val.package_name]] = _.values val.dependencies_tree['.']
      delete val.dependencies_tree['.']

      for key in ['source_code', 'dependencies_tree', 'names_map']
        memo[key] = _.extend memo[key], val[key]
      memo

    for step, step_data of package_data
      result_obj["#{step}_list"] = _.map step_data, (val) -> val.package_name

      _.reduce step_data, reduce_fn, result_obj

    result_obj                  

  ###
  This method will change all filepaths to it hashes.
  Its for squize names AND may reduce some items in sources,
  in case one code placed in diffenrent places - it may happened 
  for modules in node_modules folders - they have theyown dependencies
  ###
  changePathsToHashesInJoinedSet : (package_data) ->
    # just alias
    names_to_hash = package_data.names_map

    # change 'members'
    for key, value of ( pdm = package_data.members )
      pdm[key] = names_to_hash[value]

    # change 'source_code'
    tmp_source_code = {}
    for key, value of ( psc = package_data.source_code )
      tmp_source_code[names_to_hash[key]] = value
    package_data.source_code = tmp_source_code

    # change 'dependencies_tree'
    tmp_dependencies_tree = {}
    for out_key, out_value of ( pdt = package_data.dependencies_tree )
      tdt = tmp_dependencies_tree[names_to_hash[out_key]] = {}
      for inner_key, inner_value of out_value
        tdt[inner_key] = names_to_hash[inner_value]
    package_data.dependencies_tree = tmp_dependencies_tree

    package_data

  ###
  This method compile raw 'bundle' set with source, dep_trees and names
  ###
  _compileBundleSet : (gatherer, bundle_obj, method_cb) ->

    map_fn = ([part_name, part_path], map_cb) -> 
      gatherer part_path, (err, package_data) ->
        return map_cb err if err
        package_data.package_name = part_name
        map_cb null, package_data

    async.map _.pairs(bundle_obj), map_fn, (err, res) ->
      return method_cb err if err
      method_cb null, res

  ###
  This method build two pre-fired Gatherers:
    strict (for bundle and environment) and liberal (for replacement)
  Just shorten call + now we are may have ONE gather for all
  ###
  _buildGatherers : (package_config) ->

    requireless_filter = package_config.requireless ? []

    liberal_filter  = package_config.exclude ? []
    strict_filter   = liberal_filter.concat _.keys package_config.replacement

    liberal_gatherer  : (name, cb) => 
      @_gatherer_.buildModulePack name, {filters : liberal_filter, requireless : requireless_filter},cb
    strict_gatherer   : (name, cb) =>
      @_gatherer_.buildModulePack name, {filters : strict_filter, requireless : requireless_filter},cb


module.exports = BundleProcessor