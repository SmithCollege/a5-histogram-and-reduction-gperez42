#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>

#define SIZE 50
#define BLOCKSIZE 1

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
	int x; // Number of blocks we're launching
	
	cudaMallocManaged(&input, SIZE*sizeof(int));
	// cudaMallocManaged(&output, sizeof(int) * SIZE);

  	// initialize inputs
  	for (int i = 0; i < SIZE; i++) {
  		input[i] = 1;
   	}

	// Reduction(input, output, 0);
	// printf("Output: %d", Reduction(input, output, 0));

	/*
	if (SIZE < 2048) {
		Reduction<<<1, SIZE>>>(input, 0);
	}
	else{
		BLOCKSIZE = SIZE/2; 
		Reduction<<<BLOCKSIZE, SIZE>>>(input, 0);

	}
	*/

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
    
  	// Launch the kernel with the calculated number of blocks
    Reduction<<<BLOCKSIZE, SIZE>>>(input, 0);
 	
 	cudaDeviceSynchronize(); 
 	
 	printf("%s\n", cudaGetErrorString(cudaGetLastError()));

	cudaFree(input);
	// cudaFree(output);

	return 0;
	
}
