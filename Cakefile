###
New Cakefile with good organization
###

path  = require 'path'
fs    = require 'fs'

root_path = path.dirname fs.realpathSync __filename

paths = 
  cake_dep          : 'cake_dep'
  src_dir           : 'src'
  lib_dir           : 'lib'

# extend path with root
for own key, value of paths
   paths[key] = path.join root_path, value
   null

# add commands
commands = require path.join paths.cake_dep, 'command'

task 'build', 'build coffee to js', build = (cb) ->
  commands.build_coffee paths.src_dir, paths.lib_dir, cb

