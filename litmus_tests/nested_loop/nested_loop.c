/*
Optimisation opportunity: Register allocation of W[i]
for the inner loop using the additional predicate for
no alias between W[i] and X[i][j]. foo() has been made
local as we don't want the compiler to make conservative
assumptions about the memory access patterns of foo()
*/

int foo(int i, int j) {
	return 2 * i + j * j / 2;
}

void kern_init(int **X, int *W, int N) {
	for (int i = 0; i < N; i++) {
		W[i] = 0;
		for (int j = 0; j < N; j++) {
			W[i] += (X[i][j] = foo(i, j));
		}
	}
}
