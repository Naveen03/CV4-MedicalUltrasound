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
#include <opencv2/opencv.hpp>

using namespace System;


namespace UTCudaLib {

	static std::ofstream cppLog;

	public class Display {


		float samples, c0, s_freq, pitch, rc, s_angle, Nx, Nz;
		cv::Mat theAxis, rAxis, theMat, rMat, xM, yM, xM1, yM1, ang_view_map_x, ang_view_map_y, ang_view_map_ix, ang_view_map_iy;
		std::map <std::string, float> probPrms;

	public:

		int rows = 1024;
		int cols = 254;
		int roc_rows = 0;
		int call_count = 0;
		double min, max; // to hold min max values after each transformation
		double** imgArray = nullptr;

		std::ofstream mFile;
		cv::Mat imgMat, envolepMat, curveMat, logMat, polarMat, dispMat;
		cv::Mat errorMat = cv::Mat::zeros(rows, cols, CV_8UC1);

		Display() {
			//probPrms["MAX_ITER"]	= 0.0;
			//probPrms["N_RX"]		= 0.0;
			//probPrms["MAX_LINE"]	= 0.0;
			//probPrms["PI"]			= 0.0;
			//probPrms["MASK_WIDTH"]	= 0.0;
			//probPrms["TILE_SIZE"]	= 0.0;
			//probPrms["n_threads"]	= 0;//num_threads
			//probPrms["rx_fnumber"]	= 0;
			//probPrms["samples"]		= 0;
			//probPrms["n_elements"]	= 0;
			//probPrms["s_freeq"]		= 0; // sampling_frequency
			//probPrms["c"]			= 0;
			//probPrms["n_active"]	= 0;
			//probPrms["channels"]	= 0;
			//probPrms["Nx"]			= 0;
			//probPrms["Nz"]			= 0;
			//probPrms["frames"]		= 0;
			//probPrms["n_frames"]	= 0; //n_frames
			//probPrms["skip_frames"]	= 0;
			//probPrms["db_value"]	= 0;
			//probPrms["pitch"]		= 0;
			//probPrms["aper_len"]	= 0;
			//probPrms["zd"]			= 0;
			//probPrms["ss"]			= 0; //sample_spacing
			//probPrms["d_convert"]	= 0; //d_convert
			//probPrms["rc"]			= 0;
			//probPrms["s_angle"]		= 0; //scan_angle
			//probPrms["pixels"]		= 0;
			//probPrms["pix_cha"]		= 0;
		}

	public:

		void init();

		void readCurviLinearProbParams(const char* path, double* bmodeParms);

		void initCurviLinear();

		cv::Mat map2CurviLinear(cv::Mat inImg, int bottom_crop);
	};


	public ref class clsCuda
	{
		static double min;
		static double max;

	private:
		static int rows;
		static int cols;
		static int probe_type;
		static int call_count;


		//static std::ofstream mFile;
		static double* bModeConfig;
		static Display* displayHandle;
		static cudaBackEnd* testObj;
		static bool debug = true;
		static float** imgArray = nullptr;
		//static cv::Mat& errorMat;
		static cv::Mat* imgMat = new cv::Mat(clsCuda::rows, clsCuda::cols, CV_32FC1);
		static cv::Mat* envolepMat = new cv::Mat(clsCuda::rows, clsCuda::cols, CV_32FC1);
		static cv::Mat* curveMat = new cv::Mat(clsCuda::rows, clsCuda::cols, CV_32FC1);
		static cv::Mat* logMat = new cv::Mat(clsCuda::rows, clsCuda::cols, CV_32FC1);
		static cv::Mat* polarMat = new cv::Mat(clsCuda::rows, clsCuda::cols, CV_32FC1);
		static cli::array<double, 2>^ dataToFrontEnd; 

	public:
		
		clsCuda::clsCuda() {
			//dataToFrontEnd = gcnew cli::array<double, 2>(cols, rows);

		}

		static void selectProbe(int);

		static cli::array<double, 2>^ invokGPU();

		static void postProces(cv::Mat* inMat, cv::Mat* outMat, float params);


	};
}
