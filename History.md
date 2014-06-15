## 0.5.8 / 2014-06-15 11:50 PM

 - Add more aggressive module cache to speed up huge project rebuild
 - Update all nmp modules to latest (again)
 - Change travis to node v0.10 only

## 0.5.7 / 2014-04-13 04:00 PM

 - Add React support - `.jsx` and `.csbx` (Coffee&React)

## 0.5.5 / 2014-04-04 12:00 AM

 - Update all nmp modules to latest (again)

## 0.5.3 / 2014-04-01 12:00 AM

 - Fix & test for [#18 issue](https://github.com/Meettya/clinch/issues/18)
 - Rebuild lib with CS 1.7.1

## 0.5.1 / 2014-04-01 07:00 PM

 - Move to CoffeeScript 1.7.x
 - Update all nmp modules to latest

## 0.4.9 / 2013-12-21 09:00 PM

 - Fix & test for [#15 issue](https://github.com/Meettya/clinch/issues/15)
 - Add 'replacement as function' code & test & docs
 - Refactor some code

## 0.4.7 / 2013-12-16 11:30 PM

 - Fix & test for [#13 issue](https://github.com/Meettya/clinch/issues/13)

## 0.4.5 / 2013-12-09 03:10 AM

 - Fix & test & docs for [#11 issue](https://github.com/Meettya/clinch/issues/11)

## 0.4.3 / 2013-12-06 12:30 AM

 - Fix & test for [#9 issue](https://github.com/Meettya/clinch/issues/9)
 - Update nmp modules

## 0.4.1 / 2013-10-01 11:00 PM

 - Add 'runtime' library - now boilerplate code may be resolved by external file.
 - Add modules cache - to cover [#5 issue](https://github.com/Meettya/clinch/issues/5)
 - Add both things to documentation

## 0.3.9 / 2013-09-19 12:20 AM

  - Fix [#4 issue](https://github.com/Meettya/clinch/issues/4)

## 0.3.7 / 2013-09-18 12:48 AM

  - Fix 'sources' indent
  - Fix test for current version of modules for [#3 issue](https://github.com/Meettya/clinch/issues/3)
  - Add shinkwrap files
  - Re-build lib with new Coffee-script

## 0.3.5 / 2013-04-14 10:30 PM

  - Add 'inject' & 'strict' settings to package config
  - API changed (but old worked) - now 'package_name' part of package config, see `#buildPackage()` docs
  - Realized new feature - without 'buildPackage()' clinch now will work with bundle members - depended on 'inject' inject it to global or make local vars
  - Refactor code
  - Add Plato status

## 0.3.1 / 2013-04-02 03:00 AM

  - Refactor cache logic, now its drop only changed files
  - Add clinch version as comment in result bandle
  - Change some dependencies versions to new one
  - Add getPackageFilesList() method

## 0.2.9 / 2013-03-17 06:45 PM

  - Re-compile to js (sorry, I forgot) and link to it

## 0.2.7 / 2013-03-17 02:00 PM

  - Add Handlebars example, update docs, add test

## 0.2.5 / 2013-03-16 10:00 PM

  - Add registerProcessor() method for custom file processors
  - Huge refactor
  - Update docs

## 0.2.3 / 2013-03-15 01:00 AM

  - Add settings to Clinch constructor - 'jade', 'strict', 'inject'
  - Huge refactor to Dependency Injector Container
  - Update docs

## 0.2.1 / 2013-03-05 02:00 PM

  - Fix 'replacement' and 'exclude' - now its just string comparisons
  - Add '.jade' template engine support, see Readme, wiki and './test/jade_powered' for details

## 0.1.7 / 2013-03-02 12:00 AM

  - Add flushCache() method to force cache flush.

## 0.1.5 / 2013-03-02 10:00 PM

  - Remove unneeded dependencies
  - Add Readme with example

## 0.1.3 / 2013-03-01 04:10 PM

  - Add support for node core modules - it saved in dependencies and must be substituted with 'replacement' settings.

## 0.0.8 / 2013-02-18 10:00 PM

  - Fix 'this' call, now it worked.

## 0.0.7 / 2013-02-18 10:00 PM

  - Build beta version