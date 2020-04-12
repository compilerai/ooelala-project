Code and makefile to run the examples demonstrating sample patterns where ooelala is effective and yields significant speed-ups over clang, gcc, etc.

1. array_min_max - computation of the min and max values of an array in one iteration
The default input is an array of size 100000 for 1000 runs. This can be changed in main.c                                                                          
                                                                        
2. nested_loop - an adapted version of the kernel initialisation in morphology.c from 538.imagick_r benchmark in SPEC CPU 2017
The default input is a 1000 x 1000 array for 1000 runs. This can be changed in main.c

To get compile and run times - make <litmus_test>-test 
Refer to the Makefile for other options
