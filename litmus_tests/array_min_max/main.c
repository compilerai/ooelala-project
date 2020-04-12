extern void array_min_max(double *arr, int len, int *min, int *max);

int main() {
	const int length = 100000;
	const int num_runs = 1000;

	double a[length];
	
	for (int i = 0; i < length; i++) {
		a[i] = i;
	}
	
	for (int j = 0; j < num_runs; j++) {
		int min_index, max_index;
		array_min_max(a, length, &min_index, &max_index);
	}
	
	return 0;
}
