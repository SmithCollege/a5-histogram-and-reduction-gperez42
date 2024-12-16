#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>

#define SIZE 2048 // array size
#define BLOCKSIZE 1024 // number of threads per block

// Sources: https://developer.download.nvidia.com/assets/cuda/files/reduction.pdf

// multi-kernel for being able to handle an array larger than 2048
// gpu can't return from the kernel, so reduction can be broken down into blocks

__global__ void Reduction(int* input, int operation){
	__shared__ int sdata[SIZE];
	unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
	
	// Initialize shared memory with values from global memory
	sdata[threadIdx.x] = input[i]; // reads in the first 1000 elements
	sdata[threadIdx.x + 1024] = input[i+1024];
	/*
	 // Initialize shared memory with values from global memory
    if (i < SIZE) {
        sdata[threadIdx.x] = input[i];
    } else {
        sdata[threadIdx.x] = 0;  // Ensure unused threads have 0 in shared memory
    }
    */
	__syncthreads();
	
// Sum Operation
	if (operation == 0) {
		// int output = 0;
		for (unsigned int stride = 1;  stride <= blockDim.x; stride *= 2) {
		 	
		 __syncthreads();
			
		 	if (threadIdx.x % stride == 0) {
		 	//	input[2*threadIdx.x] += input[2*threadIdx.x+stride];
		 	// sdata[2*threadIdx.x] += sdata[2*threadIdx.x+stride];
		 		sdata[2*threadIdx.x] += sdata[2*threadIdx.x + stride];

		 	}
		 		
		}	

		if (threadIdx.x == 0) {
			input[0] = sdata[0];
			// printf("Sum: %d\n", input[blockDim.x]);

			printf("Sum: %d\n", input[0]);
		}
	// printf("Sum: %d\n", input[blockDim.x]);

	}

}

int main(){
	// allocate memory
	// int *input, *output; 
	int *input;
	// int output;
	int x=1; // Number of blocks we're launching
	
	cudaMallocManaged(&input, SIZE*sizeof(int));
	// cudaMallocManaged(&output, sizeof(int) * SIZE);

  	// initialize inputs
  	for (int i = 0; i < SIZE; i++) {
  		input[i] = 1;
   	}

	/*
	x =  (SIZE + BLOCKSIZE - 1) / BLOCKSIZE; // calculating the new number of blocks for next iteration 
	
	 // Check if SIZE is a multiple of BLOCK_SIZE
    if (SIZE % BLOCKSIZE != 0) {
      // If not a perfect multiple, calculate the number of blocks needed
      if (SIZE > BLOCKSIZE) {
        x = SIZE / BLOCKSIZE + 1; // Add 1 if not perfectly divisible
        printf("Number of blocks (with extra): %d\n", x);
      }
    } else {
      x = SIZE / BLOCKSIZE; // Perfectly divisible case
      printf("Number of blocks (perfectly divisible): %d\n", x);
    }
    */
    
  	// Launch the kernel with the calculated number of blocks
    Reduction<<<x, BLOCKSIZE>>>(input, 0);
 	
 	cudaDeviceSynchronize(); 
 	
 	printf("%s\n", cudaGetErrorString(cudaGetLastError()));

 	printf("Final Sum: %d\n", input[0]);

	cudaFree(input);
	// cudaFree(output);

	return 0;
	
}
