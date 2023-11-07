#pragma once

#include <stdlib.h>
#include <stdio.h>
#include <iomanip>
#include <ctime>
#include <math.h>
#include <string.h>
//#define PI 3.14159
//#define TILE_SIZE 4
#pragma once

#include <stdlib.h>
#include <stdio.h>
#include <iomanip>
#include <ctime>
#include <math.h>
#include <string.h>
//#define PI 3.14159
//#define TILE_SIZE 4
//#define MASK_WIDTH 364

// includes, project
#include <cuda_runtime.h>
#include <cufft.h>      /// Add "cufft.lib" in the linker input to use cufft. 
#include "cuda.h"
#include <windows.h>
#include "device_launch_parameters.h"
#include "host_func1.h"
#include "beamforming_func1.h"
#include "device_func1.h"
#include "cudaHeader.cuh"
#include "testheader.cuh"


//extern std::string imageComputeCudaWrap::cuMemInit();
//extern void imageComputeCudaWrap::cuMemInitTest(char*, float*, float*, float*,
//	float*, float*, float*, float*,
//	float*, float*, float*, float*);

using namespace System;

namespace UTCudaLib {
	public ref class clsCuda
	{
	private:
		static int probe_type;
		//static std::ofstream mFile;
		static double* bModeConfig;
		
		static cudaBackEnd* testObj;

	public:
		clsCuda() {
		}
		//static void invokGPU(float* t, float* v, int tno);
		static void selectProbe(int);
		static cli::array<double, 2>^ invokGPU();
	};
}
