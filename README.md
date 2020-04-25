This README describes this artifact, which contains the implementation for the algorithm described in the paper, *OOElala: Order-of-Evaluation Based Alias Analysis for Compiler Optimization*, accepted at PLDI 2020.

## Terminology

* We use `OOElala`, `ooelala` and `clang-unseq` interchangeably to refer to the tool/binary which we have implemented and produced as a part of this work. 
* `<artifact-home>` refers to `/home/$USER/ooelala-project`

## Structure of the artifact

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

* *sample_outputs* - This directory contains a set of sample outputs which are obtained on running the SPEC CPU 2017 and the polybench benchmarks. These can be used by the developers to verify the output format
	* *spec* - This contains the results and stats obtained for a sample run of SPEC CPU 2017, with clang and clang-unseq
	* *polybench* - This contains the results and stats obtained for a sample run of Polybench, with clang and clang-unseq

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
	* Update the path of the environment, to reflect the icc installation. You can add the following statement to the `bashrc` file as well.
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

## Running the SPEC CPU 2017 benchmarks

In section 4.2.2 of the paper, we have discussed building the SPEC CPU 2017 benchmarks using OOElala and obtaining the statistics related to the optimisations which are introduced due to the OOE non determinism. In this section, we will discuss the steps needed to be followed to run the SPEC benchmarks with OOElala and how to obtain the results. Note that, as per [this](https://www.spec.org/cpu2017/Docs/overview.html#benchmarks) documentation, the SPEC benchmarks are organised into 4 suites - intrate, intspeed, fprate and fpspeed. We analyse and benchmark OOELala on 2 out of these 4 suites namely intrate and fprate. Even from the 2 suites selected, we work with the C only benchmarks as the current scope of our analysis and implementation of OOElala is limited to C only. This gives us a set of 8 benchmarks, against which we benchmark the performance of the code compiled using OOElala and collect the optimisation related stats in the process. 

These 8 benchmarks are:
* Intrate suite
	* 500.perlbench_r
	* 502.gcc_r
	* 505.mcf_r
	* 525.x264_r
	* 557.xz_r
* Fprate suite 
	* 519.lbm_r
	* 538.imagick_r
	* 544.nab_r

### Generating Optimisation and Aliasing related Statistics

This subsection outlines the steps to be followed to generate the optimisation and aliasing related statistics after running SPEC with both Clang and OOELala. These steps will generate the statistics present in Table 5 of the paper. Using the makefiles associated with the SPEC benchmarks, the interested readers and developers can also take a look at per source file LLVM IR changes that helped us identify the patterns reported in Figure 2 of the paper.

* Change to the SPEC CPU 2017 installation directory
  ```
  $ cd /opt/spec/
  ```
* Copy the config files from `/home/$USER/ooelala-project/configs/` to `/opt/spec/configs`
  ```
  $ sudo cp /home/$USER/ooelala-project/spec/configs/clang.cfg /opt/spec/config
  $ sudo cp /home/$USER/ooelala-project/spec/configs/clang-unseq.cfg /opt/spec/config
  $ sudo cp /home/$USER/ooelala-project/spec/configs/clang-ubsan.cfg /opt/spec/config
  $ sudo cp /home/$USER/ooelala-project/spec/configs/clang-unseq-ubsan.cfg /opt/spec/config
  ```
* Copy utility scripts from `/home/$USER/ooelala-project/scripts/` to `/opt/spec/`
  ```
  $ sudo cp /home/$USER/ooelala-project/spec/scripts/buildSPEC.sh /opt/spec
  $ sudo cp /home/$USER/ooelala-project/spec/scripts/buildUBS.sh /opt/spec
  $ sudo cp /home/$USER/ooelala-project/spec/scripts/runSPEC.sh /opt/spec
  $ sudo cp /home/$USER/ooelala-project/spec/scripts/runUBS.sh /opt/spec
  $ sudo cp /home/$USER/ooelala-project/spec/scripts/moveStats.sh /opt/spec
  $ sudo cp /home/$USER/ooelala-project/spec/scripts/compareStats.py /opt/spec
  $ sudo cp /home/$USER/ooelala-project/spec/scripts/combineResults.sh /opt/spec
  ```
* Chdir to `/opt/spec` and run `./buildSPEC.sh`
  ```
  $ cd /opt/spec
  $ ./buildSPEC.sh
  ```
* The compile-time statistics per source file after the SPEC build will be generated in the directories `/opt/spec/intrate_<timestamp>/` and `/opt/spec/fprate_<timestamp>/` respectively
* Copy `compareStats.py` from `/home/$USER/ooelala-project/spec/scripts/` to `/opt/spec/`
  ```
  $ sudo cp /home/$USER/ooelala-project/spec/scripts/compareStats.py /opt/spec/
  ```
* Run the following commands to get alias stats comparison for the `intrate` suite
  ```
  $ cd /opt/spec
  $ python compareStats.py intrate_<timestamp>/clang intrate_<timestamp>/clang-unseq --csv intrate
  ```
* Run the following commands to get alias stats comparison for the `fprate` suite
  ```
  $ cd /opt/spec
  $ python compareStats.py intrate_<timestamp>/clang intrate_<timestamp>/clang-unseq --csv fprate
  ```

### Generating performance numbers

In this subsection, we outline the set of steps to be followed to run SPEC for both Clang and OOElala. These steps will generate the statistics presented in Table 6 of the paper. During the experimentation by the authors, they had run into issues related to DVFS (Dynamic Voltage and Frequency Scaling). Thus it might be beneficial to run SPEC on a machine which has DVFS disabled. To disable DVFS on ubuntu, please follow [this](https://askubuntu.com/questions/523640/how-i-can-disable-cpu-frequency-scaling-and-set-the-system-to-performance) link.

* Chdir to `/opt/spec` and run `./runSpec.sh` to run SPEC for both intrate and fprate suites, for 3 iterations
	* The script can be modified to run only intrate or fprate suites
	* The number of iteration can be increased or decreased
	
	**NOTE:** This step is the most time consuming step.

* The results are generated in the directory `/opt/spec/result` as inside the most recent `csv` files
	* `csv` file contains the times, scores, system specifications etc.
	* As per [this](https://www.spec.org/cpu2017/Docs/overview.html#metrics) documentation, the different scores are combined using the Geometric Mean, which is reported as the overall metric. 
	* In our case, we report the combined metric as the Geometric mean of the 8 C only benchmarks that we consider.

* To select the 8 C only benchmarks from intrate and fprate, we use the `combineResults.sh` script. It outputs a table with the time and score for each benchmark, as well as the combined score for all of them. 
* Run `./combineResults.sh <intrate results>.csv <fprate results>.csv <no. of iterations> <output file>`
  ```
  $ ./combineResults.sh result/CPU2017.<run no. 1>.intrate.refrate.csv result/CPU2017.<run no. 2>.fprate.refrate.csv 3 clang_comb.csv
  $ ./combineResults.sh result/CPU2017.<run no. 3>.intrate.refrate.csv result/CPU2017.<run no. 4>.fprate.refrate.csv 3 ooelala_comb.csv
  ```

### Running the UB Sanitizer

In order to build SPEC benchmarks with OOElala, with UBSAN checks enabled, we should follow the above steps and use `buildUBS.sh` and `runUBS.sh` instead of `buildSPEC.sh` and `runSPEC.sh`. This will compile the SPEC benchmarks with OOELala, with UB Sanitizer checks enabled and no optimisation passes and the the generated binaries respectively.

**NOTE:** In case SPEC is built this way, then we will see no change in the alias statistics as we disable the `AliasAnalysisEvaluator` pass due to the fact that we don’t run any optimisation passes in this case. Also, this run will be slower than the SPEC runs without the UB Sanitizer as the unoptimised code with the UB Sanitizer checks is run, instead of optimised code. Running without errors is a confirmation that there are no bugs generated due to our predicates on the reference inputs.

### Building individual SPEC benchmarks or inspecting the generated LLVM IR

In order to build individual SPEC benchmarks or generate LLVM IR at a per source file level, the reviewers can use the makefiles present in `/home/$USER/ooelala-project/spec/makefiles/`. The instructions for the same can be found in `/home/$USER/ooelala-project/spec/makefiles/Readme.md`. This can help the reviewers to generate the LLVM IR using both Clang and OOElala, for those files which contain the patterns listed in Figure 2 and compare the IR generated to see the additional optimisations performed by OOElala.

## Running Polybench benchmarks

In section 4.2.1 of the paper, we have discussed a few benchmarks drawn from the Polybench benchmark suite, which were manually annotated to introduce unsequenced side-effects to allow OOElala to infer additional aliasing information. An example annotation is:
```
#define CANT_ALIAS(a, b, c) ((a = a) + (b = b) + (c = c))
…
CANT_ALIAS(q[i], A[i][j], r[k]);
…
```
This is used to infer that `q[i]`, `A[i][j]` or `r[k]` have a (pair-wise) must-not-alias relationship. Note, that this statement is effectively a no-op, and will be removed by the DCE pass (along with by `-ffmath` in case the values are floats). This can be confirmed by generating the optimised llvm-IR with clang. We have annotated and tested 6 of the polybench benchmarks. These include various linear algebra kernels and operators. The modified programs can be found in the `polybench/selected_benchmarks` directory. 

### Running all the benchmarks

* Chdir to `<artifact-home>/polybench` directory
  ```
  cd /home/$USER/ooelala-project/polybench
  ```
* Run the script to compare times for clang, clang-unseq, icc and gcc for all benchmarks
  ```
  ./scripts/getAllResults.sh
  ```
  This will generate `results.csv` with the column `clang-unseq vs clang (x)` being used as Table 4 in the paper.

* Those who are interested in further investigation can run the following command for finer control over the results generation:
  ```
  python scripts/compareTimes.py selected_benchmarks --runs <number of runs> --csv <results>
  ```

### Compiling all the benchmarks with clang/ooelala and getting alias stats

* Chdir to `<artifact-home>/polybench` directory
  ```
  cd /home/$USER/ooelala-project/polybench
  ```
* Run `./scripts/getStats.sh <output_dir>`
* Two folders are generated inside `<output_dir>` - one for clang statistics, one for clang-unseq (ooelala)
* Run `python ./scripts/compareStats.py <output_dir>/clang <output_dir>/clang-unseq --csv <stats>`
* This generates `<stats>.csv` which contains the difference of various aliasing statistics between clang and clang-unseq

### Compiling a single benchmark

* Chdir to `<artifact-home>/polybench` directory
  ```
  cd /home/$USER/ooelala-project/polybench
  ```
* Run the following make command to compile a single benchmark with the specified compiler other than `ooelala`
  ```
  make selected_benchmarks/<benchmark>/<benchmark> COMP=<compiler_command>
  ```
  Here, `COMP = /opt/llvm/build/bin/clang`, by default. To change the compiler, `COMP` can be changed to `COMP = gcc` or `COMP = icc`.
* Run the following make command to compile a single benchmark with the `ooelala` 
  ```
  make selected_benchmarks/<benchmark>/<benchmark>-unseq
  ```

### Running a single benchmark

* Chdir to `<artifact-home>/polybench` directory
  ```
  cd /home/$USER/ooelala-project/polybench
  ```
* Run the following command to run a single benchmark
  ```
  ./scripts/timeBenchmark.sh <compiler-name> selected_benchmarks/<benchmark> <number of runs>
  ```
  Here `<compiler-name>` can be gcc, icc, clang or clang-unseq (for ooelala)