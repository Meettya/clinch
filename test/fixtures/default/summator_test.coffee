#!/usr/bin/env coffee

summator = require './summator'

console.log "\n<--- NEW --->\n"

console.log "2+2=#{summator.summator 2,2}"
console.log "(2+4)*3=#{summator.summ_a_b_and_multiply_by_3 2,4}"
console.log "(7+9)*3-2=#{summator.summ_a_b_and_multiply_by_3_than_sub_2 7,9}"
console.log "5*10+5*10-2=#{summator.sum_multiply_and_substracted_2_multipli 5, 10}"

console.log "lowest(5, 8, 9, 2, 32)= #{summator.lowest 5, 8, 9, 2, 32}"