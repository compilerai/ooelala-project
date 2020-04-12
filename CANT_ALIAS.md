# Tutorial on using the `CANT_ALIAS` macro

The `CANT_ALIAS` macro can be used to specify must-not-alias relationships
between two or more scalar values in your C program.

## `CANT_ALIAS` Definition
Here is the
definition of the `CANT_ALIAS` macro.
```
#define CANT_ALIAS1(a) (a = a)
#define CANT_ALIAS2(a, b) CANT_ALIAS1(a) & CANT_ALIAS1(b)
#define CANT_ALIAS3(a, b, c) CANT_ALIAS1(a) & CANT_ALIAS2(b, c)
#define CANT_ALIAS4(a, b, c, d) CANT_ALIAS1(a) & CANT_ALIAS3(b, c, d)
#define CANT_ALIAS5(a, b, c, d, e) CANT_ALIAS1(a) & CANT_ALIAS4(b, c, d, e);
#define CANT_ALIAS6(a, b, c, d, e, f) CANT_ALIAS1(a) & CANT_ALIAS5(b, c, d, e, f);

#define GET_MACRO(_1, _2, _3, _4, _5, _6 , NAME, ...) NAME
#define CANT_ALIAS(...) GET_MACRO(__VA_ARGS__, CANT_ALIAS6, CANT_ALIAS5, CANT_ALIAS4, CANT_ALIAS3, CANT_ALIAS2)(__VA_ARGS__)
```
This definition allows up to six arguments to `CANT_ALIAS`. It is easy to
extend this to allow more arguments if required.

## `CANT_ALIAS` usage

### An illustrative example
Here is an illustrative
example of how `CANT_ALIAS` may be used in your program:
```
void foo(int *a, int *b, int *c, int *d) {
    CANT_ALIAS(*a, *b, *c, *d);
    for (int i = 0; i < 256; i++) {
      *c = *a * i + *b / (*d + i);
    }
}
```
Consider the function `foo` that has four pointer arguments that
may, in general, alias with each other. However, a whole-program
alias analysis may not be powerful enough to infer that `*a`, `*b`, `*c`
and `*d` cannot alias with each other. A simple annotation by the
programmer (`CANT_ALIAS(*a, *b, *c, *d)`) informs the compiler that none
of these scalar objects may (pairwise) alias with each other. For example,
this extra aliasing information allows OOElala to eliminate this
loop and replace it with a single update to `*c` with `(*a<<8) - *a + (*b/(*d + 255))` (the value produced by the last iteration).

### A real-world example

Here is an
example of how `CANT_ALIAS` was used in one of the Polybench programs:
```
static void kernel_bicg(...) {
    int i, j;

#pragma scop
    for (i = 0; i < _PB_M; i++)
        s[i] = 0;
    for (i = 0; i < _PB_N; i++) {
        q[i] = SCALAR_VAL(0.0);
        for (j = 0; j < _PB_M; j++) {
            CANT_ALIAS(s[j], r[i], A[i][j], q[i], p[j]);
            s[j] = s[j] + r[i] * A[i][j];
            q[i] = q[i] + A[i][j] * p[j];
        }
    }
#pragma endscop
}
```
This `CANT_ALIAS` annotation in this code snippet specifies that `s[j]`,
`r[i]`, `A[i][j]`, `q[i]`, and `p[j]` may not (pairwise) alias with each
other.


## Things to consider while using `CANT_ALIAS`
Here are some important things to consider while using the `CANT_ALIAS`
macro in your program:

- *Are you sure that the scalar values you are passing as arguments to
  `CANT_ALIAS` are indeed expected to never alias with each other during
  runtime?*  If you are not sure, you must not use the `CANT_ALIAS` macro
  as that may cause your program to behave incorrectly in the presence
  of compiler optimizations.

* *You may be able to check your `CANT_ALIAS` annotations using OOElala's
  UB-sanitizer extension*.
  If you want to check if your `CANT_ALIAS` annotations are correct, you
  may compile the code using the UB-sanitizer extension of OOElala. When
  the compiled executable is executed on high-coverage test inputs, any
  mistakes in your `CANT_ALIAS` annotations would likely get uncovered.
  However, please be aware that the probability of the UB-sanitizer extension
  catching a wrong `CANT_ALIAS` annotation depends on the coverage of your
  testsuite.  For example, if your testsuite is incomplete, the incorrect
  `CANT_ALIAS` annotation may escape into your production code and may
  cause a failure in a production run.

- *Are the must-not-alias relationships already possible to infer for
  the compiler?* If so, the `CANT_ALIAS` specification may be unnecessary.

- *It is okay to add multiple `CANT_ALIAS` annotations even if they are
   redundant*.
   Here is a code example where multiple calls to `CANT_ALIAS` are required
   for best results:
```
static void kernel_gesummv(...) {
    int i, j;
#pragma scop
    for (i = 0; i < _PB_N; i++) {
        tmp[i] = SCALAR_VAL(0.0);
        y[i] = SCALAR_VAL(0.0);
        for (j = 0; j < _PB_N; j++) {
#ifndef POLLY
            CANT_ALIAS(A[i][j], B[i][j], x[j], y[i], tmp[i]);
#else
            CANT_ALIAS(tmp[i], x[j], A[i][j]);
            CANT_ALIAS(y[i], x[j], B[i][j]);
#endif
            tmp[i] = A[i][j] * x[j] + tmp[i];
            y[i] = B[i][j] * x[j] + y[i];
        }
        y[i] = alpha * tmp[i] + beta * y[i];
    }
#pragma endscop
}
```

* *Multiple redundant `CANT_ALIAS` annotations may sometimes be required
  to cover up the phase-ordering problem*. Below is another example (slightly modified version of our illustrative example) where multiple redundant annotations were required for best results. In this example, if only the first `CANT_ALIAS` annotation (at function entry) is present and the second `CANT_ALIAS` annotation is removed (inside the loop), the OOElala algorithm based on the llvm-8.0.0 compiler is unable to eliminate the loop at O3 optimization level, due to the notorious phase-ordering problem as explained below:
    1. The computation of lvalue `**c` at the loop head requires the
       computation of the address `*c`. In the unoptimized program, `*c`
       is computed twice: first for our `CANT_ALIAS` annotation at function
       entry, and second for the computation of `**c` in the only statement
       in the loop body. These two computations are distinct in the unoptimized
       program.
    2. The must-not-alias relationship is inferred only for the value computed by
       the first computation (at function entry) and not for the second computation
       (inside the loop body).
    3. It is possible for the *common-subexpression elimination* (CSE) compiler
       optimization pass to identify that the two distinct computations of 
       `*c` (as explained above) are actually computing the same value and
       hence the redundant second computation can be eliminated and replaced 
       by the first computed value. This would also ensure that the results
       of OOElala's alias analysis (for the first `**c`) become available
       within the loop body (because now they are using the same intermediate
       computed value for both computations). However, we find that CSE 
       triggers later than required (phase-ordering problem) in the O3 
       optimization pipeline.
    4. The *loop invariant code motion* (LICM)
       compiler optimization pass is responsible for identifying loop-invariant
       computation.  In this example, in the presence of the required must-not-alias
       information, it would be able to identify that `*a`, `*b`, and `*c` are
       loop invariant and thus the loop can be eliminated and only the updates
       performed by the last iteration need to be retained. However, because CSE
       has not yet executed, LICM is unable to use the information that `**c` does
       not alias with other integer accesses within the loop body based on the
       `CANT_ALIAS` annotation at function entry.  Thus LICM has to conservatively infer
       that `*a` and `*b` could change after each iteration (because they may alias with `**c`).
    5. This problem gets resolved if we add another `CANT_ALIAS` annotation inside 
       the loop body itself (as shown below). This problem can also be solved 
       by configuring the optimization pipeline such that LICM runs again after CSE.
```
void foo(int *a, int *b, int **c, int *d) {
    CANT_ALIAS(*a, *b, **c, *d);
    for (int i = 0; i < 256; i++) {
      CANT_ALIAS(*a, *b, **c, *d);  //redundant annotation required due to phase-ordering problem
      **c = *a * i + *b / (*d + i);
    }
}
```

- *OOElala infers must-not-alias relationships between _all_ intermediate
   lvalues of the arguments passed to `CANT_ALIAS`*.
  Consider the annotation `CANT_ALIAS(*a, *b, **c, *d)`: here, apart from
  inferring that `*a` cannot alias with `**c`, OOElala also infers that
  `*a` cannot alias with `*c`. This may or may not be desired by the programmer.
  In general, the C language does not allow two lvalues with incompatible
  types to alias anyways; thus presumably if `*a` has the same type as `**c`,
  then it would usually be true that `*a` and `*c` have incompatible types.
  The only exception to this rule is the (signed or unsigned) character type:
  a character-type lvalue is allowed to alias with an lvalue of any other type.
  If the programmer does not want the compiler to infer must-not-alias
  relationships between intermediate lvalues (and only wants to infer these
  relationships between final lvalues), then the programmer should use temporary
  local variables, e.g., `e = *c` followed by `CANT_ALIAS(*a, *b, *e, *d)`.
  It is important that these temporary local variables are not "address-taken" so
  they are eventually promoted as LLVM registers (and thus aliasing relationships
  on the addresses of these local variables become meaningless).
  In general, it is possible to make mistakes while specifying these annotations,
  and hence it is a good idea to run OOElala's UBSan checks to ensure
  that your `CANT_ALIAS` annotations are correct.

- *Are you adding the `CANT_ALIAS` annotation at the correct program location?*
   The location of the `CANT_ALIAS` annotation is crucial because (a) the
   specified must-not-alias relationships must hold at the same program
   point (where the annotation has been created); and (b) the choice of
   location may have an impact on the optimizations performed by the
    compiler. For example, adding annotations in the inner loops are
    more consequential than adding annotations at program points where
    the code is executed only once.

- *`CANT_ALIAS` annotations do not add any runtime overhead.* It is perfectly
  safe to add `CANT_ALIAS` annotations in the performance-critical inner
  loops of your program without fear of any slowdown. All optimizing
  compilers will be able to optimize out this macro because it is
  very easy to identify that this is a no-op.  However only compilers
  that implement the OOElala algorithm will be able to take advantage
  of the extra information encoded through the `CANT_ALIAS` annotation.

- *`CANT_ALIAS` is more general than the C99 restrict keyword*. As explained
  in the OOElala paper, `CANT_ALIAS` can specify must-not-alias relationships
  at a finer granularity than the restrict keyword.  Also it can be added
  anywhere in the program.  The compiler support required to exploit these
  annotations is relatively simple.
