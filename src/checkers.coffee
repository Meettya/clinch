###
This is arguments method decorator checkers
###
_       = require 'lodash'

module.exports = 
  rejectOnInvalidFilenameType : (methodBody) ->
    (filename, cb) ->
      unless _.isString filename
        return cb TypeError """
                  must be called with filename as String, but got:
                  |filename| = |#{filename}|
                  """
      methodBody.call this, filename, cb
