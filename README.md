This README described the structure of this artifact, which contains the implementation for the algorithm described in the paper, *OOElala: Order-of-Evaluation Based Alias Analysis for Compiler Optimization*, accepted at PLDI 2020.

## Terminology

* We use `OOELala`, `ooelala` and `clang-unseq` interchangeably to refer to the tool/binary which we have implemented and produced as a part of this work. 
* `<artifact-home>` refers to `/home/$USER/ooelala-project`

## Description of the artifact

This artifact directory is structured into the following subdirectories, each of which is described subsequently:

* *litmus_tests* - This directory contains the implementation of the two examples, which have been introduced in Section 1.1 of the paper, to spearhead the discussion about the key idea of the paper. The makefile is used to run these two examples, as described in detail in the later sections.
	* *array_min_max* - This subdirectory contains the code, for the first example, on the left of the figure.
	* *nested_loop* - This subdirectory contains the code for an example, which isolates the kernel initialization code described in the second image on the right. The implementation captures the basic idea for the SPEC 2017 example, as discussed in section 1.1 of the paper.

* *ooelala* - This directory contains the source code for our tool, OOELala, which has been implemented over clang/llvm 8.0.0. 
	* *src* - This sub-directory contains the source code for the optimizing compiler implementation which includes the AST analysis to identify the must-not-alias predicates and the Alias Analysis which utilises the must-not-alias information to enable further optimisations. This has been added as a sub-module and the specific implementation details can be found in the commit history and commit messages of this sub-module.
	* *ubsan* - This sub-directory contains the source code for the implementation of the UB Sanitizer which uses the must-not-alias predicates generated after the AST analysis to implement the runtime checks. This has been added as a sub-module and the specific implementation details can be found in the commit history and commit messages of this sub-module.

* *spec* - This directory contains the resources which we use to run the SPEC CPU 2017 benchmarks, with clang and OOELala.
	* *configs* - This subdirectory contains the config files `clang-unseq.cfg` and `clang.cfg`, which are used when we build and run the SPEC CPU 2017 suite with OOELala and clang respectively. Additionally, this directory also contains config files `clang-ubsan.cfg` and `clang-ubsan-unseq.cfg`, which are used to specify that SPEC should be built and run with clang and OOELala respectively, with UB Sanitizer checks enabled and no optimisations.
	* *makefiles* - This subdirectory contains the makefiles, which are used to compile and run specific SPEC benchmarks or generate object/LLVM files for some specific source files, in some specific benchmarks. These have been used to identify the patterns discussed in figure 2 of the paper. For running these on SPEC refrate inputs refer to `Readme.md` in the subdirectory.
	* *scripts* - This subdirectory contains the scripts which are used to build and run the SPEC 2017 benchmarks and generate the performance numbers presented in table 6 of the paper. This also contains the post processing python script which is used to generate the summary of the aliasing stats, which are presented in Table 5 of the paper. The list of scripts and their functionality is described in the Readme.md file present in this subdirectory.

* *polybench* - This directory contains the resources which we use to run the Polybench benchmark suite, with clang and OOELala
	* *common* - This subdirectory contains the Polybench header file which needs to be included in the benchmarks.
	* *scripts* - This subdirectory contains the scripts used to build and run the Polybench benchmarks to obtain the speedups listed in Table 4 of the paper. Comparisons between various compilers have been drawn.
	* *selected_benchmarks* - This represents the selected subset of benchmarks which we have annotated with custom `RESTRICT` macro predicates (corresponding to `CANT_ALIAS` used in the paper), used to provide the additional aliasing information, but in no way modifying the behaviour of the program

* *requirements.sh* - This script performs installation of gcc, g++, python, pip and pandas as listed in the prerequisites described above. The Intel C Compiler (icc) and the SPEC CPU 2017 benchmarks have already been installed on the VM instance, using the appropriate educational license. 

* *CANT_ALIAS.md* - This is a tutorial which discusses the *CANT_ALIAS* predicate described in the paper. It outlines the use of the macro and the subtleties associated with that.

## Setting up the tool

In this section, we provide detailed instructions related to installation of the pre-requisites and setting up the benchmarks as well as the OOElala code and binaries. The experiments in the original paper have been conducted on an Ubuntu 16.04 machine.

* Installation of g++, gcc, cmake
  ```
  $ sudo apt install build-essential g++
  $ sudo apt install cmake
  ```
* Installation of python, pip and pandas, required for the post processing scripts in python
  ```
  $ sudo apt install python python-pip
  $ sudo pip install --upgrade pip
  $ sudo pip install pandas
  ```
* Installation of icc
	* Download and Install the Intel Parallel Studio by following the instructions given [here](https://software.intel.com/en-us/download/parallel-studio-xe-2020-install-guide-linux).
	* Run the Intel Parallel Studio as follows:
		* Extract the parallel studio from the tar file and change to that directory
		* Run `./install.sh`
		* Only selecting the C++ compiler in the components to install should suffice, to run the litmus tests and the benchmarks
	* Update the path of the environment, to reflect the icc installation
	  ```
	  $ export PATH=$PATH:<path-to-folder-containing-icc-executable>
	  ```
* Installation of the SPEC 2017 benchmark suite
	* Obtain the iso for SPEC 2017 CPU benchmarks from [here](https://www.spec.org/order.html)
	* Create the SPEC installation directory
	  ```
	  $ sudo mkdir -p /opt/spec
	  $ sudo chown -R $USER /opt/spec
	  ```
	* Install the SPEC 2017 CPU benchmarks as per the instructions given [here](https://www.spec.org/cpu2017/Docs/install-guide-unix.html) in `/opt/spec`
* Installation of numactl, to run the SPEC CPU 2017 benchmarks
  ```
  sudo apt install numactl
  ```
* Place the contents of this artifact inside `/home/$USER` so that `/home/$USER/ooelala-project/` exists.
* Building the OOElala source code
  ```
  $ sudo mkdir -p /opt/llvm/build
  $ sudo chown -R $USER /opt/llvm/build
  $ cd /opt/llvm/build
  $ cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="Release" -DCLANG_BUILD_EXAMPLES=1 -DCMAKE_CXX_FLAGS="-Wno-shift-count-overflow -Wno-redundant-move -Wno-init-list-lifetime" -DLLVM_ENABLE_ASSERTIONS=On /home/$USER/ooelala-project/ooelala/src
  $ make -j2
  ```
* Building the UB Sanitizer 
  ```
  $ sudo mkdir -p /opt/llvm/ubsan
  $ sudo chown -R $USER /opt/llvm/ubsan
  $ cd /opt/llvm/ubsan
  $ cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="Release" -DCLANG_BUILD_EXAMPLES=1 -DCMAKE_CXX_FLAGS="-Wno-shift-count-overflow -Wno-redundant-move -Wno-init-list-lifetime" -DLLVM_ENABLE_ASSERTIONS=On /home/$USER/ooelala-project/ooelala/ubsan
  $ make -j2
  ```

## Running the Litmus Tests

As described above, the litmus tests correspond to the two examples introduced in section 1.1 of the paper. The litmus tests can be found in the `litmus_tests` sub directory of the `<artifact-home>` directory.

* **Example 1:** Calculating the index of the minimum and maximum element of an array
	* The first example is the `array_min_max` example which has been described in detail, in section 1.1 of the paper. 
	* In order to run this example, follow the steps: 
	  ```
	  $ cd /home/$USER/ooelala-project/litmus_tests
	  $ make array_min_max-test
	  ```
	* This will compile the source code of the array_min_max example, which is present in `<artifact_home>/litmus_tests/array_min_max/`, with gcc, icc, clang and OOElala. 
	* It reports the time taken to compile and generate the binary using each of the above mentioned compilers and also, the time taken by the binary to run the code.

* **Example 2:** Kernel matrix initialization
	* The second example is the `nested_loop example`. This example has been created by extracting out the kernel matrix initialization code which has been discussed in the example on the right hand side, in section 1.1. 
	* This example, simplifies the kernel initialization code, in a way that it is now initialising a 2D array, called X, using a nested loop, while summing up the rows of X in another array called W. We observe that the optimisation opportunity using OOE non determinism, remains the same, as outlined in the explanation in section 1.1. 
	* In order to run and benchmark the nested_loop example code, follow the steps:
	  ```
	  $ cd /home/$USER/ooelala-project/litmus_tests
	  $ make nested_loop-test
	  ```
	* This will compile the source code of the nested_loop example, which is present in `<artifact-home>/litmus_tests/nested_loop/`, with gcc, icc, clang and OOElala.
	* It reports the time taken to compile and generate the binary using each of the above mentioned compilers and also, the time taken by the binary to run the code.