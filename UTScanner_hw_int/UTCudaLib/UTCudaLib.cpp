#include "pch.h"
#include "UTCudaLib.h"
//#include "Cuda.h"
//#include "cuda_runtime.h"
//#include "device_launch_parameters.h"
//#include "vector_types.h"
#include <opencv2/opencv.hpp>

extern double** imageGenProcessinCUDA();

cli::array<double, 2>^ ConvertMatto2DArray(double** img, int rows, int cols)
{
	cli::array<double, 2>^ data = gcnew cli::array<double, 2>(cols, rows);

	for (int rIdx = 0; rIdx < rows; rIdx++) {
		for (int cIdx = 0; cIdx < cols; cIdx++) {
			data[cIdx, rIdx] = img[rIdx][cIdx];
		}
	}

	return data;
}

cv::Mat Convert2DArraytoMat(double** data, int rows, int cols)
{

	double val, val2;
	cv::Mat img = cv::Mat::zeros(rows, cols, CV_64FC1);//(rows, cols, CV_64FC1);
	//System::IO::StreamWriter^ sw = gcnew System::IO::StreamWriter("C:\\Users\\Arun\\Documents\\Naveen\\buslab_project\\data\\test.txt");

	for (int rIdx = 0; rIdx < rows; rIdx++)
	{
		for (int cIdx = 0; cIdx < cols; cIdx++)
		{
			val = data[rIdx][cIdx];
			img.at<double>(rIdx, cIdx) = val;
		}
	}
	//cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/outputs/imgFromCpp.png", img);

	return img;
}

namespace UTCudaLib {
	cli::array<double, 2>^ clsCuda::invokGPU()
	{
		int croppedBot = 300;
		// testCLass testObj;
		//cv::Mat testMat1 = testObj.testFun();
		// cv::Mat testMat1 = cv::Mat::zeros(250, 1000, CV_8UC1);
		//cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/UTScannerApp/260923/testMat1.png", testMat1);

		auto current = std::chrono::system_clock::now();
		double** imgArray = imageGenProcessinCUDA();

		//cv::Mat testMat2 = cv::Mat::zeros(250, 1000, CV_8UC1);
		//cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/UTScannerApp/260923/testMat2.png", testMat2);

		cv::Mat matArray = Convert2DArraytoMat(imgArray, 1024 - croppedBot, 254);
		cli::array<double, 2>^ gcNewArray = ConvertMatto2DArray(imgArray, 1024 - croppedBot, 254); // Hardcoded the size of matrix
		return gcNewArray;
	}

}
