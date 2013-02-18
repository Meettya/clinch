# simple module

power = require './power'

substractor = (a, b) -> a - b
substractor_pow = (a, b) -> power.pow substractor a, b
substractor_rec = (a,b) -> substractor a, b

module.exports =
  substractor : substractor
  substractor_pow : substractor_pow
  substractor_rec : substractor_rec