# simple module


{generator} = require './unique_generator'
generator2 = (require './unique_generator').generator

module.exports = 
  {generator, generator2}