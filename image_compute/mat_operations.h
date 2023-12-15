#pragma once
// include OpenCV Header
#include <opencv2/opencv.hpp>
#include <opencv2/highgui.hpp>
#include "mat_operations.h"

// Converting the B-mode image into OpenCV Mat
cv::Mat converttoMat(float* imgArray, int rows, int cols);

cv::Mat converttoMat(float** imgArray, int rows, int cols);

cv::Mat converttoMat(double** imgArray, int rows, int cols);

void converttoMat(float** imgArray, cv::Mat* outMat, int rows, int cols);

double** convertto2darray(float* imgArray, int rows, int cols);

cv::Mat logTransform(const cv::Mat& inMat);

cv::Mat dynamicRangeAdjust(const cv::Mat& inMat, float delta);

cv::Mat displayRangeAdjust(const cv::Mat& inMat, bool negtoZero = true);

cv::Mat hilbertTrans4(const cv::Mat& rf, float factor);

double** reshapeto2d(float*, int, int);

double** ConvertMatto2DArray(cv::Mat img);

//class DeSpeckle {
//public:
//    DeSpeckle(const cv::Mat& inimg) {};
//    cv::Mat gradient(const cv::Mat& inimg);
//    cv::Mat matrixOp(const cv::Mat& inDiv, const cv::Mat& inoutimg, double kappa);
//    void applyDespeckle1(const cv::Mat& inimg, cv::Mat& outimg, int option, float kappa, float lambda);
//    void applySRAD(const cv::Mat& inimg, cv::Mat& outimg, int option, double kappa, float lambda, bool applyMedian = false, bool getIn8uc1 = true);
//};

class DeSpeckle
{
public:
    cv::Mat despeckledImg;
    cv::Mat inImg;
    int rows = inImg.rows;
    int cols = inImg.cols;

    cv::Size imgSize;
    // Constructor
    DeSpeckle(const cv::Mat& inimg) {
        inImg = inimg;
        imgSize = inImg.size();
        rows = inImg.rows;
        cols = inImg.cols;
    }

    cv::Mat gradient(const cv::Mat& inimg) {
        cv::Mat Dx, Dy, GMag;
        cv::Sobel(inimg, Dx, CV_32F, 1, 0, 3);
        cv::Sobel(inimg, Dy, CV_32F, 0, 1, 3);

        // Compute gradient
        cv::magnitude(Dx, Dy, GMag);
        // getMatDetails(GMag, "MATRIX MAGNITUTE");

        return GMag;
    }

    cv::Mat matrixOp(const cv::Mat& inDiv, const cv::Mat& inoutimg, double kappa) {
        cv::Mat ML1, ML2, ML3, MR4, outMat;
        cv::multiply(inDiv, 0.5, ML1);
        subtract(ML1, 0.5, ML1);
        pow(inDiv, 2, ML2);
        cv::multiply(ML1, ML2, ML3, kappa);
        ML3 = cv::abs(ML3);

        cv::Mat minMat;
        // minMat = (max(0.01,outimg+(1/4).*deltaWW))
        double minMatrix, maxMatrix;
        cv::add(inoutimg, 0.25, MR4);
        cv::multiply(MR4, inDiv, MR4);
        cv::minMaxIdx(MR4, &minMatrix, &maxMatrix);
        double max_value = std::max(maxMatrix, 0.01);
        // std::cout << "max_value : " << max_value << endl;
        if (maxMatrix < 0.01) {
            // create am trix of 0.01
            minMat = cv::Mat(inDiv.size(), CV_32F, 0.01);
            // std::cout << minMat.size() << " : " << minMat.at<float>(50, 50) << endl;
        }
        else {
            minMat = MR4;
        }
        cv::divide(ML3, minMat, outMat);
        cv::sqrt(outMat, outMat);
        //getMatDetails(outMat, "outMat");

        return outMat;
    }

    void applyDespeckle1(const cv::Mat& inimg, cv::Mat& outimg, int option, float kappa, float lambda) {
        // Implement algorithm-1 Perona Malik outimgusion

        int border = 2;
        cv::Mat deltaN, deltaS, deltaW, deltaE, inImg_double, cN, cE, cW, cS;
        cv::normalize(inimg, inImg_double, 1.0, 0, cv::NORM_MINMAX, CV_32FC1);
        // getMatDetails(inImg_double, "inImg_double");

        inImg_double.copyTo(outimg);
        cv::Mat outimgl = cv::Mat::zeros(inImg_double.rows + border, inImg_double.cols + border, CV_32FC1);
        cv::copyMakeBorder(inImg_double, outimgl, border, border, border, border, cv::BORDER_CONSTANT);

        // cv::imshow("outimgl : ", outimgl);
        // North, South, East and West outimgerences (gradient)
        // select the N part of it w/o copying data

        cv::Mat deltaN_temp(outimgl, cv::Rect(1, 0, cols, rows));
        deltaN_temp.copyTo(deltaN);
        deltaN = deltaN - outimg;

        cv::Mat deltaS_temp(outimgl, cv::Rect(1, 2, cols, rows));
        deltaS_temp.copyTo(deltaS);
        deltaS = deltaS - outimg;

        cv::Mat deltaE_temp(outimgl, cv::Rect(2, 1, cols, rows));
        deltaE_temp.copyTo(deltaE);
        deltaE = deltaE - outimg;

        cv::Mat deltaW_temp(outimgl, cv::Rect(0, 1, cols, rows));
        deltaW_temp.copyTo(deltaW);
        deltaW = deltaW - outimg;
        // getMatDetails(deltaW, "deltaW_outimg");

        //Perona & Malik outimgusion Equation No. 1')//
        cv::pow(-(deltaN / kappa), 2.0, cN);
        cv::pow(-(deltaE / kappa), 2.0, cE);
        cv::pow(-(deltaW / kappa), 2.0, cW);
        cv::pow(-(deltaS / kappa), 2.0, cS);
        // getMatDetails(cN, "cN_pow");
        cv::exp(cN, cN);
        cv::exp(cE, cE);
        cv::exp(cW, cW);
        cv::exp(cS, cS);
        // getMatDetails(cN, "cN_exp");       

        cv::multiply(cN, deltaN, cN);
        cv::multiply(cE, deltaE, cE);
        cv::multiply(cS, deltaS, cS);
        cv::multiply(cW, deltaW, cW);
        // getMatDetails(cN, "cN_after multiplication");
        // outimg.convertTo(outimg, CV_32FC1);

        outimg = outimg + lambda * (cN + cS + cE + cW);
        // getMatDetails(outimg, "outimg");
        cv::multiply(outimg, 255, outimg);
        // getMatDetails(outimg, "outimg_after");
        outimg.convertTo(outimg, CV_8UC1);

        // releasing memmory
        deltaW.release();
        deltaE.release();
        deltaS.release();
        deltaN.release();
        cN.release();
        cW.release();
        cE.release();
        cS.release();
        deltaN_temp.release();
        inImg_double.release();
        outimgl.release();
    }

    void applySRAD(const cv::Mat& inimg, cv::Mat& outimg, int option, double kappa, float lambda, bool applyMedian = false, bool getIn8uc1 = true) {
        // Implement SRAD Perona Malik outimgusion

        int border = 2;
        cv::Mat deltaN, deltaS, deltaW, deltaE, inImg_double, deltaNN, deltaSS, deltaEE, deltaWW, cN, cE, cW, cS;
        double minM, maxM, inMax;

        // getMatDetails(inimg, "inimg");
        cv::minMaxIdx(inimg, &minM, &inMax);
        // inImg_double = inimg + abs(minM);
        // cv::minMaxIdx(inImg_double, &minM, &maxM);
        // std::cout << "Range of image in despekling fun1 : " << minM << " -> " << maxM << std::endl;
        // cv::normalize(inimg, inImg_double, 1.0, 0.0, cv::NORM_MINMAX, CV_32FC1);
        // inImg_double = inimg / inMax;
        inimg.convertTo(inImg_double, CV_32FC1, (1.0 / inMax));
        cv::minMaxIdx(inImg_double, &minM, &maxM);
        std::cout << "Range of image in despekling after normalizing : " << minM << " -> " << maxM << std::endl;

        inImg_double.copyTo(outimg);
        cv::Mat outimgl = cv::Mat::zeros(inImg_double.rows + border, inImg_double.cols + border, CV_32FC1);
        cv::copyMakeBorder(inImg_double, outimgl, border, border, border, border, cv::BORDER_CONSTANT);

        // cv::imshow("outimgl : ", outimgl);
        // North, South, East and West outimgerences (gradient)
        // select the N part of it w/o copying data

        cv::Mat deltaN_temp(outimgl, cv::Rect(1, 0, cols, rows));
        deltaN_temp.copyTo(deltaN);
        deltaN = deltaN - outimg;

        cv::Mat deltaS_temp(outimgl, cv::Rect(1, 2, cols, rows));
        deltaS_temp.copyTo(deltaS);
        deltaS = deltaS - outimg;

        cv::Mat deltaE_temp(outimgl, cv::Rect(2, 1, cols, rows));
        deltaE_temp.copyTo(deltaE);
        deltaE = deltaE - outimg;

        cv::Mat deltaW_temp(outimgl, cv::Rect(0, 1, cols, rows));
        deltaW_temp.copyTo(deltaW);
        deltaW = deltaW - outimg;
        // getMatDetails(deltaW, "deltaW_outimg");  

        // divergence  
        deltaNN = gradient(deltaN);
        deltaSS = gradient(deltaS);
        deltaEE = gradient(deltaE);
        deltaWW = gradient(deltaW);
        // getMatDetails(deltaNN, "deltaNN");

        cN = matrixOp(deltaNN, outimg, kappa);
        cS = matrixOp(deltaSS, outimg, kappa);
        cE = matrixOp(deltaEE, outimg, kappa);
        cW = matrixOp(deltaWW, outimg, kappa);

        multiply(cN, deltaN, cN);
        multiply(cE, deltaE, cE);
        multiply(cS, deltaS, cS);
        multiply(cW, deltaW, cW);
        // getMatDetails(cN, "cN_after multiplication");

        outimg = outimg + lambda * (cN + cS + cE + cW); // final process in the sepckling
        outimg = cv::max(outimg, 0); //truncating the negative values

        if (getIn8uc1) {
            multiply(outimg, 255, outimg);
            outimg.convertTo(outimg, CV_8UC1, 255 / inMax);
        }
        else {
            multiply(outimg, inMax, outimg);
        }


        // cv::add(outimg, abs(minM), outimg);
        // cv::normalize(outimg, outimg, 255, 0, cv::NORM_MINMAX, CV_8UC1);

        // apply a median filter
        if (applyMedian)
            cv::medianBlur(outimg, outimg, 3);


        // releasing memmory
        deltaW.release();
        deltaE.release();
        deltaS.release();
        deltaN.release();
        cN.release();
        cW.release();
        cE.release();
        cS.release();
        deltaW_temp.release();
        deltaS_temp.release();
        deltaE_temp.release();
        deltaN_temp.release();
        deltaNN.release();
        deltaEE.release();
        deltaSS.release();
        deltaWW.release();
        inImg_double.release();
    }
};