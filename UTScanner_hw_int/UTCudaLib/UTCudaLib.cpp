#include "pch.h"
#include <exception>
#include <chrono>
#include <fstream>
#include "UTCudaLib.h"
#include "cudaHeader.cuh"
#include "mat_operations.h"
#include <opencv2/opencv.hpp>

using std::chrono::high_resolution_clock;
using std::chrono::duration_cast;
using std::chrono::duration;
using std::chrono::milliseconds;

extern std::string imageComputeCudaWrap::cuMemInit();
extern int imageComputeCudaWrap::cuMemInitLinear(); // to init linear prob
extern int imageComputeCudaWrap::cuMemInitCurv(double*); // Initialize memmory for curLinear prob

extern double** imageComputeCudaWrap::computeCurveImg(double*); // compute imge from curvLinear array
extern double** imageComputeCudaWrap::computeLinearImg(); // to reading
extern double** imageComputeCudaWrap::computeImg();//

void readLinearProbParams(const char* path, double* bmodeParms) {

	std::string line, key_value, key;
	double v;
	//std::map <std::string, double> bmodeParms;

	std::ifstream paramFile;
	paramFile.open(path, std::ios::in);

	int i, j = 0;
	if (paramFile.is_open()) {
		while (getline(paramFile, line)) {
			std::stringstream word(line);
			//i = 0; // to get the key
			//while (getline(word, key_value, ',')) {
				////std::cout << key_value << std::endl;
				//if (i == 0)
				//	key = key_value;
				//else {
				bmodeParms[j] = stod(line);
				j++; // to get the count
				//}
				//i++;
			//}
		}
	}
	paramFile.close();

	// calculating other values
	//// iterator pointing to start of map
	//std::map<std::string, double>::iterator it = bmodeParms.begin();
	//// Iterating over the map using Iterator till map end.
	//while (it != bmodeParms.end())
	//{
	//	// Accessing the key
	//	std::string word = it->first;
	//	// Accessing the value
	//	double value = it->second;
	//	std::cout << word << " :: " << value << std::endl;
	//	// iterator incremented to point next item
	//	it++;
	//}

	// return bmodeParms;
}

void readCurviLinearProbParams(const char* path, double* bmodeParms) {
	/// -------------------READING THE DATA FILE------------------------------------------

	std::string line, key_value, key;
	double v;
	// std::map <std::string, double> bmodeParms;

	std::ifstream paramFile;
	paramFile.open(path, std::ios::in);

	int i, j = 0;
	if (paramFile.is_open()) {
		while (getline(paramFile, line)) {
			std::stringstream word(line);
			bmodeParms[j] = stod(line);
			j++;
		}
	}
	paramFile.close();

	//// calculating other values
	//double pitch = 0.465 / 1000;
	//double aper_len = (bmodeParms[9] - 1) * pitch * 1000;
	//double zd = pitch * bmodeParms[12] / (float)2;
	//double sample_spacing = bmodeParms[11] / bmodeParms[10] / (float)2;
	//double del_convert = bmodeParms[10] / bmodeParms[11];
	//double rc = 60.1 / 1000.0;
	//double scan_angle = (58 * bmodeParms[3]) / 180;
	//double pixels = bmodeParms[15] * bmodeParms[14];
	//double pix_cha = pixels * bmodeParms[13];
	//bmodeParms[j + 1] = pitch;
	//bmodeParms[j + 2] = aper_len;
	//bmodeParms[j + 3] = zd;
	//bmodeParms[j + 4] = sample_spacing;
	//bmodeParms[j + 5] = del_convert;
	//bmodeParms[j + 6] = rc;
	//bmodeParms[j + 7] = scan_angle;
	//bmodeParms[j + 8] = pixels;
	//bmodeParms[j + 9] = pix_cha;

	//// iterator pointing to start of map
	//std::map<std::string, double>::iterator it = bmodeParms.begin();
	//// Iterating over the map using Iterator till map end.
	//while (it != bmodeParms.end())
	//{
	//	// Accessing the key
	//	std::string word = it->first;
	//	// Accessing the value
	//	double value = it->second;
	//	std::cout << word << " :: " << value << std::endl;
	//	// iterator incremented to point next item
	//	it++;
	//}
	//return bmodeParms;
}

cli::array<double, 2>^ ConvertMatto2DArray(double** imgArray, int rows, int cols)
{
	cli::array<double, 2>^ data = gcnew cli::array<double, 2>(cols, rows);

	for (int rIdx = 0; rIdx < rows; rIdx++) {
		for (int cIdx = 0; cIdx < cols; cIdx++) {
			data[cIdx, rIdx] = imgArray[rIdx][cIdx];
			// imgArray[rIdx][cIdx];
		}
	}

	return data;
}

cli::array<double, 2>^ ConvertMatto2DArray(float* img, int rows, int cols)
{
	cli::array<double, 2>^ data = gcnew cli::array<double, 2>(cols, rows);

	for (int rIdx = 0; rIdx < rows; rIdx++) {
		for (int cIdx = 0; cIdx < cols; cIdx++) {
			data[cIdx, rIdx] = img[rIdx * cols + cIdx];
			//data[cIdx, rIdx] = 0.00;
		}
	}

	return data;
}

cli::array<double, 2>^ ConvertMatto2DArray(int rows, int cols)
{
	cli::array<double, 2>^ data = gcnew cli::array<double, 2>(cols, rows);

	for (int rIdx = 0; rIdx < rows; rIdx++) {
		for (int cIdx = 0; cIdx < cols; cIdx++) {
			data[cIdx, rIdx] = 0.00;
		}
	}

	return data;
}

cli::array<double, 2>^ ConvertMatto2DArray(cv::Mat inMat, int rows, int cols)
{
	cli::array<double, 2>^ data = gcnew cli::array<double, 2>(cols, rows);

	for (int rIdx = 0; rIdx < rows; rIdx++) {
		for (int cIdx = 0; cIdx < cols; cIdx++) {
			data[cIdx, rIdx] = inMat.at<double>(rIdx, cIdx);
		}
	}

	return data;
}

cv::Mat Convert2DArraytoMat(double** data, int rows, int cols)
{

	double val, val2;
	cv::Mat img = cv::Mat::zeros(rows, cols, CV_64FC1);//(rows, cols, CV_64FC1);

	for (int rIdx = 0; rIdx < rows; rIdx++)
	{
		for (int cIdx = 0; cIdx < cols; cIdx++)
		{
			val = data[rIdx][cIdx];
			img.at<double>(rIdx, cIdx) = val;
		}
	}


	return img;
}

cv::Mat Convert2DArraytoMat(float* data, int rows, int cols)
{

	double val, val2;
	cv::Mat img = cv::Mat::zeros(rows, cols, CV_64FC1);//(rows, cols, CV_64FC1);

	for (int rIdx = 0; rIdx < rows; rIdx++)
	{
		for (int cIdx = 0; cIdx < cols; cIdx++)
		{
			val = data[rIdx * cols + cIdx];
			img.at<double>(rIdx, cIdx) = val;
		}
	}
	//cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/outputs/imgFromCpp.png", img);

	return img;
}

std::map <std::string, float> probPrms;

cv::Mat map2CurviLinear(cv::Mat inImg, std::map <std::string, float> probPrms, int bottom_crop) {

	// image in polar cordinate but currenly represented in cartesian cordinate  
	//cv::Mat inImg = cv::imread("C:/Users/navee/Documents/projects/USI_processing/BmodeMat_fromnew.png", 0);
	int rows = inImg.rows;
	int cols = inImg.cols;
	float sample_spacing = probPrms["c0"] / probPrms["fs"] / 2;
	float dz = sample_spacing * probPrms["samples"] / probPrms["Nz"];
	int roc_rows = floor(probPrms["rc"] / dz);
	//std::cout << "roc_rows : " << roc_rows << std::endl;
	int total_rows = roc_rows + probPrms["Nz"]; // in opencv implementation total rows should be = residual_rows + image rows
	float curve_width = 2 * (probPrms["Nz"] * std::sin(probPrms["scan_angle"] / 2));

	// declaring the canvas matrix in which the polar image will get plotted
	int dxRows = total_rows;
	int dxCols = curve_width;

	// std::cout << "curve_width : " << curve_width << std::endl;
	cv::Mat theAxis = cv::Mat(1, int(probPrms["Nx"]), CV_32FC1); // angle distribution across columsn, a.k.a across scanning elements i.o.w  firing angle of each transducer element
	cv::Mat rAxis = cv::Mat(total_rows, 1, CV_32FC1); // depth or radius of coverage for each transducer element

	// Creating the angle axis whcih rnges from -0.5 to +0.5 radians (-28 to +28 degree)
	// This will be repeated along the y (row) direction (same across all row)
	for (int i = 0; i < theAxis.cols; i++) {
		theAxis.at<float>(0, i) = -probPrms["scan_angle"] / 2 + (i * (probPrms["scan_angle"]) / probPrms["Nx"]);
	}

	// Creating the magnitude axis whcih ranges from 0 to i*total_rows (0 to total_rows)
	// This will be repeated along the x (column) direction (same across all cols)
	for (int i = 0; i < total_rows; i++) {
		rAxis.at<float>(i, 0) = probPrms["Nz"] * i;
	}

	// creating grids for plotting using theta and r
	cv::Mat theMat, rMat, xM, yM;
	cv::repeat(theAxis, total_rows, 1, theMat); // Repeating along the y (row)
	cv::repeat(rAxis, 1, probPrms["Nx"], rMat); // Repeating along the x (cols)

	// Calculating corresponding 'x', 'y' location from 'r' and 'angle'
	cv::polarToCart(rMat, theMat, xM, yM);
	double minX, maxX, minY, maxY;
	cv::minMaxIdx(xM, &minX, &maxX); // to get the max 'x' value here it is 0.133884
	cv::minMaxIdx(yM, &minY, &maxY); // to get the max 'y' value here it is 0.111515

	//// Normalize values to fit rows and columns
	cv::Mat xM1 = xM * ((dxRows - 1) / maxX); // normalizing x values to fit the canvas column size - only required to test the plotting
	cv::Mat yM1 = yM * ((dxCols - 2) / (2.0 * std::max(std::abs(minY), maxY))); // normalizing the y values to fit the -row/2 to row/2 - only required to test the plotting
	yM1 = (dxCols / 2) + yM1; // converting the range from -row/2 to row/2 to 0 to row/2
	xM1.convertTo(xM1, CV_16UC1); // only required to test the plotting
	yM1.convertTo(yM1, CV_16UC1); // only required to test the plotting
	double minX1, maxX1, minY1, maxY1;
	cv::minMaxIdx(xM1, &minX1, &maxX1);
	cv::minMaxIdx(yM1, &minY1, &maxY1);
	//std::cout << "maxX1 : " << maxX1 << " maxY1 " << maxY1 << std::endl;

	assert(dxRows >= maxX1);
	assert(dxCols >= maxY1); // else plotting will not fit

	// matrices to hold the location of pixel (i.e, x & y) in the cartisian cordinate (i.e. in this image "inImg")
	// it will just range from x: 0--> inImg.cols, y: 0-->inImg.rows
	cv::Mat ang_view_map_x = cv::Mat::zeros(dxRows, dxCols, CV_32FC1);
	cv::Mat ang_view_map_y = cv::Mat::zeros(dxRows, dxCols, CV_32FC1);

	//cv::Mat canvasMat1 = cv::Mat::zeros(dxRows + 20, dxCols + 20, CV_8UC1); // added some padding to make sure about boundary conditions
	int i, j; // location of pixel in cartesian cordinates plotted in cartesian cordinates from input image "inImg"
	int x, y; // location of pixel in polar cordinates represented in cartesian cordinates 
	for (i = 0; i < xM1.rows; i++) {
		//int i = 100; 
		for (j = 0; j < xM1.cols; j++) {
			x = xM1.at<uint16_t>(i, j);
			y = yM1.at<uint16_t>(i, j);
			//canvasMat1.at<uchar>(x, y) = 255; // test the plotiing
			ang_view_map_x.at<float>(x, y) = j;
			ang_view_map_y.at<float>(x, y) = i;
		}
	}

	// this is to fill in some void points in the mapping matrix
	cv::Mat strel = cv::getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(7, 7));
	cv::dilate(ang_view_map_x, ang_view_map_x, strel);
	cv::dilate(ang_view_map_y, ang_view_map_y, strel);

	//cv::imshow("canvasMat1", canvasMat1);
	cv::Mat croppedImg;// , paddedInImg, remappedImg;
	cv::copyMakeBorder(inImg, croppedImg, roc_rows, 0, 0, 0, 0); // padding to adjust for 0--> residual area
	croppedImg = croppedImg(cv::Range(0, croppedImg.rows - bottom_crop), cv::Range(0, inImg.cols));
	cv::remap(croppedImg, croppedImg, ang_view_map_x, ang_view_map_y, 0);
	croppedImg = croppedImg(cv::Range(roc_rows, croppedImg.rows - bottom_crop), cv::Range(0, croppedImg.cols));

	return croppedImg;
}

cv::Mat map2Display(cv::Mat inImg, float log_const, float gain) {
	double min, max;

	cv::Mat logMat = logTransform(inImg);
	cv::minMaxIdx(logMat, &min, &max);
	//std::cout << "Range of values logMat : " << min << " , " << max << std::endl;

	//cv::Mat adjMat = logMat - (max / 2);
	//cv::minMaxIdx(adjMat, &min, &max);
	//std::cout << "Range of values adjMat : " << min << " , " << max << std::endl;

	//float db = 10;
	//cv::Mat dbMat = (logMat + gain) / gain;
	//cv::minMaxIdx(dbMat, &min, &max);
	//std::cout << "Range of values dbMat : " << min << " , " << max << std::endl;

	//cv::Mat intMat;
	//dbMat.convertTo(intMat, CV_8UC1, 255 / max);
	//cv::minMaxIdx(intMat, &min, &max);
	//std::cout << "Range of values intMat : " << min << " , " << max << std::endl;

	//logMat = logMat + std::abs(min);
	//logMat = logMat * (255.0 / std::abs(min) + max);

	return logMat;
}

cv::Mat process2Display(double** imgArray, int rows, int cols, float log_const, float gain, 
	std::map <std::string, float> probPrms, int bottom_crop=0, bool polar_form = false ) {
	cv::Mat outMat, polarMat;
	outMat = converttoMat(imgArray, rows, cols);
	//cv::imwrite("sample_output/outMat.png", outMat);
	if (polar_form == true) {
		outMat.copyTo(polarMat);
		polarMat = map2CurviLinear(outMat, probPrms, 450);
		cv::imwrite("sample_output/polarMat.png", polarMat);
	}
	else {
		polarMat = outMat;
	}
	
	//polarMat = polarMat(cv::Range(0, rows-bottom_crop), cv::Range(0, cols));
	polarMat = hilbertTrans4(polarMat, 1.0);
	polarMat = logTransform(polarMat); // log compression
	cv::imwrite("sample_output/logrMat.png", polarMat);

	return polarMat;
}

namespace UTCudaLib {
	void clsCuda::selectProbe(int probeID) {

		/*
		Function to perfomrm inilization (one time operation)
		1. Read the parameters to allocate CUDA memmory
		2. Init the h/w prob
		3. Read the setting file and keep in memmory
		4. Allocate and init reusable CUDA memmory
		*/
		int ok; //variable to check the success of calling each function
		const char* linear_param_path = "b_mode_linear_params2.csv";
		const char* curvilinear_param_path = "b_mode_curvilinear_params2.csv";
		const char* linear_setting_file = "out25.txt";
		const char* curvi_setting_file = "out25_curvi.txt";
		clsCuda::bModeConfig = new double[29];
		clsCuda::probe_type = probeID;
		//std::ofstream mFile;
		//mFile.open("sample_output/prob_type.txt");
		//mFile << "probeID : " << clsCuda::probe_type << std::endl;
		//mFile.close(); 

		if (clsCuda::probe_type == 1)		// read from Curvilinear prob
		{
			readCurviLinearProbParams(curvilinear_param_path, clsCuda::bModeConfig); //1
			ok = testObj->initGPUprobeC(clsCuda::bModeConfig);	//2
			ok = testObj->initHW();								//3
			ok = testObj->initSettingFile(linear_setting_file);	//4
		}

		else if (clsCuda::probe_type == 2)	// read from TV prob
		{
			//
		}

		else if (clsCuda::probe_type == 3)	// read from Linear prob
		{
			
			readLinearProbParams(linear_param_path, clsCuda::bModeConfig);
			ok = testObj->initGPUprobeC(clsCuda::bModeConfig);
			ok = testObj->initHW();
			ok = testObj->initSettingFile(linear_setting_file);
		}

		else if (clsCuda::probe_type == 4) // read from CSV
		{
			//
		}
	}

	cli::array<double, 2>^ clsCuda::invokGPU()
	{
		std::ofstream mFile;
		mFile.open("sample_output/callfun.txt");
		//clsCuda::probe_type = 4; // to read from CSV
		mFile << clsCuda::probe_type << std::endl;
		static int call_count = 0;
		int croppedBot = 300;
		double** imgArray;
		float* imgArray1;
		int rows = 1024;
		int cols = 254;
		auto t1 = 0, t2 = 0;
		cv::Mat envolepMat, curveMat;
		probPrms["samples"] = 3328;
		probPrms["c0"] = 1540;
		probPrms["fs"] = 10e6; // sampling_frequency
		probPrms["pitch"] = 0.4654 / 1000;
		probPrms["rc"] = 59.1 / 1000; // radius_of_curvature
		probPrms["scan_angle"] = 1; //in radians
		probPrms["Nx"] = 254;
		probPrms["Nz"] = 1024;
		bool curveProb = true;
		double min, max;
		cv::Mat testMat0 = cv::Mat::zeros(250, 1000, CV_8UC1);

		// switch statements 
		if (clsCuda::probe_type == 1) {

			try {
				//t1 = high_resolution_clock::now();
				//imgArray = imageComputeCudaWrap::computeCurveImg(clsCuda::bModeConfig);
				imgArray = testObj->computeBModeImgC();
				//t2 = high_resolution_clock::now();
				//duration<double, std::milli> ms_double = t2 - t1;
				//mFile << "computeImgHW : " << std::to_string(ms_double.count()) << std::endl;

				if (imgArray == nullptr) {
					// error
					cv::imwrite("sample_output/errorMat1.png", testMat0);
				}
				cv::Mat outMat = converttoMat(imgArray, rows, cols);
				cv::Mat polarMat = map2CurviLinear(outMat, probPrms, 450);
				polarMat = hilbertTrans4(polarMat, 1.0);
				envolepMat = logTransform(polarMat); // log compression
				//cv::imwrite("sample_output/logrMat.png", polarMat);
				//cv::imwrite("sample_output/envolepCurvMat.png", envolepMat);
			}
			catch (std::exception& e) {
				std::cerr << e.what();
			}
		}

		else if (clsCuda::probe_type == 2) {}

		else if (clsCuda::probe_type == 3) {
		
			try {
				//t1 = high_resolution_clock::now();
				//imgArray2 = imageComputeCudaWrap::computeLinearImg();
				imgArray = testObj->computeBModeImgL();
				//t2 = high_resolution_clock::now();
				//duration<double, std::milli> ms_double = t2 - t1;
				//mFile << "computeImgHW : " << std::to_string(ms_double.count()) << std::endl;

				if (imgArray == nullptr) {
					// error
					cv::imwrite("sample_output/errorMat1.png", testMat0);
				}
				//envolepMat = process2Display(imgArray, rows, cols, 20.0, 5, probPrms);
			}
			catch (std::exception& e) {
				//cv::imwrite("sample_output/errorCppMat2.png", testMat0);
				std::cerr << e.what();
			}

		}

		else if (clsCuda::probe_type == 4) {
				std::string status = imageComputeCudaWrap::cuMemInit();
				mFile << "clsCuda::probe_type : " << clsCuda::probe_type << std::endl;
				mFile << "status : " << status << std::endl;
				imgArray = imageComputeCudaWrap::computeImg();
				envolepMat = process2Display(imgArray, rows, cols, 20.0, 5, probPrms);
			}

		//cli::array<double, 2>^ gcNewArray = ConvertMatto2DArray(envolepMat, 1024- croppedBot, 254); // Hardcoded the size of matrix
		cli::array<double, 2>^ gcNewArray = ConvertMatto2DArray(envolepMat, envolepMat.rows, envolepMat.cols); // Hardcoded the size of matrix
		//cli::array<double, 2>^ gcNewArray = ConvertMatto2DArray(1024, 254); // Hardcoded the size of matrix
		mFile.close();
		return gcNewArray;
	}

}
