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


//class testCLass {
//public:
//	int a, b;
//public: cv::Mat testFun();
//};

using namespace System;

namespace UTCudaLib {
	public ref class clsCuda
	{
		// TODO: Add your methods for this class here.
	public:
		clsCuda() {}
		//static void invokGPU(float* t, float* v, int tno);
		static cli::array<double, 2>^ invokGPU();
		int Test(int a, int b)
		{
			return 7;
		}
	};
}
