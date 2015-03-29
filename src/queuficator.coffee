###
This is queuefication module

- it create AOP wrapper for function and build queue if some queries do to function
like memoize, but for async and only in this moment

###

_       = require 'lodash'


_keyChecker = (key, args) ->
  unless _.isString key
    return cb TypeError """
              cant build cache key as String form args:
              |args| = |#{args?.join ','}|
              """ 

_keyBuilder = (args) ->
  res = ''
  res += arg for arg in args when not _.isFunction arg
  res

_done_cb_builder = (queue_cache, key) ->
  (data...) ->
    while step = queue_cache[key].shift()
      # prevent ANY interaction cased by result sharing (it may slow down execution, but safety first!)
      step (_.cloneDeep data)...

queueSomeRequest = (methodBody) ->
    queue_cache = {}

    (args..., cb) ->

      key = _keyBuilder args
      _keyChecker key, args

      queue_cache[key] or= []
      queue_cache[key].push cb

      if queue_cache[key].length is 1
        methodBody.apply this, args.concat _done_cb_builder queue_cache, key

module.exports =
  { queueSomeRequest }