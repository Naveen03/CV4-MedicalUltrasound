#pragma once
#include "pch.h"
// include OpenCV Header
#include <opencv2/opencv.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/cudaimgproc.hpp>


cv::Mat converttoMat(float* imgArray, int rows, int cols) {

    // Converting the B-mode image into OpenCV Mat
    cv::Mat outMat = cv::Mat::zeros(rows, cols, CV_64FC1);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            outMat.at<double>(i, j) = imgArray[i * cols + j];
        }

    }

    return outMat;
}

cv::Mat converttoMat(float** imgArray, int rows, int cols) {

    // Converting the B-mode image into OpenCV Mat
    cv::Mat outMat = cv::Mat::zeros(rows, cols, CV_64FC1);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            outMat.at<double>(i, j) = imgArray[i][j];
        }

    }

    return outMat;
}

cv::Mat logTransform(const cv::Mat& inMat) {
    // Performing the log transformation to the image to make it enhanced
    // Formula applied is: "output=c*log(1+input)"
    // inMat range should be 0 -->maxvalue
    double min, max;
    cv::Mat outMat(inMat.size(), CV_64FC1);
    cv::minMaxIdx(inMat, &min, &max);
    double c = 255.0 / (log10(1 + max));
    std::cout << " const value from log transform : " << c << std::endl;

    for (int i = 0; i < inMat.rows; i++) {
        for (int j = 0; j < inMat.cols; j++) {
            outMat.at<double>(i, j) = 20.0 * std::log10(1 + inMat.at<double>(i, j));
        }
    }

    return outMat;
}

cv::Mat dynamicRangeAdjust(const cv::Mat& inMat, float delta) {
    // requiress to be positive values
    //env_dB = env_dB - max(max(env_dB));
    double minP, maxP;
    cv::Mat outMat;;

    cv::minMaxIdx(inMat, &minP, &maxP);
    // adjusting if not positive matrix
    
    if (minP < 0) {
        outMat = inMat + abs(minP);
    }
    else{
        outMat = inMat;
    }
    cv::minMaxIdx(outMat, &minP, &maxP);
    outMat = outMat - maxP;
    outMat = 127*((outMat + delta) / delta);

    return outMat;
}

cv::Mat displayRangeAdjust(const cv::Mat& inMat, bool negtoZero = true) {
    double minP, maxP;
    cv::Mat outMat;;

    cv::minMaxIdx(inMat, &minP, &maxP);
    if (negtoZero) {
        inMat.convertTo(outMat, CV_8UC1, 255.0 / maxP ); // convert to 0->255 range avoiding neg pixels
    }
    else {
        outMat = inMat + abs(minP); // to avoid any negative pixels
        outMat.convertTo(outMat, CV_8UC1, 255.0 / (maxP + abs(minP))); // converst to 0->255 range including neg pixels
    }

    return outMat;
}

// // display code in matlab THis is for referance
//rf = load('C:\Users\CSR_L\source\repos\beamforming_parallel3_PA\b_mode.csv');
//sa = rf(1:end, : );
//no_lines = size(sa, 2);
//figure(1),
//env = abs(hilbert(sa));
//env_dB = 20 * log10(env);
//env_dB = env_dB - max(max(env_dB));
//env_gray = 127 * (env_dB + 50) / 50;
//x = ((1:no_lines) - ceil(no_lines / 2)) * 0.075 / 1000;
//depth = ((1:size(env_gray, 1))) * (1540 / 32e6 / 2);
//image(x * 1000, depth * 1000, env_gray);
//xlabel('Lateral Distance [mm]', 'FontSize', 12, 'FontWeight', 'bold')
//ylabel('Depth [mm]', 'FontSize', 12, 'FontWeight', 'bold')
//set(findall(gcf, 'type', 'text'), 'FontSize', 12, 'fontWeight', 'bold')
//set(findall(gcf, 'type', 'axes'), 'fontsize', 12, 'fontWeight', 'bold')
//axis('image')
//colormap(gray(128))

cv::Mat hilbertTrans4(const cv::Mat& rf, float factor) {
    cv::Mat rfComplex(rf.rows, rf.cols, CV_64FC2);
    std::vector<cv::Mat> combiner;
    combiner.push_back(rf);
    combiner.push_back(cv::Mat::zeros(rf.size(), CV_64FC1));
    cv::merge(combiner, rfComplex);
    std::vector<cv::Mat> splitter;
    splitter.push_back(cv::Mat(rfComplex.rows, rfComplex.cols, CV_64FC1));
    splitter.push_back(cv::Mat(rfComplex.rows, rfComplex.cols, CV_64FC1));
    cv::Mat rfSpectrum = cv::Mat(rfComplex.rows, rfComplex.cols, CV_64FC2);

    // forward DFT
    cv::dft(rfComplex, rfSpectrum);
    cv::multiply(rfSpectrum, factor, rfSpectrum, 1.0, CV_64FC2);

    // inverse DFT
    cv::dft(rfSpectrum, rfComplex, cv::DFT_INVERSE | cv::DFT_SCALE);
    cv::split(rfComplex, splitter);

    // get imaginary part
    cv::Mat imag = splitter[1];
    cv::Mat envelope;

    cv::multiply(imag, cv::Scalar(1.0 / rf.cols), imag, 1.0, CV_64FC1);
    cv::magnitude(rf, imag, envelope);
    return envelope;
}

