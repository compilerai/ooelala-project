A few polybench benchmarks selected to benchmark and compare the performance of various compilers, most importantly of clang and ooelala(clang-unseq)

Polybench programs serve as a good demonstration of the usage of a "RESTRICT"-like macro which can be used to specify must-not-alias relationships between a set of values, which then allows for generation of more optimised code as seen by reduced runtimes (in some cases)
