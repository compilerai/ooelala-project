Makefiles to compile SPEC benchmarks individually - in order to experiment with the benchmarks themselves, e.g. adding clock around certain sections of code, without having to compile the entire benchmark every time.

These are derived from running individual benchmarks with `runcpu` with `--fake`, parsing the logs to get the compile commands and making a makefile out of these

1. Rename "\<benchmark\>.makefile" to "Makefile"
2. Move to \<benchmark\>/src
3. `make <command>`

The commands and inputs to run the binaries generated can be found inside the spec_installation/benchspec/CPU/<benchmark>/run/<config> folder
Specifically, speccmds.out contains the commands run (which requires SPEC CPU 2017 to have been run once)

SPEC (runcpu) checks the benchmark source directories' checksums, and so no changes should be made to the SPEC install's directory structure. It is suggested to copy the benchmark source directory entirely.

By default, the clang and ooelala(clang-unseq) paths are set to /opt/llvm
