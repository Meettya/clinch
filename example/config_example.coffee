###
Example of frankenweenie config
###

module.exports = 

  ###
  At least one key must be exists
  name -> code place
  this keys was be exported when script loaded
  bundle = 
    main   : function(){...}
    helper : function(){...}

  later in code

    main = bundle.main()

  or 

    main = bundle.get 'main' ???

  а! а что у нас там с геттерами? может их использовать?

    main = bundle.main

  второй вариант выглядит интереснее, можно сделать обработку ошибок 
  и никакой черной магии

  Кроме того, если вызывать buldPackage() БЕЗ package_name, то все ключи 
  будут инжектированы в глобаль, это будет удобно для создания приложений
  не придется использовать заглушечное имя бандла и потом его разыменовывать

  ###

  bundle :
    main : './src'
    helper : './src/lib/helper'

  ###
  Отключает 'use strict' локально, для этого бандла
  ###
  strict : off

  ###
  Отключает инжект бандла в глобаль локально, для этого бандла,
  не влияет на exports, только на bundle
  ###
  inject : off

  ###
  This is local for code variables, to imitate node.js environment,
  or replace somthing
  Important - keys will be used as variable name, so any strange things may happened
  if it not old plain string, remember it!!!
  ###
  environment :
    process : './node/js-process'
    console : './node_modules/console-shim'

  ###
  This part replace modules with browser-spec one
  # TODO! realize not node modules replacment, but any - by path
  # think about it
  ###
  replacement :
    util : './node_modules/js-util'

  ###
  this is list of modules, whis is not be placed in bungle
  ###
  exclude : [
    'underscore'
  ]

  ###
  This is list of modules, which we are not check for require in it
  save time with huge pre-bulded libraries, like `lodash` or `jquery`
  if we are decide to place it in bundle
  ###
  requireless : [
    'lodash'
  ]
