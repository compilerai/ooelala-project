This README described the structure of this artifact, which contains the implementation for the algorithm described in the paper, *OOElala: Order-of-Evaluation Based Alias Analysis for Compiler Optimization*, accepted at PLDI 2020.

##Description of the artifact

This artifact directory is structured into the following subdirectories, each of which is described subsequently:

* *litmus_tests* - This directory contains the implementation of the two examples, which have been introduced in Section 1.1 of the paper, to spearhead the discussion about the key idea of the paper. The makefile is used to run these two examples, as described in detail in the later sections.
	* *array_min_max* - This subdirectory contains the code, for the first example, on the left of the figure.
	* *nested_loop* - This subdirectory contains the code for an example, which isolates the kernel initialization code described in the second image on the right. The implementation captures the basic idea for the SPEC 2017 example, as discussed in section 1.1.

* *ooelala* - This directory contains the source code for our tool, OOELala, which has been implemented over clang/llvm 8.0.0. 
	* *src* - This sub-directory contains the source code for the optimizing compiler implementation which includes the AST analysis to identify the must-not-alias predicates and the Alias Analysis which utilises the must-not-alias information to enable further optimisations. This has been added as a sub-module and the specific implementation details can be found in the commit history and commit messages of this sub-module.
	* *ubsan* - This sub-directory contains the source code for the implementation of the UB Sanitizer which uses the must-not-alias predicates generated after the AST analysis to implement the runtime checks. This has been added as a sub-module and the specific implementation details can be found in the commit history and commit messages of this sub-module.

* *spec* - This directory contains the resources which we use to run the SPEC CPU 2017 benchmarks, with clang and OOELala.
	* *configs* - This subdirectory contains the config files clang-unseq.cfg and clang.cfg, which are used when we build and run the SPEC CPU 2017 suite with OOELala and clang respectively. Additionally, this directory also contains config files clang-ubsan.cfg and clang-ubsan-unseq.cfg, which are used to specify that SPEC should be built and run with clang and OOELala respectively, with UBSAN checks enabled and no optimisations.
	* *makefiles* - This subdirectory contains the makefiles, which are used to compile and run specific SPEC benchmarks or generate object/LLVM files for some specific source files, in some specific benchmarks. These have been used to identify the patterns discussed in figure 2, present in appendix A.3 of the paper. For running these on SPEC refrate inputs refer to Readme.md in the subdir.
	* *scripts* - This subdirectory contains the scripts which are used to build and run the SPEC 2017 benchmarks and generate the performance numbers presented in table 6, present in Appendix A.4 of the paper. This also contains the post processing python script which is used to generate the summary of the aliasing stats, which are presented in Table 4, present in section 4 of the paper. The list of scripts and their functionality is described in the Readme.md file present in this subdirectory.

* *polybench* - This directory contains the resources which we use to run the Polybench benchmark suite, with clang and OOELala
	* *common* - This subdirectory contains the Polybench header file which needs to be included in the benchmarks.
	* *scripts* - This subdirectory contains the scripts used to build and run the Polybench benchmarks to obtain the speedups listed in Table 3, present in section 4 of the paper.Comparisons between various compilers have been drawn
	* *selected_benchmarks* - This represents the selected subset of benchmarks which we have annotated with custom “RESTRICT” macro predicates (corresponding to CANT_ALIAS used in the paper), used to provide the additional aliasing information, but in no way modifying the behaviour of the program

* *requirements.sh* - This script performs installation of gcc, g++, python, pip and pandas as listed in the prerequisites described above. The Intel C Compiler (icc) and the SPEC CPU 2017 benchmarks have already been installed on the VM instance, using the appropriate educational license. 

* *CANT_ALIAS.md* - This is a tutorial which discusses the *CANT_ALIAS* predicate described in the paper. It outlines the use of the macro and the subtleties associated with that.
