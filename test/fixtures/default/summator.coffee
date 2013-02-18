# simple module

{_} = require 'lodash'

{multiplier, multiply_and_substract_2} = require './sub_dir/multiplier'

summator = (a, b) -> a + b
summ_a_b_and_multiply_by_3 = (a,b) -> multiplier summator(a,b), 3
summ_a_b_and_multiply_by_3_than_sub_2 = (a,b) -> 
  multiply_and_substract_2 @summator(a,b), 3
sum_multiply_and_substracted_2_multipli = (a,b) ->
  summator multiplier(a,b), multiply_and_substract_2(a,b)

lowest = (args...) -> _.min args


module.exports =
  summator : summator
  summ_a_b_and_multiply_by_3 : summ_a_b_and_multiply_by_3
  summ_a_b_and_multiply_by_3_than_sub_2: summ_a_b_and_multiply_by_3_than_sub_2
  sum_multiply_and_substracted_2_multipli : sum_multiply_and_substracted_2_multipli
  lowest : lowest

