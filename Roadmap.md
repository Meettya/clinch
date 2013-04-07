## Roadmap for clinch

  - Add some options to package settings - like `inject` and other. It will overwrite global clinch object options.
  - Add direct injection, without bundle prefix.
  - Add shim filter if replacers dont used in dependencies - maybe later, non-trivial.
  - Add smart cache system by file hash - done
  - Replace two file read to one buffer read - unneeded, no speed up detected
  - Replace detective with self-writed class on acorn
  - Add jade support - done
  - Add more tests