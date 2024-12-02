#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>

#define SIZE 50

//  multi-kernel for being able to handle an array larger than 2048

__global__ void Reduction(int* input, int* output, int operation){
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

/*
	// Sum Operation
	if (operation == 0){
		for (unsigned int stride = 1; stride <= blockDim.x; stride *= 2) {
			if (SIZE % stride == 0){
				//output[stride] = input[stride] + input[stride*2];
				//output[2*SIZE] = input[2*SIZE] + input[2*SIZE*stride];
				output[2*SIZE] = input[2*SIZE] + input[2*SIZE*stride];

			}
				
		}
	printf("Sum: %d\n", output[SIZE]);
	// printf("Output: %d", output[stride]);
	}	
	//return output[SIZE];
*/


	if (operation == 0) {
		output[SIZE] = 0;
		for (unsigned int stride = blockDim.x; stride >= 1; stride /= 2) {
		 	
		 __syncthreads();

	
			if (SIZE < stride) {
		 		output[SIZE] += input[SIZE+stride];
		 	}
		 
		 /*
		 	if (threadIdx.x < stride) {
		 		output[threadIdx.x] += output[threadIdx.x+stride];
		 	}
		 */		
		}	
	
	printf("Sum: %d\n", output[SIZE]);
	
	}


}

int main(){
	// allocate memory
	int *input, *output; 
	// int sum;	
	cudaMallocManaged(&input, sizeof(int) * SIZE);
	cudaMallocManaged(&output, sizeof(int));

  	// initialize inputs
  	for (int i = 0; i < SIZE; i++) {
  		input[i] = 1;
   	}
	
	// Reduction(input, output, 0);
	// printf("Output: %d", Reduction(input, output, 0));
	Reduction<<<1, SIZE>>>(input, output, 0);

	/*
	  // check results
 	 for (int i = 0; i < SIZE; i++) {
    	printf("%d ", output[i]);
  	 }
 	 printf("\n");
 	*/ 
 	printf("%s\n", cudaGetErrorString(cudaGetLastError()));

	cudaFree(input);
	cudaFree(output);

	return 0;
	
}
