## Roadmap for clinch

  - Add some options to package settings - like `inject` and other. It will overwrite global clinch object options. - done
  - Add direct injection, without bundle prefix. - done
  - Add shim filter if replacer don't used in dependencies - maybe later, non-trivial.
  - Add smart cache system by file hash - done
  - Replace two file read to one buffer read - unneeded, no speed up detected
  - Replace detective with self-writhed class on acorn
  - Add jade support - done
  - Add more tests - in process
  - Add 'runtime' package option, to replace boilerplate code to runtime lib - done
  - Add modules cache to prevent re-creating prototypes on every call - done
  - Add 'clinch require start/end' statimen support to speed up require parsing (with RegExp, not detective)
  - Add travis-ci  - done
  - Add React support - done