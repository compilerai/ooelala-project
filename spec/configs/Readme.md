Config files to use with SPEC CPU 2017 to benchmark clang and clang-unseq(ooelala), with and without the UBSAN checks.

1. Copy <config>.cfg to <SPEC installdir>/config
2. Change paths (like BASE_DIR)
3. Run `runcpu` with `--config=<config>`

Note - Some benchmarks need gFortran and LLVM dragonegg plugin to run with clang. 

Warning - dragonegg has some issues with llvm versions and is quite non-trivial to set-up. And so, it has not been done (yet). So benchmarks like exchange_r (from intrate) will not run
