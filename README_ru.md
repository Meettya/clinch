# clinch

**clinch** - еще один упаковщик ComonJS-style проектов для браузера. 

Он отлично подходит для небольших модулей благодаря малому оверхеду на имитацию require-логики.

Он отлично продходит для больших приложений благодаря возможности подмены кода модулей, эмуляции глобальных node-переменых и реализации экспорта нескольких объектов сразу.

## installation

    npm install clinch

## example

    #!/usr/bin/env coffee
    Clinch = require 'clinch'
    packer = new Clinch()
    pack_config = 
      bundle : 
        main : "#{__dirname}/hello_world"
    packer.buldPackage 'my_package', pack_config, (err, data) ->
      if err
        console.log 'Builder, err: ', err
      else
        console.log 'Builder, data: \n', data

Контент файла `./hellow_world`

    ###
    This is 'Hello World!' example
    ###
    module.exports = 
      hello_world : -> 'Hello World!'

Даст нам в `data` примерно такие данные

    (function() {
        'use strict';
        
    <... skip clinch header ...>

        dependencies = {};
        sources = {
    "2377150448": function(exports, module, require) {
    // /Users/meettya/github/clinch/example/hello_world/hello_world.coffee 
    /*
    This is 'Hello World!' example
    */
    module.exports = {
      hello_world: function() {
        return 'Hello World!';
      }
    };
    }};
    this.my_package = {
    "main": require(2377150448)};
    }).call(this);

И в браузере функция будет доступна вот так

    hello_world = my_package.main.hello_world

## Особенности:

### только require-based включение модулей

В отличие от [stitch](https://github.com/sstephenson/stitch) в пакет включаются только модули, которые загружаются посредством `require()` а не все, лежащие в перечисленных папках.

### честный AST-парсинг кода модулей

**clinch** проводит поиск в результирующем CommonJS-коде, что исключает появление в зависимостях закомментированных модулей и прочих странных вещей.

### исходный код модулей не модифицируется

**clinch** добавляет к исходному коду модуля только комментарий с путем файла, для облегчения отладки. Сам код остается в неприкосновенности, следовательно появление ошибки в результате обработки упаковщиком маловероятно.

### есть разные версии и нет дублей

Благодаря использованию деревьев зависимостей и подмене имен файлов на их хеш от содержимого решается проблема одноименных подчиненных модулей с разной версией и исключаются дубликаты модулей, имеющих разные имена и одинаковое содержимое (это чертовски сложно объяснить, но это работает, просто поверьте).

### бандл, а не приложение

**clinch** создает бандл-пак, а не собирает приложение. В чем разница? У вас сколько угодно точек входа. Более того, можно сделать дополнительной точкой входа суб-модуль, и это никак не изменит размер получаемого пакета.

### development-mode ready

**clinch** может быть использован для development-mode http-serverа прямо из коробки. Все асинхронно, везде кеш, умная инвалидация кеша в комплекте. Объявите объект повыше и используйте для сборки кода на лету.

## API & settings

У **clinch** очень простой API

### buldPackage()

    packer.buldPackage package_name, package_config, cb

`package_name` - имя глобального объекта пакета, который станет корнем для всего содержимого бандла в браузере, как `$` в jQuery, коллизии имен пакетов на вашей совести.

`package_config` - настройки пакета.

`cb` - стандартный коллбек, для работы с результатами, все в **clinch** асинхронно.

### flushCache()

    packer.flushCache()

Этот метод сбрасывает кеш пакера. Обычно инвалидатор кеша в **clinch** отлично справляется со своей работой, но если вам по каким-то причинам нужно сделать принудительный ручной сброс - это просто.

### package_config

пример доступных настроек пакета с комментариями

    ###
    Ветка bundle перечисляет модули, которые будут включены в пакет 
    И будут доступны в браузере из глобального объекта пакета
    ###
    bundle :
      main : './src'              # -> my_package.main
      helper : './src/lib/helper' # -> my_package.helper

    ###
    Ветка replacement перечисляет модули, которые будут подменены.
    Кроме того здесь следует указывать любые node.js - core модули,
    так как их импорт по умолчанию не производтся.
    ###
    replacement :
      util : './node_modules/js-util'

    ###
    Ветка requireless может быть использована для ускорения сборки пакета
    перечисленные модули не будут разбираться на предмет наличия в них
    require, что существенно сокращает время сборки, особенно с большими файлами
    ###
    requireless : [
      'lodash'
    ]

    ###
    Ветка environment может использоваться для имитации node.js окружения,
    ключи становятся локальными для пакета переменными, с похожим для node.js поведением.
    Используйте осторожно, точно понимая что вы делаете.
    ###
    environment :
      process : './node/js-process'
      console : './node_modules/console-shim'

    ###
    Ветка exclude используется для исключения модулей из пакета,
    однако ее ценность выглядит сомнительной, возможно в дальнейшем
    она будет исключена. Используйте replacement и fake-модули.
    ###
    exclude : [
      'underscore'
    ]

## Что на выходе?

Результатом работы **clinch** является SIF бандл-пак, который инжектит в this ключ с именем бандл-пака, в содержимом будут ключи, перечисленные в bundle-ветке настроек.

Если проще, то после загрузки файла в браузер необходимые модули станут доступны как то так - `var main = my_package.main`

## У меня ничего не работает

Во-первых ваш код должен работать в node.js, например проходить тесты. Если рабочий код после упаковки становится неработоспособным - возможно следует указать замену node.js-специфичным модулям или core-модулям.

Если код выглядит переносимым, но тем не менее не хочет работать в браузере - свяжитесь со мной, возможно я где-то ошибся в **clinch**, на данный момент это всего лишь бета.

Кроме того можете проверить директории `example` и `test` на предмет подсказок и примеров использования.

## Примеры

Смотри `example` или `test` директории.

Кроме того несколько простых примеров результата доступны online тут - [clinch_demo](http://meettya.github.com/clinch_demo/index.html).

Так же **clinch** был использован для упаковки проекта [TinyData](http://meettya.github.com/TinyData/demo.html), смотри исходники на странице или [packed lib](https://github.com/Meettya/TinyData/blob/master/lib_browser/tinydata.js)
