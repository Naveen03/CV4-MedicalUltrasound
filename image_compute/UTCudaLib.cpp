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

//void Display::init() {
//	//mFile.open("sample_output/callfun.txt");
//	//int rows = 1024;
//	//int cols = 254;
//	//imgArray = nullptr;
//	//call_count = 0;
//	//errorMat = cv::Mat::zeros(rows, cols, CV_8UC1);
//
//}
//
//void Display::initCurviLinear()
//{
//
//	//----------------------
//	//probPrms["samples"] = (int)clsCuda::bModeConfig[8];
//	//probPrms["c0"] = (float)clsCuda::bModeConfig[11];
//	//probPrms["s_freq"] = (float)clsCuda::bModeConfig[10]; // sampling_frequency
//	//probPrms["pitch"] = (float)clsCuda::bModeConfig[20];
//	//probPrms["rc"] = (float)clsCuda::bModeConfig[25]; // radius_of_curvature
//	//probPrms["scan_angle"] = (float)clsCuda::bModeConfig[26]; //in radians
//	//probPrms["Nx"] = (int)clsCuda::bModeConfig[14];
//	//probPrms["Nz"] = (int)clsCuda::bModeConfig[15];
//	//-----------------------
//
//	rows = 0;
//	cols = 0;
//	samples = probPrms["samples"];
//	c0 = probPrms["c"];
//	s_freq = probPrms["sampling_frequency"];       // sampling_frequency
//	pitch = probPrms["pitch"];
//	rc = probPrms["rc"];       // radius_of_curvature
//	s_angle = probPrms["scan_angle"];   // scan_angle in radians
//	Nx = probPrms["Nx"];
//	Nz = probPrms["Nz"];
//
//	float sample_spacing = c0 / s_freq / 2;
//	float dz = sample_spacing * samples / Nz;
//	roc_rows = floor(rc / dz);
//	//std::cout << "roc_rows : " << roc_rows << std::endl;
//	int total_rows = roc_rows + Nz; // in opencv implementation total rows should be = residual_rows + image rows
//	float curve_width = 2 * (Nz * std::sin(s_angle / 2));
//
//	// declaring the canvas matrix in which the polar image will get plotted
//	int dxRows = total_rows;
//	int dxCols = curve_width;
//
//	// std::cout << "curve_width : " << curve_width << std::endl;
//	theAxis = cv::Mat(1, int(Nx), CV_32FC1); // angle distribution across columsn, a.k.a across scanning elements i.o.w  firing angle of each transducer element
//	rAxis = cv::Mat(total_rows, 1, CV_32FC1); // depth or radius of coverage for each transducer element
//
//	// Creating the angle axis whcih rnges from -0.5 to +0.5 radians (-28 to +28 degree)
//	// This will be repeated along the y (row) direction (same across all row)
//	for (int i = 0; i < theAxis.cols; i++) {
//		theAxis.at<float>(0, i) = -s_angle / 2 + (i * (s_angle) / Nx);
//	}
//
//	// Creating the magnitude axis whcih ranges from 0 to i*total_rows (0 to total_rows)
//	// This will be repeated along the x (column) direction (same across all cols)
//	for (int i = 0; i < total_rows; i++) {
//		rAxis.at<float>(i, 0) = Nz * i;
//	}
//
//	cv::repeat(theAxis, total_rows, 1, theMat); // Repeating along the y (row)
//	cv::repeat(rAxis, 1, Nx, rMat); // Repeating along the x (cols)
//
//	// Calculating corresponding 'x', 'y' location from 'r' and 'angle'
//	cv::polarToCart(rMat, theMat, xM, yM);
//	double minX, maxX, minY, maxY;
//	cv::minMaxIdx(xM, &minX, &maxX); // to get the max 'x' value here it is 0.133884
//	cv::minMaxIdx(yM, &minY, &maxY); // to get the max 'y' value here it is 0.111515
//
//			//// Normalize values to fit rows and columns
//	xM1 = xM * ((dxRows - 1) / maxX); // normalizing x values to fit the canvas column size - only required to test the plotting
//	yM1 = yM * ((dxCols - 2) / (2.0 * std::max(std::abs(minY), maxY))); // normalizing the y values to fit the -row/2 to row/2 - only required to test the plotting
//	yM1 = (dxCols / 2) + yM1; // converting the range from -row/2 to row/2 to 0 to row/2
//	xM1.convertTo(xM1, CV_16UC1); // only required to test the plotting
//	yM1.convertTo(yM1, CV_16UC1); // only required to test the plotting
//	double minX1, maxX1, minY1, maxY1;
//	cv::minMaxIdx(xM1, &minX1, &maxX1);
//	cv::minMaxIdx(yM1, &minY1, &maxY1);
//	//std::cout << "maxX1 : " << maxX1 << " maxY1 " << maxY1 << std::endl;
//
//	assert(dxRows >= maxX1);
//	assert(dxCols >= maxY1); // else plotting will not fit
//
//	// matrices to hold the location of pixel (i.e, x & y) in the cartisian cordinate (i.e. in this image "inImg")
//	// it will just range from x: 0--> inImg.cols, y: 0-->inImg.rows
//	ang_view_map_x = cv::Mat::zeros(dxRows, dxCols, CV_32FC1);
//	ang_view_map_y = cv::Mat::zeros(dxRows, dxCols, CV_32FC1);
//	ang_view_map_ix = cv::Mat::zeros(dxRows, dxCols, CV_16SC2);
//	//ang_view_map_iy = cv::Mat::zeros(dxRows, dxCols, CV_32FC1);
//
//	//cv::Mat canvasMat1 = cv::Mat::zeros(dxRows + 20, dxCols + 20, CV_8UC1); // added some padding to make sure about boundary conditions
//	int i, j; // location of pixel in cartesian cordinates plotted in cartesian cordinates from input image "inImg"
//	int x, y; // location of pixel in polar cordinates represented in cartesian cordinates 
//	for (i = 0; i < xM1.rows; i++) {
//		//int i = 100; 
//		for (j = 0; j < xM1.cols; j++) {
//			x = xM1.at<uint16_t>(i, j);
//			y = yM1.at<uint16_t>(i, j);
//			//canvasMat1.at<uchar>(x, y) = 255; // test the plotiing
//			ang_view_map_x.at<float>(x, y) = j;
//			ang_view_map_y.at<float>(x, y) = i;
//		}
//	}
//
//	// this is to fill in some void points in the mapping matrix
//	cv::Mat strel = cv::getStructuringElement(cv::MORPH_ELLIPSE, cv::Size(7, 7));
//	cv::dilate(ang_view_map_x, ang_view_map_x, strel);
//	cv::dilate(ang_view_map_y, ang_view_map_y, strel);
//	//cv::convertMaps(ang_view_map_x, ang_view_map_y, ang_view_map_ix, ang_view_map_iy, CV_16SC2, false);
//
//}
//
//cv::Mat Display::map2CurviLinear(cv::Mat inImg, int bottom_crop) {
//
//	// image in polar cordinate but currenly represented in cartesian cordinate  
//	//cv::Mat inImg = cv::imread("C:/Users/navee/Documents/projects/USI_processing/BmodeMat_fromnew.png", 0);
//	rows = inImg.rows;
//	cols = inImg.cols;
//
//	//cv::imshow("canvasMat1", canvasMat1);
//	cv::Mat croppedImg;// , paddedInImg, remappedImg;
//	int top_crop = std::max(0, roc_rows - 100);
//	cv::copyMakeBorder(inImg, croppedImg, roc_rows, 0, 0, 0, 0); // padding to adjust for 0--> residual area
//	croppedImg = croppedImg(cv::Range(0, croppedImg.rows - bottom_crop), cv::Range(0, inImg.cols));
//
//	//std::cout << "croppedImg.size : " << croppedImg.size() << std::endl;
//	//std::cout << "ang_view_map_x.size : " << ang_view_map_x.size() << std::endl;
//	//std::cout << "ang_view_map_y.size : " << ang_view_map_y.size() << std::endl;
//
//	cv::remap(croppedImg, croppedImg, ang_view_map_ix, ang_view_map_iy, 0);
//	croppedImg = croppedImg(cv::Range(top_crop, croppedImg.rows - bottom_crop), cv::Range(0, croppedImg.cols));
//
//	return croppedImg;
//}
//
//void Display::readCurviLinearProbParams(const char* path, double* bmodeParms) {
//	/// -------------------READING THE DATA FILE------------------------------------------
//
//	/*
//	*Order of parameters
//	MAX_ITER
//	N_RX
//	MAX_LINE
//	PI
//	MASK_WIDTH
//	TILE_SIZE
//	num_threads
//	rx_f_number
//	samples
//	N_elements
//	sampling_frequency
//	c
//	N_active
//	channels
//	Nx
//	Nz
//	frames
//	num_frames
//	skip_frames
//	dBvalue
//	*/
//
//	std::string line, key_value, key;
//	double v;
//	// std::map <std::string, double> bmodeParms;
//
//	std::ifstream paramFile;
//	paramFile.open(path, std::ios::in);
//
//	int i, j = 0;
//	if (paramFile.is_open()) {
//		while (getline(paramFile, line)) {
//			std::stringstream word(line);
//			i = 0; // to get the key
//			while (getline(word, key_value, ',')) {
//				//std::cout << key_value << std::endl;
//				if (i == 0) {
//					key = key_value;
//					// std::cout << "key : " << " : " << key;
//				}
//
//				else {
//					probPrms[key] = stod(key_value);
//					bmodeParms[j] = stod(key_value);
//					j++;
//					// std::cout << "key_value : " << key_value << std::endl;
//				}
//				i++;
//			}
//		}
//	}
//	paramFile.close();
//}

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
			i = 0; // to get the key
			while (getline(word, key_value, ',')) {
				//std::cout << key_value << std::endl;
				if (i == 0) {
					key = key_value;
					// std::cout << "key : " << " : " << key;
				}
				else {
					bmodeParms[j] = stod(key_value);
					j++;
					// std::cout << "key_value : " << key_value << std::endl;
				}
				i++;
			}
		}
	}
	paramFile.close();


	//int i, j = 0;
	//if (paramFile.is_open()) 
	//{
	//	while (getline(paramFile, line)) 
	//	{
	//		bmodeParms[j] = stod(line);
	//		j++; // to get the count
	//	}
	//}
	//paramFile.close();
}

void readCurviLinearProbParams(const char* path, double* bmodeParms) {
	/// -------------------READING THE DATA FILE------------------------------------------

	/*
	*Order of parameters
	MAX_ITER
	N_RX
	MAX_LINE
	PI
	MASK_WIDTH
	TILE_SIZE
	num_threads
	rx_f_number
	samples
	N_elements
	sampling_frequency
	c
	N_active
	channels
	Nx
	Nz
	frames
	num_frames
	skip_frames
	dBvalue
	*/

	std::string line, key_value, key;
	double v;
	// std::map <std::string, double> bmodeParms;

	std::ifstream paramFile;
	paramFile.open(path, std::ios::in);

	int i, j = 0;
	if (paramFile.is_open()) {
		while (getline(paramFile, line)) {
			std::stringstream word(line);
			i = 0; // to get the key
			while (getline(word, key_value, ',')) {
				//std::cout << key_value << std::endl;
				if (i == 0) {
					key = key_value;
					// std::cout << "key : " << " : " << key;
				}

				else {
					bmodeParms[j] = stod(key_value);
					j++;
					// std::cout << "key_value : " << key_value << std::endl;
				}
				i++;
			}
		}
	}
	paramFile.close();



}

cli::array<double, 2>^ convertMatto2DArray(double** imgArray, int rows, int cols)
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

cli::array<double, 2>^ convertMatto2DArray(float* img, int rows, int cols)
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

cli::array<double, 2>^ convertMatto2DArray(int rows, int cols)
{
	cli::array<double, 2>^ data = gcnew cli::array<double, 2>(cols, rows);

	for (int rIdx = 0; rIdx < rows; rIdx++) {
		for (int cIdx = 0; cIdx < cols; cIdx++) {
			data[cIdx, rIdx] = 0.00;
		}
	}

	return data;
}

cli::array<double, 2>^ convertMatto2DArray(cv::Mat inMat, int rows, int cols)
{
	cli::array<double, 2>^ data = gcnew cli::array<double, 2>(cols, rows);

	for (int rIdx = 0; rIdx < rows; rIdx++) {
		for (int cIdx = 0; cIdx < cols; cIdx++) {
			data[cIdx, rIdx] = inMat.at<double>(rIdx, cIdx);
		}
	}

	return data;
}

void convertMatto2DArray(cv::Mat* inMat, cli::array<double, 2>^ out_data)
{
	//cli::array<double, 2>^ data = gcnew cli::array<double, 2>(cols, rows);

	for (int rIdx = 0; rIdx < inMat->rows; rIdx++) {
		for (int cIdx = 0; cIdx < inMat->cols; cIdx++) {
			out_data[cIdx, rIdx] = inMat->at<double>(rIdx, cIdx);
		}
	}

	//return data;
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
	int top_crop = std::max(0, roc_rows - 100);
	cv::copyMakeBorder(inImg, croppedImg, roc_rows, 0, 0, 0, 0); // padding to adjust for 0--> residual area
	croppedImg = croppedImg(cv::Range(0, croppedImg.rows - bottom_crop), cv::Range(0, inImg.cols));
	cv::remap(croppedImg, croppedImg, ang_view_map_x, ang_view_map_y, 0);
	croppedImg = croppedImg(cv::Range(top_crop, croppedImg.rows - bottom_crop), cv::Range(0, croppedImg.cols));

	return croppedImg;
}

cv::Mat map2Display(cv::Mat inImg, float log_const, float gain) {

	/*
	* Function to adjust the imge properties to
	* diplay properly
	*/

	cv::Mat threshMat;
	double min, max;
	cv::minMaxIdx(inImg, &min, &max);

	cv::Mat adjMat = inImg - (max / 2);
	cv::minMaxIdx(adjMat, &min, &max);
	//std::cout << "Range of values adjMat : " << min << " , " << max << std::endl;

	//float db = 5;
	cv::Mat dbMat = (adjMat + gain) / gain;
	cv::threshold(adjMat, threshMat, 0, 255, cv::THRESH_TOZERO);

	return threshMat;
}

cv::Mat process2Display(double** imgArray, int rows, int cols, float log_const, float gain,
	std::map <std::string, float> probPrms, int bottom_crop = 0, bool polar_form = false) {
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

		const char* linear_param_path = "b_mode_linear_params3.csv";
		const char* curvilinear_param_path = "b_mode_curvilinear_params3.csv";
		const char* linear_setting_file = "out25.txt";
		const char* curvi_setting_file = "out25_v2.txt";
		
		int s1, s2, s3;

		clsCuda::bModeConfig = new double[29];
		clsCuda::probe_type = probeID;
		clsCuda::rows = 1024;
		clsCuda::cols = 254;
		clsCuda::call_count = 0;

		UTCudaLib::cppLog.open("sample_output/cppLog_file.txt");
		UTCudaLib::cppLog << "probeID : " << probeID << std::endl;


		if (clsCuda::probe_type == 1)		// read from Curvilinear prob
		{

			readCurviLinearProbParams(curvilinear_param_path, clsCuda::bModeConfig);
			s1 = testObj->initHW();
			s2 = testObj->initGPUprobeC(clsCuda::bModeConfig);
			s3 = testObj->initSettingFile(curvi_setting_file);
			UTCudaLib::cppLog << "h/w init,  cuda mem ini, setting file init has completed " << std::endl;
			UTCudaLib::cppLog << " codes from Functions ,  initHW : , initGPUprobeL : , initSettingFile : " << s1 << " , " << s2 << " , " << s3 << std::endl;
			// declaring the out put valiable, rows and colums are the final ones to be displayed, if polar applied the
			// rows and cols will change
			clsCuda::dataToFrontEnd = gcnew cli::array<double, 2>(clsCuda::cols, clsCuda::rows);

		}

		else if (clsCuda::probe_type == 2)	// read from TV prob
		{
			//
			UTCudaLib::cppLog << "h/w init,  cuda mem ini, setting file init has completed " << std::endl;
		}

		else if (clsCuda::probe_type == 3)	// read from Linear prob
		{
			readLinearProbParams(linear_param_path, clsCuda::bModeConfig);
			s1 = testObj->initHW();
			s2 = testObj->initGPUprobeL(clsCuda::bModeConfig);
			s3 = testObj->initSettingFile(linear_setting_file);
			UTCudaLib::cppLog << "h/w init,  cuda mem ini, setting file init has completed " << std::endl;
			UTCudaLib::cppLog << " codes from Functions ,  initHW : , initGPUprobeL : , initSettingFile : " << s1 << " , " << s2 << " , " << s3 << std::endl;
			// declaring the out put valiable, rows and colums are the final ones to be displayed, if polar applied the
			// rows and cols will change
			clsCuda::dataToFrontEnd = gcnew cli::array<double, 2>(clsCuda::cols, clsCuda::rows);
		}

		else if (clsCuda::probe_type == 4) // read from CSV
		{
			//
			UTCudaLib::cppLog << "h/w init,  cuda mem ini, setting file init has completed " << std::endl;
		}
	}

	cli::array<double, 2>^ clsCuda::invokGPU()
	{
		UTCudaLib::cppLog << clsCuda::probe_type << std::endl;

		// switch statements 
		if (clsCuda::probe_type == 1)
		{

			cv::Mat imgMat2 = cv::Mat::zeros(clsCuda::rows, clsCuda::cols, CV_32FC1);
			cv::Mat polarMat2, envolepMat2, logMat2;
			double min;
			double max;
			probPrms["samples"] = 3328;
			probPrms["c0"] = 1540;
			probPrms["fs"] = 10e6; // sampling_frequency
			probPrms["pitch"] = 0.4654 / 1000;
			probPrms["rc"] = 59.1 / 1000; // radius_of_curvature
			probPrms["scan_angle"] = 1; //in radians
			probPrms["Nx"] = 254;
			probPrms["Nz"] = 1024;

			auto start = high_resolution_clock::now();
			clsCuda::imgArray = testObj->computeBModeImgDev();
			auto stop = high_resolution_clock::now();
			auto duration = duration_cast<std::chrono::microseconds>(stop - start);

			if (clsCuda::imgArray == nullptr) {
				// send error code
				UTCudaLib::cppLog << " nullptr received , Error in image formation " << std::endl;
				cv::imwrite("sample_output/errorMat1.png", imgMat2);
			}

			imgMat2 = converttoMat(clsCuda::imgArray, clsCuda::rows, clsCuda::cols);
			polarMat2 = map2CurviLinear(imgMat2, probPrms, 0);
			envolepMat2 = hilbertTrans4(polarMat2, 1.0);
			logMat2 = logTransform(envolepMat2); // log compression


			if (clsCuda::debug && clsCuda::call_count == 0)
			{
				UTCudaLib::cppLog << "First image computation has completed " << std::endl;
				UTCudaLib::cppLog << "imgMat.type()		: " << imgMat2.type() << std::endl;
				UTCudaLib::cppLog << "polarMat.type()	: " << polarMat2.type() << std::endl;
				UTCudaLib::cppLog << "envolepMat.type()	: " << envolepMat2.type() << std::endl;

				cv::minMaxIdx(imgMat2, &min, &max);
				UTCudaLib::cppLog << "imgMat.range		: " << min << " -- > " << max << std::endl;
				cv::minMaxIdx(polarMat2, &min, &max);
				UTCudaLib::cppLog << "polarMat.range	: " << min << " -- > " << max << std::endl;
				cv::minMaxIdx(envolepMat2, &min, &max);
				UTCudaLib::cppLog << "envolepMat.range	: " << min << " -- > " << max << std::endl;
				cv::imwrite("sample_output/curvienvolepMat.png", imgMat2);
			}

			if (clsCuda::call_count < 10)
			{
				UTCudaLib::cppLog << "duration for frame " << clsCuda::call_count << " : = " << duration.count() << std::endl;
			}

			cli::array<double, 2>^ gcNewArray = convertMatto2DArray(logMat2, logMat2.rows, logMat2.cols); // Hardcoded the size of matrix
			convertMatto2DArray(clsCuda::polarMat, clsCuda::dataToFrontEnd); // Hardcoded the size of matrix

			//return gcNewArray;
			clsCuda::dataToFrontEnd;

		}

		else if (clsCuda::probe_type == 2) {}

		else if (clsCuda::probe_type == 3) {

			double min;
			double max;
			float param;

			auto start = high_resolution_clock::now();
			clsCuda::imgArray = testObj->computeBModeImgLinDiv();

			//clsCuda::imgMat = converttoMat(clsCuda::imgArray, clsCuda::rows, clsCuda::cols);
			converttoMat(clsCuda::imgArray, clsCuda::imgMat, clsCuda::rows, clsCuda::cols);
			//postProces(clsCuda::imgMat, clsCuda::imgMat, param);

			auto stop_log = high_resolution_clock::now();

			if (clsCuda::imgArray == nullptr) {
				// send error code
				UTCudaLib::cppLog << " nullptr received , Error in image formation " << std::endl;
				cv::imwrite("sample_output/errorMat1.png", *clsCuda::imgMat);
			}

			if (clsCuda::debug && clsCuda::call_count == 0)
			{
				UTCudaLib::cppLog << "imgMat.type()		: " << clsCuda::imgMat->type() << std::endl;
				cv::minMaxIdx(*clsCuda::imgMat, &min, &max);
				UTCudaLib::cppLog << "imgMat.range		: " << min << " -- > " << max << std::endl;
				cv::imwrite("sample_output/LinenvolepMat.png", *clsCuda::imgMat);

			}

			if (clsCuda::call_count < 10)
			{
				auto duration_com = duration_cast<std::chrono::microseconds>(stop_log - start);
				UTCudaLib::cppLog << "duration computation for frame " << clsCuda::call_count << " : = " << duration_com.count()<< " micro sec" << std::endl;
				std::cout << "-------------------------------------------------------------------------------------------" << std::endl;
			}

			// cli::array<double, 2>^ gcNewArray = convertMatto2DArray(imgMat, imgMat.rows, imgMat.cols); // Hardcoded the size of matrix
			convertMatto2DArray(clsCuda::imgMat, clsCuda::dataToFrontEnd); // Hardcoded the size of matrix
			return clsCuda::dataToFrontEnd;

		}

		else if (clsCuda::probe_type == 4) {
			std::string status = imageComputeCudaWrap::cuMemInit();
			UTCudaLib::cppLog << "clsCuda::probe_type : " << clsCuda::probe_type << std::endl;
			UTCudaLib::cppLog << "status : " << status << std::endl;
			//clsCuda::imgArray = imageComputeCudaWrap::computeImg();
			//imgMat = process2Display(clsCuda::call_count++; ::imgArray, displayHandle->rows, displayHandle->cols, 20.0, 5, probPrms);
		}


		clsCuda::call_count++;
		if (clsCuda::call_count >= 10)
		{
			UTCudaLib::cppLog.close();
		}

		//return gcNewArray;
		return clsCuda::dataToFrontEnd;
	}

	void clsCuda::postProces(cv::Mat* inMat, cv::Mat* outMat, float param) 
	{
		//

	}

}
