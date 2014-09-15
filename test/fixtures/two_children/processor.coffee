# simple module

power = require './power'

process = (a, b) -> a * b
processor_pow = (a, b) -> power.pow process a, b

module.exports =
  { 
    process
    processor_pow
  }