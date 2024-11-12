#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>

#define SIZE 50

int Reduction(int* input, int sum, int product, int max, int min, int operation){

	// Sum Operation
	if (operation == 0){
		sum = 0;
		for (int i=0; i < SIZE; i++){
			// output[i] += input[i];
			sum += input[i];
		}
		//printf("Sum: %d", output[SIZE]);	
		// return output[SIZE-1];
		return sum;

	}	

	// Product Operation
	if (operation == 1){
		product = 1; // can't start at 0 bc everything will be 0 when multiplied, but anything *1 is just itself so 1 is fine
		for (int i=0; i < SIZE; i++){
			//output[i] *= input[i];
			product *= input[i];
		}	
		// printf("Product: %d", output[SIZE]);	
		// return output[SIZE];
		return product;

	}

	// Max Operation
	if (operation == 2){
		max = input[0];
		for (int i=0; i < SIZE; i++){
			if (max < input[i]) {
				max = input[i];
			}	
		}	
		// printf("Max: %d", max);	
		return max;
	}

	// Min Operation
	if (operation == 3){
		min = input[0];
		for (int i=0; i < SIZE; i++){
			if (min > input[i]) {
				min = input[i];
			}	
		}
		// printf("Min: %d", min);	
		return min;
	}

	// Another operation given
	else {
		return 0;
	}
}

int main(){
	// allocate memory
	int* input = (int*) malloc(sizeof(int) * SIZE);
	// int* output = (int*) malloc(sizeof(int) * SIZE);
	int sum, product, max, min;

  	// initialize inputs
  	for (int i = 0; i < SIZE; i++) {
  		input[i] = 1;
   	}

	printf("Sum: %d\n", Reduction(input, sum, product, max, min, 0));
	printf("Product: %d\n", Reduction(input, sum, product, max, min, 1));
	printf("Max: %d\n", Reduction(input, sum, product, max, min, 2));
	printf("Min: %d\n", Reduction(input, sum, product, max, min, 3));

	// Freeing memory
	free(input);
	
	return 0;
	
}
