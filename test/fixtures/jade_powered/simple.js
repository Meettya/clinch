
fs = require 'fs'

Clinch = require 'clinch'
packer = new Clinch()

package_config = 
  bundle : 
    main : "#{__dirname}/filename"

packer.buldPackage 'my_package', package_config, (err, data) ->
  fs.writeFile "#{__dirname}/result.js", data, 'utf8', (err) ->
    console.log 'Bundle saved!'