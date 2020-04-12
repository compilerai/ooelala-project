/*
Optimisation opportunity: Reg alloc of *min and *max
and moving the stores to *min and *max out of the loop
using the additional no alias predicate between *min
and *max
*/

void array_min_max(double *arr, int len, int *min, int *max) {
    	*min = *max = 0;
	for (int i = 1; i < len; i++) {
		*min = (arr[i] < arr[*min]) ? i : *min;
		*max = (arr[i] > arr[*max]) ? i : *max;
	}
}
