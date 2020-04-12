#include <stdlib.h>

void kern_init(int **X, int *W, int N);

int main() {
	const int length = 1000;
	const int num_runs = 1000;

	int *x[length];
	int w[length];

	for (int i = 0; i < length; i++)
		x[i] = malloc(length * sizeof(int));
	
	for (int j = 0; j < num_runs; j++) {
		kern_init(x, w, length);
	}
	
	return 0;
}
