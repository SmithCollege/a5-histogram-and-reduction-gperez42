#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>

#define SIZE 50

int Reduction(int* input, int* output, int operation){
	// Stride is distance to the next value being
	// accumulated into the threads mapped position
	// in the partialSum[] aray
	/*
	for (unsigned int stride = 1; stride <= blockDim.x; stride *= 2) {
		 __syncthreads();
		
		 if (t % stride == 0) {
			 partialSum[2*t]+= partialSum[2*t+stride];
		}
	}
	*/

	// Sum Operation
	if (operation == 0){
		for (unsigned int stride = 1; stride <= SIZE; stride *= 2) {
			if (SIZE % stride == 0){
				// output[stride] = input[stride] + input[stride*2];
				output[2*SIZE] = input[2*SIZE] + input[2*SIZE*stride];
			}
				
		}
	// printf("Output: %d", output[stride]);
	}	
}

int main(){
	// allocate memory
	int* input = (int*) malloc(sizeof(int) * SIZE);
	int* output = (int*) malloc(sizeof(int) * SIZE);

  	// initialize inputs
  	for (int i = 0; i < SIZE; i++) {
  		input[i] = 1;
   	}
	
	//Reduction(input, output, 0);
	printf("Output: %d", Reduction(input, output, 0));

	/*
	  // check results
 	 for (int i = 0; i < SIZE; i++) {
    	printf("%d ", output[i]);
  	 }
 	 printf("\n");
 	*/ 
	

	return 0;
	
}
