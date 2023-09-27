#pragma once
#include<opencv2/opencv.hpp>
#include<opencv2/imgproc.hpp>
//#include "UTCudaLib.h"

using namespace System;
using namespace System::Collections::Generic;
namespace UTImgProcess {
	public ref class clsImageProcess
	{
		// TODO: Add your methods for this class here.
	public:
		cli::array<double, 2>^ inputClrFlowData_;
		clsImageProcess();
		cli::array<double, 2>^ ApplyTGC(cli::array<double, 2>^ inputData, cli::array<double>^ tgcParam);
		cli::array<double, 2>^ ApplyGain(cli::array<double, 2>^ inputData, double gain);
		cli::array<double, 2>^ ApplyDynamicFilter(cli::array<double, 2>^ inputData, double dynamicParam);
		cli::array<double, 2>^ ApplyDepth(cli::array<double, 2>^ inputData, double debth);
		cli::array<double, 2>^ ApplyEnhanceFilter(cli::array<double, 2>^ inputData, int enhanceId);// int s_option, int niter, float kappa, float lambda, float clahe_clip);
		cli::array<double, 2>^ ApplyDeSpeckleFilter(cli::array<double, 2>^ inputData);
		cli::array<double, 2>^ LoadCarotidData(cli::array<double, 2>^ inputData);
		cli::array<double, 2>^ ApplyGammaFilter(cli::array<double, 2>^ inputData, cli::array<double>^ yPts);
		cli::array<double, 2>^ ReadDatabyProbe();
		//cli::array<double, 2>^ ApplyColorFlow(cli::array<double, 2>^ inputData);
		List<cli::array<double>^>^ ApplyColorFlow(cli::array<double, 2>^ inputData, cli::array<double>^ colorFlowCursorPoints);//0->startX,1->startY,2->endX,2->endY
	protected:
		cv::Mat Convert2DArraytoMat(cli::array<double, 2>^ data);
		cli::array<double, 2>^ ConvertMatto2DArray(cv::Mat img);
		cli::array<double, 2>^ ConvertMatto2DClrFlowArray(cv::Mat img);

	};
}
