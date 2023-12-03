#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <fstream>
#include <vector>
#include <stdio.h>
#include <string>
#include <iostream>
#include <exception>
#include <chrono>
#include <math.h>
#include <complex>
#include <cufft.h>      /// From "cufft.lib" 
#include <array>
#include <iomanip>
#include <opencv2/opencv.hpp>

void read_data2(const char* path, float* outArray, int rows, int cols, bool display) {
    /// -------------------READING THE DATA FILE------------------------------------------

    std::string line, word;
    std::ifstream wholeStream;
    std::stringstream lineStream;
    std::cout << "rows : " << rows << "cols : " << cols << std::endl;
    wholeStream.open(path, std::ios::in);

    if (wholeStream.is_open()) {
        int i = 0, j = 0;
        float v;
        while (getline(wholeStream, line)) {

            // convert string line to line stream
            lineStream = std::stringstream(line);
            while (getline(lineStream, word, ',')) {
                //std::cout << "word :" << word;
                outArray[i] = stof(word);
                i++;
            }
        }
    }
    wholeStream.close();


    if (display) {
        std::cout << "----------------" << std::endl;
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                std::cout << outArray[cols * i + j] << ", ";
            }
            std::cout << std::endl;
        }
    }
}

__global__ void real2complex(float* f, cufftComplex* fc) {
    //int i = threadIdx.x;
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    fc[i].x = f[i];
    fc[i].y = 0.0f;
}

__global__ void splitComplex(cufftComplex* inComplex, float* outReal, float* outImag) {

    int i = threadIdx.x;
    outReal[i] = inComplex[i].x;
    outImag[i] = inComplex[i].y;

}

__global__ void scalarMult(float* inArray, float* outArray, float c) {
    int i = threadIdx.x;

    outArray[i] = inArray[i] * c;

}

__global__ void magnitide(float* inX, float* inY, float* outW) {
    int i = threadIdx.x;

    outW[i] = std::sqrtf(std::pow(inX[i], 2) + std::pow(inY[i], 2));

}

cv::Mat converttoMat(float* imgArray, int rows, int cols) {

    // Converting the B-mode image into OpenCV Mat
    cv::Mat outMat = cv::Mat::zeros(rows, cols, CV_32FC1);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            outMat.at<float>(i, j) = imgArray[i * cols + j];
        }

    }

    return outMat;
}

class cudaDisplay
{
private:

    cufftHandle plan;
    int NBK;
    dim3 BKZ;
    float* d_xflat, * d_ifftI, * d_ifftR, * d_envelop;
    cufftComplex* d_xflatComplex;
    cufftComplex* d_fftComplex;
    cufftComplex* d_ifftComplex;
    cufftComplex* xflatComplex;
    cufftComplex* fftComplex;
    cufftComplex* ifftComplex;

public:
	void init(int rows, int cols) {

		// init the cufft handles here
        NBK = cols;
        BKZ = dim3(rows);
        cufftPlan2d(&plan, cols, rows, CUFFT_C2C);

        cudaMalloc((void**)&d_xflat, sizeof(float) * rows * cols);
        cudaMalloc((void**)&d_ifftI, sizeof(float) * rows * cols);
        cudaMalloc((void**)&d_ifftR, sizeof(float) * rows * cols);
        cudaMalloc((void**)&d_envelop, sizeof(float) * rows * cols);

        xflatComplex = new cufftComplex[rows * cols];
        fftComplex = new cufftComplex[rows * cols];
        ifftComplex = new cufftComplex[rows * cols];
        cudaMalloc((void**)&d_fftComplex, sizeof(cufftComplex) * rows * cols);
        cudaMalloc((void**)&d_ifftComplex, sizeof(cufftComplex) * rows * cols);
        cudaMalloc((void**)&d_xflatComplex, sizeof(cufftComplex) * rows * cols);

        
	}

	void fetchEnvolep(float* inImg, float* outEnvolep, int rows, int cols) {
		// calculate the hilber transform here
        cudaMemcpy(d_xflat, inImg, sizeof(float) * rows * cols, cudaMemcpyHostToDevice); //input in device
        real2complex << <NBK, BKZ >> > (d_xflat, d_xflatComplex);
        cufftExecC2C(plan, d_xflatComplex, d_fftComplex, CUFFT_FORWARD);
        cufftExecC2C(plan, d_fftComplex, d_ifftComplex, CUFFT_INVERSE);
        // convert t real and imaginary parts
        splitComplex << <NBK, BKZ >> > (d_ifftComplex, d_ifftR, d_ifftI);
        scalarMult << <NBK, BKZ >> > (d_ifftI, d_ifftI, (float)(1.0 / rows));
        magnitide << <NBK, BKZ >> > (d_xflat, d_ifftI, d_envelop);

        cudaMemcpy(outEnvolep, d_envelop, sizeof(float) * rows * cols, cudaMemcpyDeviceToHost);
	}

};

int main()
{
    int rows = 1024;
    int cols = 256;
    float* xflat = new float[rows * cols];
    float* yflat = new float[rows * cols];
    cv::Mat envolepMat;
    const char* data_path = "./inputs/b_curve_mode.csv";
    read_data2(data_path, xflat, rows, cols, false);

    cudaDisplay cudaDisplayHandle = cudaDisplay();
    cudaDisplayHandle.init(rows, cols);
    cudaDisplayHandle.fetchEnvolep(xflat, yflat, rows, cols);

    std::cout << "--------- envelop------------" << std::endl;
    std::cout << std::setprecision(2);
    for (int j = 0; j < rows*cols; j++) {
            std::cout << yflat[j] << ",";
            if ((j + 1) % rows == 0)
                std::cout << std::endl;
    }

    envolepMat = converttoMat(yflat, rows, cols);

    cv::imwrite("./sample_outputs/envolepMat_cuda.png", envolepMat);
    
    return 0;
}