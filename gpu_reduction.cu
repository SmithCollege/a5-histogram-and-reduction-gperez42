#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>

#define SIZE 4096 // array size
#define BLOCKSIZE 1024 // number of threads per block

// Sources: https://developer.download.nvidia.com/assets/cuda/files/reduction.pdf, Microsoft Copilot for help managing memory issues

__global__ void Reduction(int* input, int operation) {
	 __shared__ int sdata[SIZE];
	// __shared__ int sdata[BLOCKSIZE * 2];
	unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;

	
	// Initialize shared memory with values from global memory
    sdata[threadIdx.x] = (i < SIZE) ? input[i] : 0;
    if ((i + BLOCKSIZE) < SIZE) {
        sdata[threadIdx.x + BLOCKSIZE] = input[i + BLOCKSIZE];
    } else {
        sdata[threadIdx.x + BLOCKSIZE] = 0;
    }
  	__syncthreads();
  	
    // Sum Operation
    if (operation == 0) {
        for (unsigned int stride = 1; stride <= blockDim.x; stride *= 2) {
            __syncthreads();
            if (threadIdx.x % stride == 0) {
                sdata[2 * threadIdx.x] += sdata[2 * threadIdx.x + stride];
            }
        }
    }
    
	if (operation == 1){
		for (unsigned int stride = 1; stride <= blockDim.x; stride *= 2) {
	        __syncthreads();
	        if (threadIdx.x % stride == 0) {
	            sdata[2 * threadIdx.x] *= sdata[2 * threadIdx.x + stride];
	        }
	    }
	}

	if (operation == 2) {
	    //max = sdata[0];
		for (unsigned int stride = 1; stride <= blockDim.x; stride *= 2) {
	    	__syncthreads();
		    //if (max < sdata[2 * threadIdx.x + stride]) {
		   if (sdata[2 * threadIdx.x] < sdata[2 * threadIdx.x + stride]) {
		        sdata[2 * threadIdx.x] = sdata[2 * threadIdx.x + stride];
		        //max = sdata[2 * threadIdx.x];
		    }
		}
	}

	if (operation == 3) {
		//min = sdata[0];
		for (unsigned int stride = 1; stride <= blockDim.x; stride *= 2) {
	    	__syncthreads();
		    //if (min > sdata[2 * threadIdx.x + stride]) {
		    if (sdata[2 * threadIdx.x] > sdata[2 * threadIdx.x + stride]) {
		        sdata[2 * threadIdx.x] = sdata[2 * threadIdx.x + stride];
		        //min = sdata[2 * threadIdx.x];
		    }
		}
	}


   if (threadIdx.x == 0) {
            input[blockIdx.x] = sdata[0];
            printf("Result: %d\n", input[0]);
        }
}


int main() {
    // Allocate memory
    int *input;
    // int x;
    cudaMallocManaged(&input, SIZE * sizeof(int));

    // Initialize inputs
    for (int i = 0; i < SIZE; i++) {
        input[i] = 1;
    }
    int x = (SIZE + BLOCKSIZE * 2 - 1) / (BLOCKSIZE * 2);

	// Check if SIZE is a multiple of BLOCK_SIZE 
	if (SIZE % BLOCKSIZE != 0) { 
		if (SIZE > BLOCKSIZE) { 
			x += 1; 
			printf("Number of blocks (with extra): %d\n", x); 
		} 
	} else { 
			printf("Number of blocks (perfectly divisible): %d\n", x); 
		}
   
    // Launch the kernel with the calculated number of blocks
    //Reduction<<<x, BLOCKSIZE>>>(input, 0); // sum
   	// Reduction<<<x, BLOCKSIZE>>>(input, 1); // product
    //Reduction<<<x, BLOCKSIZE>>>(input, 2); // max
    //Reduction<<<x, BLOCKSIZE>>>(input, 3); // min

    cudaDeviceSynchronize();

    // Sum the results from each block - uncomment when operation is 0
    /*
    int sum = 0;
    for (int i = 0; i < x; i++) {
        sum += input[i];
    }
    */
    
	// Multiply the results from each block - uncomment when operation is 1 
	/*
	int product = 1;
	for (int i = 0; i < x; i++) { 
	 	product *= input[i]; 
	}
	*/

	// Find the max from all blocks - uncomment when operation is 2
	/*
	int max = input[0];
	for (int i=0; i < SIZE; i++){
		if (max < input[i]) {
			max = input[i];
		}
	}
	*/

	// Find the min from all blocks - uncomment when operation is 3
	int min = input[0];
		for (int i=0; i < SIZE; i++){
			if (min > input[i]) {
				min = input[i];
			}
		}

	
	 
    printf("%s\n", cudaGetErrorString(cudaGetLastError()));
    //printf("Final Sum: %d\n", sum); // uncomment when operation is 0
    //printf("Final Product: %d\n", product); // uncomment when operation is 1
    //printf("Final Max: %d\n", max); // uncomment when operation is 2
    printf("Final Min: %d\n", min); // uncomment when operation is 3
    
    //printf("Final Sum: %d\n", input[0]);

    // Free memory
    cudaFree(input);

    return 0;
}
