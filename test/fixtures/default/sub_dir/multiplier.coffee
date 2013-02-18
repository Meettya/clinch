# simple module

{substractor} = require '../substractor'

multiplier = (a, b) -> a * b
multiply_and_substract_2 = (a, b) -> 
  substractor multiplier(a, b), 2

module.exports =
  multiplier : multiplier
  multiply_and_substract_2 : multiply_and_substract_2

