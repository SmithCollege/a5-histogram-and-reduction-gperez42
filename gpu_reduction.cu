#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>

#define SIZE 50

//  multi-kernel for being able to handle an array larger than 2048
// gpu can't return from the kernel
__global__ void Reduction(int* input, int operation){

// Sum Operation
	if (operation == 0) {
		for (unsigned int stride = 1;  stride <= blockDim.x; stride *= 2) {
		 	
		 __syncthreads();

			
		 	if (threadIdx.x % stride == 0) {
		 		input[2*threadIdx.x] += input[2*threadIdx.x+stride];
		 	}
		 		
		}	

	if (threadIdx.x == 0) {
		printf("Sum: %d\n", input[0]);
	}
	
	}

}

int main(){
	// allocate memory
	// int *input, *output; 
	int *input;
	
	cudaMallocManaged(&input, sizeof(int) * SIZE);
	// cudaMallocManaged(&output, sizeof(int) * SIZE);

  	// initialize inputs
  	for (int i = 0; i < SIZE; i++) {
  		input[i] = 1;
   	}
	
	// Reduction(input, output, 0);
	// printf("Output: %d", Reduction(input, output, 0));

	Reduction<<<1, SIZE>>>(input, 0);

/*
	if SIZE < 2048{
		Reduction<<<1, SIZE>>>(input, output, 0);
	}
	
	else{
		Reduction<<<1, SIZE>>>(input, output, 0);
		// ReductionLarge<<<>>>();
	}
*/

	/*
	  // check results
 	 for (int i = 0; i < SIZE; i++) {
    	printf("%d ", output[i]);
  	 }
 	 printf("\n");
 	*/ 
 	printf("%s\n", cudaGetErrorString(cudaGetLastError()));

	cudaFree(input);
	// cudaFree(output);

	return 0;
	
}
