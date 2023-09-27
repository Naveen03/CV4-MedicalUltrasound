#include "pch.h"
#include "UTImgProcess.h"
//#include "UTCudaLib.h"
#include <map>

using namespace UTImgProcess;
using namespace std;
using namespace UTCudaLib;


void streatchHist(const cv::Mat& displayMat) {
    // stretching the histogram 
    double min1, max1;
    cv::minMaxIdx(displayMat, &min1, &max1);
    float ratio = 255.0 / (max1 - min1);
    cv::multiply(displayMat, ratio, displayMat);
}

cv::Mat interPolatedImage(const cv::Mat& displayMat, bool resize, cv::Size resizeSize) {

    /*INTER_NEAREST -->1
    INTER_LINEAR -->2
    INTER_CUBIC -->3
    INTER_AREA -->4
    INTER_LANCZOS4 -->5
    INTER_LINEAR_EXACT -->6
    INTER_MAX -->7
    WARP_FILL_OUTLIERS -->8
    WARP_INVERSE_MAP -->9 */
    double min, max;

    cv::minMaxIdx(displayMat, &min, &max);
    /* Conveting image to positive range */
    cv::add(displayMat, abs(min), displayMat);
    //cout << "adding" << endl;
    /* stretching the histogram */
    streatchHist(displayMat);

    cv::Mat resizedMatrix;
    if (resize == true)
    {
        cv::resize(displayMat, resizedMatrix, resizeSize, 0, 0, cv::INTER_LINEAR);
    }
    else {
        resizedMatrix = displayMat;
    }
    resizedMatrix.convertTo(resizedMatrix, CV_8UC1);
    return resizedMatrix;
}

/* class that will hold the variables and methods
for denoising the ultrasound images
*/

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

    void applySRAD(const cv::Mat& inimg, cv::Mat& outimg, int option, double kappa, float lambda) {
        // Implement SRAD Perona Malik outimgusion

        int border = 2;
        cv::Mat deltaN, deltaS, deltaW, deltaE, inImg_double, deltaNN, deltaSS, deltaEE, deltaWW, cN, cE, cW, cS;
        double minM, maxM;

        // getMatDetails(inimg, "inimg");
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

        outimg = outimg + lambda * (cN + cS + cE + cW);
        // getMatDetails(outimg, "outimg");

        multiply(outimg, 255, outimg);
        // getMatDetails(outimg, "outimg_after");
        outimg.convertTo(outimg, CV_8UC1);
        // cv::imshow("Output before 0->1: ", outimg);

        cv::minMaxIdx(outimg, &minM, &maxM);
        cv::add(outimg, abs(minM), outimg);
        cv::normalize(outimg, outimg, 255, 0, cv::NORM_MINMAX, CV_8UC1);
        // getMatDetails(outimg, "outimg_after 0->255");

        // apply a median filter
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

clsImageProcess::clsImageProcess()
{

}

cli::array<double, 2>^ clsImageProcess::ApplyTGC(cli::array<double, 2>^ inputData, cli::array<double>^ tgcParam)
{
    // TGC filter Algorithm
    try
    {
        cv::Mat inputMat = Convert2DArraytoMat(inputData);

        // Parameters
        int t1, y, h, numBlocks = 8, sDepth, v;
        double g, minP, maxP;
        cv::Mat outMat, maskImg, roi, tgcImg;

        // adjusting input image
        cv::minMaxIdx(inputMat, &minP, &maxP);
        cv::add(inputMat, std::abs(minP), inputMat);// adjusting the range to 0-->max

        // create Mask
        maskImg = cv::Mat::zeros(inputMat.size(), CV_8UC1);
        for (int i = 0; i < numBlocks; i++) {
            if (tgcParam[i] != 0.0) {
                v = tgcParam[i];
                sDepth = (inputMat.rows / numBlocks);
                y = sDepth * i;
                cv::Mat roi(maskImg, cv::Rect(0, y, inputMat.cols, sDepth));// select a ROI
                roi = 255; //(uchar)tgcParam[i];// fill the ROI with 255to make changes in maskImg
            }
        }

        // Create TGC matrix
        tgcImg = cv::Mat::zeros(inputMat.size(), inputMat.type());
        cv::add(tgcImg, v, tgcImg, maskImg);

        // Apply changes to Output MAt
        outMat = inputMat + tgcImg;

        //cv::minMaxIdx(outMat, &minP, &maxP);
        //t1 = inputMat.type();
        ////cv::minMaxIdx(outMat, &minP, &maxP);
        //cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/UTScannerApp/150823/UTScannerApp/UTScannerApp/tgcMask.jpg", maskImg);
        //cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/UTScannerApp/150823/UTScannerApp/UTScannerApp/tgcInMat.jpg", inputMat);
        //cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/UTScannerApp/150823/UTScannerApp/UTScannerApp/tgcOutMat.jpg", outMat);
        return ConvertMatto2DArray(outMat);
    }
    catch (exception xptn)
    {

    }

}

cli::array<double, 2>^ clsImageProcess::ApplyGammaFilter(cli::array<double, 2>^ inputData, cli::array<double>^ yPts)
{
    cv::Mat inputMat = Convert2DArraytoMat(inputData);
    cv::Mat outImg = cv::Mat::zeros(inputMat.size(), CV_8UC1);
    // cv::Mat outImg = cv::Mat(inputMat.size(), CV_8UC1);
    float p;
    /*Pts
    [0] = 0.0,    ypts[0]
    [1] = 12.5, ypts[1]
    [2] = 25.0,   ypts[2]
    [3] = 37.5, ypts[3]
    [4] = 50.0,   ypts[4]
    [5] = 62.5, ypts[5],
    [6] = 75.0,   ypts[6],
    [7] = 87.5, ypts[7],
    [8] = 100.,  ypts[8],
    */

    float xStage[9] = { 0 * 2.55, 12.5 * 2.55, 25 * 2.55, 37.5 * 2.55, 50 * 2.55, 62.5 * 2.55, 75 * 2.55, 87.5 * 2.55, 100 * 2.55 };
    float yStage[9] = { 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    float* yRatios = new float[255];

    for (int i = 0; i < 9; i++) {
        p = yPts[i] * 2.55; // converting to 0-255 range
        yStage[i] = p;
    }

    // calculating the multiplication ratios
    for (int j = 0; j < 8; j++) {
        for (int i = int(xStage[j]); i <= int(xStage[j + 1]); i++) {
            p = yStage[j + 1] / xStage[j + 1];
            yRatios[i] = p;
        }
    }

    // Convert image to 0-255 range before applying the filter
    double min, max;
    cv::minMaxIdx(inputMat, &min, &max);
    cv::add(inputMat, abs(min), inputMat);
    cv::minMaxIdx(inputMat, &min, &max);
    cv::multiply(inputMat, (255.0 / max), inputMat);
    cv::minMaxIdx(inputMat, &min, &max);

    //int t = inputMat.type();
    //std::cout << min << " , " << max << std::endl;
    for (int i = 0; i < inputMat.cols; i++) {

        for (int j = 0; j < inputMat.rows; j++) {
            int pix = inputMat.at<double>(j, i);
            float r = yRatios[pix];
            outImg.at<uchar>(j, i) = int(pix * r);
        }
    }
    //cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/us_data/sample_images/outimgfromui1508.png", outImg);
    return ConvertMatto2DArray(outImg);

}

cli::array<double, 2>^ clsImageProcess::ApplyDeSpeckleFilter(cli::array<double, 2>^ inputData)
{
    cv::Mat inputMat = Convert2DArraytoMat(inputData);

    // declaration of parameters
    cv::Mat interpolateMat, enhancedImage, anisoImage, sradImage;
    int s_option = 2; // choosing despekling option 0-2
    int niter = 1; // number of iterations 1-20
    float kappa = 20.0; // kappa for despekling 1-20
    float lambda = 0.25; // lambda for despekling 0-1

    // Converting array to OpenCV Mat
    inputMat = Convert2DArraytoMat(inputData);

    // Performing interpolation to increase the size
    interpolateMat = interPolatedImage(inputMat, true, cv::Size(512, 260));

    // initializing the despekling object
    DeSpeckle deSpeckle(interpolateMat);
    if (s_option == 1) {
        //deSpeckle.applyDespeckle1(interpolateMat, anisoImage, niter, kappa, lambda);
        //cv::imwrite("C:/Users/Arun/Documents/Naveen/buslab_project/data/anisoImage.png", anisoImage);
    }
    else if (s_option == 2) {
        deSpeckle.applySRAD(interpolateMat, sradImage, niter, kappa, lambda);
        //cv::imwrite("C:/Users/Arun/Documents/Naveen/buslab_project/data/sradImage.png", sradImage);
    }

    return ConvertMatto2DArray(sradImage);
}

cli::array<double, 2>^ clsImageProcess::ApplyEnhanceFilter(cli::array<double, 2>^ inputData, int enhanceId)// int s_option, int niter, float kappa, float lambda, float clahe_clip)
{
    float clahe_clip[3] = { 0.50, 1.25, 1.75 };
    double min, max;
    cv::Mat inputMat, enhancedImage;
    int level = enhanceId;

    // Converting array to OpenCV Mat
    inputMat = Convert2DArraytoMat(inputData);

    // Convert input image to 0-255 and 8UC1 before applying the filter
    cv::minMaxIdx(inputMat, &min, &max);
    cv::add(inputMat, abs(min), inputMat); // 0-> max range
    cv::minMaxIdx(inputMat, &min, &max);
    cv::multiply(inputMat, (255.0 / max), inputMat);
    inputMat.convertTo(inputMat, CV_8UC1);

    // Apply the CLAHE algorithm to the L channel
    cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE();
    clahe->setClipLimit(clahe_clip[level]); // clip value for enhancement 0-2
    clahe->apply(inputMat, enhancedImage);

    //cv::imwrite("C:/Users/Arun/Documents/Naveen/buslab_project/data/enhancedImage.png", enhancedImage);

    return ConvertMatto2DArray(enhancedImage);
}

cv::Mat logTransform(const cv::Mat& inMat) {
    // Performing the log transformation to the image to make it enhanced
    // Formula applied is: "output=c*log(1+input)"
    // inMat range should be 0 -->maxvalue
    double min, max;
    cv::Mat outMat(inMat.size(), CV_64FC1);
    cv::minMaxIdx(inMat, &min, &max);
    double c = 255.0 / (log10(1 + max));
    std::cout << " const value from hilbert transform: " << c << std::endl;

    for (int i = 0; i < inMat.rows; i++) {
        for (int j = 0; j < inMat.cols; j++) {
            outMat.at<double>(i, j) = 250 * std::log10(1 + inMat.at<double>(i, j));
        }
    }

    return outMat;
}

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

cv::Mat GenBmode(const cv::Mat& inRfMat) {
    // input will be the raw acquired value in OpenCV Mat form    
    // performing hilber transform
    cv::Mat env_dB = hilbertTrans4(inRfMat, 1.0);
    // getMatDetails(env_dB, "env_dB");
    cv::Mat log_compressed_data = logTransform(env_dB);

    return log_compressed_data;
}

/*
List<cli::array<double>^>^ clsImageProcess::ApplyColorFlow(cli::array<double, 2>^ inputData)
{
    List<cli::array<double>^>^ blobData = gcnew List<cli::array<double>^>();
    cv::Mat inputMat, bModeimg;
    inputClrFlowData_ = inputData;
    // Converting array to OpenCV Mat
    inputMat = Convert2DArraytoMat(inputData);

   // cv::transpose(inputMat, inputMat);
    cv::Mat dummy_mat = cv::Mat::zeros(inputMat.rows, inputMat.cols, CV_8UC1);

    for (int i = 100; i < 200; i++) {
        for (int j = 100; j < 200; j++) {
            blobData->Add(gcnew cli::array<double>(3) {i,j,255});
        }
    }
    return blobData;
}
*/

/* NEW COLOR FLOW CODE*/
// cv::Mat dataReshape(cv::Mat dataMat, int rows, int extra, int width){
cv::Mat dataReshape(cv::Mat dataMat, std::map<std::string, float>& csv_header) {
    int i, j;
    /// ---------------------DATA RESHAPING --------------------
    //double RFdata[rows][extra][width];
    //int* RFdata = (int*)malloc(rows*sizeof(int));

    //float*** RFdata = get3darray(rows, extra, width);

    int rows = csv_header["cropped_rows"];
    int width = csv_header["cropped_width"];
    int extra = csv_header["cropped_extra"];

    int size[]{ rows, extra, width };
    cv::Mat RfMat(3, size, CV_32F);

    int pval = 0;
    for (int nf = 0; nf < width; nf++)
    {
        for (int c = 0; c < extra; c++)
        {
            for (int r = 0; r < rows; r++)
            {
                // printf("%d", r);
                //RFdata[r][c][nf]=data[r][pval];
                //RfMat.at<float>(r, c, nf) = data[r][pval];
                RfMat.at<float>(r, c, nf) = dataMat.at<float>(r, pval);
            }
            pval++;
        }
    }
    //std::cout << "pval" << pval << std::endl;
    return RfMat;
}

// std::vector<cv::Mat> iqDemodulation(cv::Mat RFdata){
std::vector<cv::Mat> iqDemodulation(cv::Mat RFdata, std::map<std::string, float>& csv_header) {
    // std::vector<float***> vectIQ;
    std::vector<cv::Mat> vectIQMat;
    float pi = 3.14;

    /*
    int W = 20;
    int extra= 8;
    // int width= 61;
    int width= 250;
    int ensemble= extra;
    int nlines= width;
    double c = 1540;
    double Fe= 5e+06; //hinfo[14];
    double Fs= 2e+07; //hinfo[15]
    */
    /*
    double Ts=(1/Fs);
    double D=(W*c)/(2*Fs);
    double temp;
    // int Linelength = 512; // was equal to rows
    int Linelength = 1760;
    int deltaW = 10;
    int nW = floor ((Linelength-W)/deltaW);
    */

    int W = int(csv_header["w"]);
    int extra = int(csv_header["extra"]);
    int width = int(csv_header["cropped_width"]);
    int ensemble = int(csv_header["cropped_ensemble"]);
    int nlines = int(csv_header["cropped_width"]);
    double c = double(csv_header["c"]);
    double Fe = double(csv_header["Fe"]);
    double Fs = double(csv_header["Fs"]);
    double Ts = double(1 / csv_header["Fs"]);
    double D = double(csv_header["W"] * csv_header["c"]) / (2 * csv_header["Fs"]);
    int Linelength = int(csv_header["cropped_rows"]);
    int deltaW = 10;
    int nW = floor((Linelength - W) / deltaW);
    double temp;

    //double sinterm[20]={0};
    //double costerm[20]={0};
    //double t[30]={0};
    //double win[20]={0};

    std::vector<double> sintermVec(20, 0);
    std::vector<double> costermVec(20, 0);
    std::vector<double> tVec(30, 0);
    std::vector<double> winVec(20, 0);

    /// ------------------- IQ DEMODULATION -----------------------
    int half = W / 2;
    double sumwin = 0;
    int i = 0, j = 0;
    for (int n = 0; n < W; n++)
    {
        if (n < half)
        {
            //win[n]=0.5*(1-cos(2*pi*(n+1)/(W+1)));
            winVec.at(n) = 0.5 * (1 - cos(2 * pi * (n + 1) / (W + 1)));
        }
        else
        {
            //win[n]=win[W-1-n];
            winVec.at(n) = winVec.at(W - 1 - n);
        }

        //sumwin+=win[n];
        sumwin += winVec.at(n);
    }
    for (i = 0; i < W; i++)
    {
        //win[i]=win[i]/sumwin;
        winVec.at(i) = winVec.at(i) / sumwin;
    }

    for (i = 1; i < W; i++)
    {
        //t[i]=t[i-1]+Ts;
        tVec.at(i) = tVec.at(i - 1) + Ts;
    }

    for (j = 0; j < W; j++)
    {
        //sinterm[j] = win[j]*sin(2*pi*Fe*(j+1)/Fs);
        //costerm[j] = win[j]*cos(2*pi*Fe*(j+1)/Fs);
        sintermVec.at(j) = winVec.at(j) * sin(2 * pi * Fe * (j + 1) / Fs);
        costermVec.at(j) = winVec.at(j) * cos(2 * pi * Fe * (j + 1) / Fs);
    }

    //float*** I = get3darray(nlines, nW, ensemble);
    //float*** Q = get3darray(nlines, nW, ensemble);

    int size[]{ nlines, nW, ensemble };
    cv::Mat IMat(3, size, CV_32F);
    cv::Mat QMat(3, size, CV_32F);

    //double currentwindow[20], currentline[Linelength], Reterms[20], Imterms[20];
    std::vector<double> currentwindowVec(20);
    std::vector<double> currentlineVec(Linelength);
    std::vector<double> RetermsVec(20);
    std::vector<double> ImtermsVec(20);

    double Re = 0, Im = 0;

    for (int le = 0; le < nlines; le++)
    {
        for (int oe = 0; oe < ensemble; oe++)
        {
            for (int cno = 0; cno < Linelength; cno++)
            {
                // temp=RFdata[cno][oe][le];
                temp = RFdata.at<float>(cno, oe, le);
                // currentline[cno]=temp;
                currentlineVec.at(cno) = temp;
            }
            for (int innerj = 0; innerj < nW; innerj++)
            {
                Re = 0;
                Im = 0;
                for (int inval = 0; inval < W; inval++)
                {
                    //currentwindow[inval]=currentline[(innerj*deltaW)+inval];
                    currentwindowVec.at(inval) = currentlineVec.at((innerj * deltaW) + inval);
                    //Reterms[inval]=sinterm[inval]*currentwindow[inval];
                    //Imterms[inval]=costerm[inval]*currentwindow[inval];
                    //Reterms[inval]=sintermVec.at(inval)*currentwindow[inval];
                    //Imterms[inval]=costermVec.at(inval)*currentwindow[inval];
                    RetermsVec.at(inval) = sintermVec.at(inval) * currentwindowVec.at(inval);
                    ImtermsVec.at(inval) = costermVec.at(inval) * currentwindowVec.at(inval);
                    //Re=Re+Reterms[inval];
                    //Im=Im+Imterms[inval];
                    Re = Re + RetermsVec.at(inval);
                    Im = Im + ImtermsVec.at(inval);
                }
                IMat.at<float>(le, innerj, oe) = Re;
                QMat.at<float>(le, innerj, oe) = Im;

            }
        }
    }
    vectIQMat.push_back(IMat);
    vectIQMat.push_back(QMat);

    return vectIQMat;
}

// std::vector<cv::Mat> ZeroHighPassFilter(std::vector<cv::Mat> vectIQ){
std::vector<cv::Mat> ZeroHighPassFilter(std::vector<cv::Mat> vectIQ, std::map<std::string, float>& csv_header) {
    /*
    int W = 20;
    int extra= 8;
    int width= 250; // equal to cols/extra
    int ensemble= extra;
    int nlines= width;
    double c = 1540;
    double Fe= 5e+06; //hinfo[14];
    double Fs= 2e+07; //hinfo[15]
    int Linelength = 1760; // was equal to rows
    */
    /*
    double Ts=(1/Fs);
    double D=(W*c)/(2*Fs);
    double temp;
    int deltaW = 10;
    int nW = floor ((Linelength-W)/deltaW);
    */

    int W = int(csv_header["w"]);
    int extra = int(csv_header["extra"]);
    int width = int(csv_header["cropped_width"]); // equal to cols/extra
    int ensemble = int(csv_header["cropped_ensemble"]);
    int nlines = int(csv_header["cropped_width"]);
    double c = double(csv_header["c"]);
    double Fe = double(csv_header["Fe"]);
    double Fs = double(csv_header["Fs"]);

    double Ts = double(1 / csv_header["Fs"]);
    int Linelength = int(csv_header["cropped_rows"]);
    int deltaW = 10;
    int nW = floor((Linelength - W) / deltaW);
    double temp;


    //double sinterm[20]={0};
    //double costerm[20]={0};
    //double t[30]={0};
    //double win[20]={0};

    // std::vector<float***> fillIQ;
    std::vector<cv::Mat> vecFillIQ;
    /// Zero phase high pass filtering
    int filtord = 2, nfact = 6;
    int totallength = (nfact * 2) + ensemble;

    //double tempi[ensemble],tempq[ensemble];
    //double tempi2[totallength],tempq2[totallength];

    std::vector<double> tempiVec(ensemble);
    std::vector<double> tempqVec(ensemble);
    std::vector<double> tempi2Vec(totallength);
    std::vector<double> tempq2Vec(totallength);

    //float*** I = vectIQ.at(0);
    //float*** Q = vectIQ.at(1);

    cv::Mat I = vectIQ.at(0);
    cv::Mat Q = vectIQ.at(1);

    //float*** filtI = get3darray(nlines, nW, ensemble);
    //float*** filtQ = get3darray(nlines, nW, ensemble);

    int size[]{ nlines, nW, ensemble };
    cv::Mat filtI(3, size, CV_32F);
    cv::Mat filtQ(3, size, CV_32F);

    for (int lp = 0; lp < nlines; lp++)
    {
        for (int np = 0; np < nW; np++)
        {
            for (int ne = 0; ne < ensemble; ne++)
            {
                //tempi[ne]=I[lp][np][ne];
                //tempq[ne]=Q[lp][np][ne];

                //tempi[ne] = I.at<float>(lp, np, ne);
                //tempq[ne] = Q.at<float>(lp, np, ne);
                tempiVec.at(ne) = I.at<float>(lp, np, ne);
                tempqVec.at(ne) = Q.at<float>(lp, np, ne);
            }
            for (int tl = 0; tl < totallength; tl++)
            {
                if (tl < nfact)
                {
                    //tempi2[tl]=2*tempi[0]-tempi[nfact-tl];
                    //tempq2[tl]=2*tempq[0]-tempq[nfact-tl];

                    tempi2Vec.at(tl) = 2 * tempiVec.at(0) - tempiVec.at(nfact - tl);
                    tempq2Vec.at(tl) = 2 * tempqVec.at(0) - tempqVec.at(nfact - tl);
                }
                else if ((tl >= nfact) & (tl < (totallength - nfact)))
                {
                    //tempi2[tl]=tempi[tl-nfact];
                    //tempq2[tl]=tempq[tl-nfact];
                    tempi2Vec.at(tl) = tempiVec.at(tl - nfact);
                    tempq2Vec.at(tl) = tempqVec.at(tl - nfact);
                }
                else if (tl >= (totallength - nfact))
                {
                    //tempi2[tl]=(2*tempi[ensemble-1])-tempi[totallength-tl];
                    //tempq2[tl]=(2*tempq[ensemble-1])-tempq[totallength-tl];
                    tempi2Vec.at(tl) = (2 * tempiVec.at(ensemble - 1)) - tempiVec.at(totallength - tl);
                    tempq2Vec.at(tl) = (2 * tempqVec.at(ensemble - 1)) - tempqVec.at(totallength - tl);
                }
            }


            //-------------> FILTERING <------------//
            //----------> Forward filtering <-------//
            double b[] = { 0.87517141414347399130946314471657, -1.7503428282869479826189262894331, 0.87517141414347399130946314471657 };
            double a[] = { 1.0, -1.7346994738051471074413711903617, 0.76598618276874885779648138850462 };
            double zi[] = { -0.87517141414347399130946314471657, 0.87517141414347365824255575716961 };
            double zii[3], ziq[3];
            zii[0] = zi[0] * tempi2Vec.at(0);
            zii[1] = zi[1] * tempi2Vec.at(0);
            zii[2] = 0;
            ziq[0] = zi[0] * tempq2Vec.at(0);
            ziq[1] = zi[1] * tempq2Vec.at(0);
            ziq[2] = 0;

            // double ix[totallength],iq[totallength], idata[ensemble],qdata[ensemble], tempirev[totallength], tempqrev[totallength];
            std::vector<double> ixVec(totallength);
            std::vector<double> iqVec(totallength);
            std::vector<double> idataVec(ensemble);
            std::vector<double> qdataVec(ensemble);
            std::vector<double> tempirevVec(totallength);
            std::vector<double> tempqrevVec(totallength);

            for (int m = 0; m < totallength; m++)
            {
                //ix[m] = b[0]*tempi2Vec.at(m) + zii[0];
                //iq[m] = b[0]*tempq2Vec.at(m) + ziq[0];

                ixVec.at(m) = b[0] * tempi2Vec.at(m) + zii[0];
                iqVec.at(m) = b[0] * tempq2Vec.at(m) + ziq[0];
                for (int minner = 1; minner <= filtord; minner++)
                {
                    zii[minner - 1] = b[minner] * tempi2Vec.at(m) + zii[minner] - a[minner] * ixVec.at(m);
                    ziq[minner - 1] = b[minner] * tempq2Vec.at(m) + ziq[minner] - a[minner] * iqVec.at(m);
                }
            }
            for (int ind = 0; ind < totallength; ind++)
            {
                tempirevVec.at(ind) = ixVec.at(totallength - ind - 1);
                tempqrevVec.at(ind) = iqVec.at(totallength - ind - 1);
            }

            //--------------->Reverse filtering<-------------------//
            //zii[0]=zi[0]*tempirev[0]; zii[1]=zi[1]*tempirev[0]; zii[2]=0;
            //ziq[0]=zi[0]*tempqrev[0]; ziq[1]=zi[1]*tempqrev[0]; ziq[2]=0;
            zii[0] = zi[0] * tempirevVec.at(0);
            zii[1] = zi[1] * tempirevVec.at(0);
            zii[2] = 0;
            ziq[0] = zi[0] * tempqrevVec.at(0);
            ziq[1] = zi[1] * tempqrevVec.at(0);
            ziq[2] = 0;
            for (int m = 0; m < totallength; m++)
            {
                //ix[m]=b[0]*tempirev[m]+zii[0];
                //iq[m]=b[0]*tempqrev[m]+ziq[0];

                ixVec.at(m) = b[0] * tempirevVec.at(m) + zii[0];
                iqVec.at(m) = b[0] * tempqrevVec.at(m) + ziq[0];
                for (int minner = 1; minner <= filtord; minner++)
                {
                    //zii[minner-1]=b[minner]*tempirev[m]+zii[minner]-a[minner]*ix[m];
                    //ziq[minner-1]=b[minner]*tempqrev[m]+ziq[minner]-a[minner]*iq[m];
                    zii[minner - 1] = b[minner] * tempirevVec.at(m) + zii[minner] - a[minner] * ixVec.at(m);
                    ziq[minner - 1] = b[minner] * tempqrevVec.at(m) + ziq[minner] - a[minner] * iqVec.at(m);
                }
            }
            for (int ind = 0; ind < totallength; ind++)
            {
                // tempirev[ind]=ix[totallength-ind-1];
                // tempqrev[ind]=iq[totallength-ind-1];

                tempirevVec.at(ind) = ixVec.at(totallength - ind - 1);
                tempqrevVec.at(ind) = iqVec.at(totallength - ind - 1);

            }

            for (int ind = 0; ind < ensemble; ind++)
            {
                // idata[ind]=tempirev[totallength-nfact-ind-1];
                // qdata[ind]=tempqrev[totallength-nfact-ind-1];
                idataVec.at(ind) = tempirevVec.at(totallength - nfact - ind - 1);
                qdataVec.at(ind) = tempqrevVec.at(totallength - nfact - ind - 1);
            }

            for (int ne = 0; ne < ensemble; ne++)
            {
                //filtI[lp][np][ne]=idata[ne];
                //filtQ[lp][np][ne]=qdata[ne];

                filtI.at<float>(lp, np, ne) = idataVec.at(ne);
                filtQ.at<float>(lp, np, ne) = qdataVec.at(ne);
            }
        }
    }
    vecFillIQ.push_back(filtI);
    vecFillIQ.push_back(filtQ);

    return vecFillIQ;
}

// std::vector<cv::Mat> autoCorrelation(cv::Mat I, cv::Mat Q, cv::Mat filtI, cv::Mat filtQ){
std::vector<cv::Mat> autoCorrelation(cv::Mat I, cv::Mat Q, cv::Mat filtI, cv::Mat filtQ, std::map<std::string, float>& csv_header) {

    /*
    int W = 20;
    int extra= 8;
    // int width= 61;
    int width = 250;
    int ensemble= extra;
    int nlines= width;
    // int Linelength = 512;
    int Linelength = 1760;
    int deltaW = 10;
    int nW = floor ((Linelength-W)/deltaW);
    */

    int W = int(csv_header["w"]);
    int extra = int(csv_header["extra"]);
    int width = int(csv_header["cropped_width"]); // equal to cols/extra
    int ensemble = int(csv_header["cropped_ensemble"]);
    int nlines = int(csv_header["cropped_width"]);
    int Linelength = int(csv_header["cropped_rows"]); // equal to rows
    int deltaW = 10;
    int nW = floor((Linelength - W) / deltaW);

    //std::vector<float**> estmateVector;
    std::vector<cv::Mat> estmateMatVector;

    //------------------->AUTOCORRELATION<-------------------//
    double Icurrent, Inext, Qcurrent, Qnext, nRx = 0, nRy = 0, nRo = 0, nRt = 0;
    double filtIcurrent, filtInext, filtQcurrent, filtQnext, fnRx = 0, fnRy = 0, fnRo = 0, fnRt = 0;
    printf("nW %d , nlines %d ", nW, nlines);

    //float** vel_est = get2darray(nW, nlines);
    /*
    float** sig_est = get2darray(nW, nlines);
    float** pow_est = get2darray(nW, nlines);
    float** filt_vel_est = get2darray(nW, nlines);
    float** filt_sig_est = get2darray(nW, nlines);
    float** filt_pow_est = get2darray(nW, nlines);
    */
    /*
    std::vector<std::vector<float>> sig_est1;
    std::vector<std::vector<float>> pow_est1;
    std::vector<std::vector<float>> filt_vel_est1;
    std::vector<std::vector<float>> filt_sig_est1;
    std::vector<std::vector<float>> filt_pow_est1;

    std::vector<float> colSig;
    std::vector<float> colPow;
    std::vector<float> colFilt_vel;
    std::vector<float> colFilt_sig;
    std::vector<float> colFilt_pow;
    */

    cv::Mat sig_estMat(nW, nlines, CV_32FC1);
    cv::Mat pow_estMat(nW, nlines, CV_32FC1);
    cv::Mat filt_vel_estMat(nW, nlines, CV_32FC1);
    cv::Mat filt_sig_estMat(nW, nlines, CV_32FC1);
    cv::Mat filt_pow_estMat(nW, nlines, CV_32FC1);

    for (int le = 0; le < nlines; le++)
    {
        for (int j = 0; j < nW; j++)
        {
            for (int i = 0; i < ensemble - 1; i++)
            {
                //------------->IQ data<-------//
                //Icurrent=I[le][j][i];
                //Inext=I[le][j][i+1];
                //Qcurrent=Q[le][j][i];
                //Qnext=Q[le][j][i+1];

                Icurrent = I.at<float>(le, j, i);
                Inext = I.at<float>(le, j, i + 1);
                Qcurrent = Q.at<float>(le, j, i);
                Qnext = Q.at<float>(le, j, i + 1);

                nRy += (Icurrent * Qnext) - (Qcurrent * Inext);
                nRx += (Icurrent * Inext) + (Qcurrent * Qnext);
                nRo += (Icurrent * Icurrent) + (Qcurrent * Qcurrent);

                //--------->Filtered IQ data <---//
                //filtIcurrent=filtI[le][j][i];
                //filtInext=filtI[le][j][i+1];
                //filtQcurrent=filtQ[le][j][i];
                //filtQnext=filtQ[le][j][i+1];

                filtIcurrent = filtI.at<float>(le, j, i);
                filtInext = filtI.at<float>(le, j, i + 1);
                filtQcurrent = filtQ.at<float>(le, j, i);
                filtQnext = filtQ.at<float>(le, j, i + 1);

                fnRy += (filtIcurrent * filtQnext) - (filtQcurrent * filtInext);
                fnRx += (filtIcurrent * filtInext) + (filtQcurrent * filtQnext);
                fnRo += (filtIcurrent * filtIcurrent) + (filtQcurrent * filtQcurrent);
            }
            /// IQ data
            nRo += (Inext * Inext) * (Qnext * Qnext);
            // vel_est[j][le]= atan2(nRy,nRx);
            nRt = sqrt((nRx * nRx) + (nRy * nRy));
            //sig_est[j][le]=1-(nRt/nRo);
            //colSig.push_back(1-(nRt/nRo));
            sig_estMat.at<float>(j, le) = 1 - (nRt / nRo);

            //pow_est[j][le]=20*log10(1+(nRo/ensemble));
            //colPow.push_back(20*log10(1+(nRo/ensemble)));
            pow_estMat.at<float>(j, le) = 20 * log10(1 + (nRo / ensemble));

            nRy = 0; nRx = 0; nRo = 0;
            /// filtered data
            fnRo += (filtInext * filtInext) * (filtQnext * filtQnext);
            //filt_vel_est[j][le]= atan2(fnRy,fnRx);
            //colFilt_vel.push_back(atan2(fnRy,fnRx));
            filt_vel_estMat.at<float>(j, le) = atan2(fnRy, fnRx);

            fnRt = sqrt((fnRx * fnRx) + (fnRy * fnRy));
            //filt_sig_est[j][le]=1-(fnRt/fnRo);
            //colFilt_sig.push_back(1-(fnRt/fnRo));
            filt_sig_estMat.at<float>(j, le) = (fnRt / fnRo);

            //filt_pow_est[j][le] = 20*log10(1+(fnRo/ensemble));
            //colFilt_pow.push_back(20*log10(1+(fnRo/ensemble)));
            filt_pow_estMat.at<float>(j, le) = 20 * log10(1 + (fnRo / ensemble));

            fnRy = 0; fnRx = 0; fnRo = 0;
        }

        //sig_est1.push_back(colSig);
        //pow_est1.push_back(colPow);
        //filt_vel_est1.push_back(colFilt_vel);
        //filt_sig_est1.push_back(colFilt_sig);
        //filt_pow_est1.push_back(colFilt_pow);

    }

    estmateMatVector.push_back(filt_vel_estMat);
    estmateMatVector.push_back(filt_sig_estMat);
    estmateMatVector.push_back(filt_pow_estMat);
    estmateMatVector.push_back(pow_estMat);
    /*
    estmateVector.push_back(filt_vel_est);
    estmateVector.push_back(filt_sig_est);
    estmateVector.push_back(filt_pow_est);
    estmateVector.push_back(pow_est);
    */
    return estmateMatVector;
}

//std::vector<cv::Mat> postProcessing(std::vector<cv::Mat> estimateVectorMat){
std::vector<cv::Mat> postProcessing(std::vector<cv::Mat> estimateVectorMat, std::map<std::string, float>& csv_header) {
    /*
    int W = 20;
    int extra= 8;
    // int width= 61;
    int width = 250;
    int nlines= width;
    // int Linelength = 512;
    int Linelength = 1760;
    int deltaW = 10;
    int nW = floor ((Linelength-W)/deltaW);
    */

    int W = int(csv_header["w"]);
    int extra = int(csv_header["extra"]);
    int width = int(csv_header["cropped_width"]); // equal to cols/extra
    int nlines = int(csv_header["cropped_width"]);
    int Linelength = int(csv_header["cropped_rows"]); // equal to rows
    int deltaW = 10;
    int nW = floor((Linelength - W) / deltaW);

    //float** filt_vel_est = estimateVectorMat.at(0);
    //float** filt_sig_est = estimateVectorMat.at(1);
    //float** filt_pow_est = estimateVectorMat.at(2);
    //float** pow_est = estimateVectorMat.at(3);

    cv::Mat filt_vel_est = estimateVectorMat.at(0);
    cv::Mat filt_sig_est = estimateVectorMat.at(1);
    cv::Mat filt_pow_est = estimateVectorMat.at(2);
    cv::Mat pow_est = estimateVectorMat.at(3);

    std::vector<cv::Mat> estmateVectorPostMat;

    //std::vector<float**> estmateVectorPost;
    //std::vector<float> outVector;

    //vector1.insert( vector1.end(), vector2.begin(), vector2.end() );

    /// ------------------------Post processing ----------------------------------------
    int minpower = 10, maxpower = 150;
    for (int i = 0; i < nW; i++)
    {
        for (int j = 0; j < nlines; j++)
        {
            //if ((filt_pow_est[i][j]<minpower) || (pow_est[i][j])> maxpower)
            if ((filt_pow_est.at<float>(i, j) < minpower) || (pow_est.at<float>(i, j)) > maxpower)
            {
                filt_vel_est.at<float>(i, j) = 0;
                filt_pow_est.at<float>(i, j) = 0;
                filt_sig_est.at<float>(i, j) = 0;

            }
        }
    }

    estmateVectorPostMat.push_back(filt_vel_est);
    estmateVectorPostMat.push_back(filt_sig_est);
    estmateVectorPostMat.push_back(filt_pow_est);
    estmateVectorPostMat.push_back(pow_est);

    return estmateVectorPostMat;
}

// std::vector<cv::Mat> zeroPadding(cv::Mat filt_vel_est, cv::Mat filt_pow_est){
std::vector<cv::Mat> zeroPadding(cv::Mat filt_vel_est, cv::Mat filt_pow_est, std::map<std::string, float>& csv_header) {

    /*
    int W = 20;
    // int width= 61;
    int width = 250;
    int nlines= width;
    // int Linelength = 512;
    int Linelength = 1760;
    int deltaW = 10;
    int nW = floor ((Linelength-W)/deltaW);
    //std::vector<std::vector<std::vector<>>>
    */

    int W = int(csv_header["w"]);
    int width = int(csv_header["cropped_width"]); // equal to cols/extra
    int nlines = int(csv_header["cropped_width"]);
    int Linelength = int(csv_header["cropped_rows"]); // equal to rows
    int deltaW = 10;
    int nW = floor((Linelength - W) / deltaW);


    /// zero padding
    //float** vel_int = get2darray((nW+2), (nlines+2));
    //float** pow_int = get2darray((nW+2), (nlines+2));

    cv::Mat vel_intMat((nW + 2), (nlines + 2), CV_32FC1);
    cv::Mat pow_intMat((nW + 2), (nlines + 2), CV_32FC1);

    //std::vector<float**> outVector; 
    std::vector<cv::Mat> outVectorMat;

    for (int i = 0; i < nW; i++)
    {
        for (int j = 0; j < nlines; j++)
        {
            //vel_int[i+1][j+1]=filt_vel_est[i][j];
            //pow_int[i+1][j+1]=filt_pow_est[i][j];

            vel_intMat.at<float>(i + 1, j + 1) = filt_vel_est.at<float>(i, j);
            pow_intMat.at<float>(i + 1, j + 1) = filt_pow_est.at<float>(i, j);
        }
    }
    outVectorMat.push_back(vel_intMat);
    outVectorMat.push_back(pow_intMat);

    return outVectorMat;
}

// std::vector<cv::Mat> sorting(cv::Mat vel_int, cv::Mat pow_int){
std::vector<cv::Mat> sorting(cv::Mat vel_int, cv::Mat pow_int, std::map<std::string, float>& csv_header) {
    /*
    int W = 20;
    // int width= 61;
    int width = 250;
    int nlines= width;
    // int Linelength = 512;
    int Linelength = 1760;
    int deltaW = 10;
    int nW = floor ((Linelength-W)/deltaW);
    */

    int W = int(csv_header["w"]);
    int width = int(csv_header["cropped_width"]); // equal to cols/extra
    int nlines = int(csv_header["cropped_width"]);
    int Linelength = int(csv_header["cropped_rows"]); // equal to rows
    int deltaW = 10;
    int nW = floor((Linelength - W) / deltaW);

    //float** vel_final = get2darray(nW, nlines);
    //float** sig_final = get2darray(nW, nlines);
    //float** pow_final = get2darray(nW, nlines); 

    cv::Mat vel_final(nW, nlines, CV_32FC1);
    cv::Mat sig_final(nW, nlines, CV_32FC1);
    cv::Mat pow_final(nW, nlines, CV_32FC1);

    /*
    std::vector<std::vector<float>> vel_final1;
    std::vector<std::vector<float>> sig_final1;
    std::vector<std::vector<float>> pow_final1;
    std::vector<float> valsVector;
    std::vector<float> valsPowVector;
    */
    std::vector<cv::Mat> outVector;

    int p = 0;
    double vals[9], vals_pow[9], temp_a;

    for (int i = 0; i < nW; i++)
    {
        int x = i + 1;
        for (int j = 0; j < nlines; j++)
        {
            int y = j + 1;
            p = 0;
            for (int k1 = -1; k1 <= 1; k1++)
            {
                for (int k2 = -1; k2 <= 1; k2++)
                {   // printf("%d, %d", x+k1, y+k2);
                    //vals[p]= vel_int[x+k1][y+k2];
                    vals[p] = vel_int.at<float>(x + k1, y + k2);

                    //vals_pow[p]= pow_int[x+k1][y+k2];
                    vals_pow[p] = pow_int.at<float>(x + k1, y + k2);
                    p++;
                }
            }
            /// sorting
            for (int s1 = 0; s1 < 9; s1++)
            {
                for (int s2 = 0; s2 < 9; s2++)
                {
                    if (vals[s1] > vals[s2])
                    {
                        temp_a = vals[s1];
                        vals[s1] = vals[s2];
                        vals[s2] = temp_a;
                    }
                    if (vals_pow[s1] > vals_pow[s2])
                    {
                        temp_a = vals_pow[s1];
                        vals_pow[s1] = vals_pow[s2];
                        vals_pow[s2] = temp_a;
                    }
                }
            }
            //vel_final[i][j]=vals[4];
            //pow_final[i][j]=vals_pow[4];
            vel_final.at<float>(i, j) = vals[4];
            pow_final.at<float>(i, j) = vals_pow[4];

            //valsVector.push_back(vals[4]);
            //valsPowVector.push_back(vals_pow[4]);
        }
        //vel_final1.push_back(valsVector);
        //pow_final1.push_back(valsPowVector);
        //valsVector.clear();
        //valsPowVector.clear();
    }
    outVector.push_back(vel_final);
    outVector.push_back(pow_final);

    return outVector;
}

cv::Mat MakeMask(const cv::Mat& inColimg) {
    cv::Mat alpha;
    cv::cvtColor(inColimg, alpha, cv::COLOR_RGB2GRAY);
    cv::threshold(alpha, alpha, 10, 255, cv::THRESH_BINARY + cv::THRESH_OTSU);

    return alpha;
}

cv::Mat Blend(const cv::Mat& bground, const cv::Mat& fground, const cv::Mat& alpha) {
    /*input 8uc3 images*/
    // convert to 0-1, 32FC3
    cv::Mat bground_f, fground_f, alpha_f;
    bground.convertTo(bground_f, CV_32FC3, 1.0 / 255);
    fground.convertTo(fground_f, CV_32FC3, 1.0 / 255);
    // cv::cvtColor(alpha, alpha_f, cv::COLOR_GRAY2BGR);
    alpha_f.convertTo(alpha_f, CV_32FC3, 1.0 / 255);

    //getMatDetails(bground_f, "bground_f");
    //getMatDetails(fground_f, "fground_f");
    //getMatDetails(alpha_f, "alpha_f");

    // Storage for output image
    cv::Mat ouImage = cv::Mat::zeros(fground_f.size(), fground_f.type());

    // Multiply the foreground with the alpha matte
    multiply(alpha_f, fground_f, fground_f);

    // Multiply the background with ( 1 - alpha )
    multiply(cv::Scalar::all(1.0) - alpha_f, bground_f, bground_f);

    // Add the masked foreground and background.
    add(fground_f, bground_f, ouImage);

    ouImage.convertTo(ouImage, CV_8UC3, 255);

    // Display image
    // imshow("alpha blended image", ouImage);

    return ouImage;
}

cli::array<double, 2>^ clsImageProcess::ApplyDepth(cli::array<double, 2>^ inputData, double depth) //float maxdepth)
{
    try
    {
        double maxdepth = 80.0; //maxdepth
        double min, max;
        cv::Mat inputMat = Convert2DArraytoMat(inputData);

        int c1 = inputMat.cols;
        int r1 = inputMat.rows;

        int t1 = inputMat.type();

        cv::minMaxIdx(inputMat, &min, &max);
        //std::cout << min << " , " << max << std::endl;

        //cv::add(inputMat, abs(min), inputMat);
        //inputMat.convertTo(inputMat, CV_8UC1);

        //int t2 = inputMat.type();
        //cv::minMaxIdx(inputMat, &min, &max);
        //std::cout << min << " , " << max << std::endl;

      ///  cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\debug\\20230705\\inputforcrop.jpg", inputMat);
        //Apply Debth

        cv::Mat outMat = inputMat;
        int rows = inputMat.rows; // the length of original image
        int cols = inputMat.cols;
        double pixPerDepth = rows / maxdepth;
        int rowPixForDisp = depth * pixPerDepth; // in pixels
      //  std::cout << "rowPixForDisp : " << rowPixForDisp << std::endl;

        cv::Rect myROI(0, 0, cols, rowPixForDisp);
        // cv::Mat croppedBmodeMat = inputMat(myROI);
        cv::Mat croppedBmodeMat = inputMat(cv::Range(0, rowPixForDisp), cv::Range(0, cols));
        // std::cout << croppedBmodeMat.type() << std::endl;
        // std::cout << inputMat.type() << std::endl;
        int c2 = croppedBmodeMat.cols;
        int r2 = croppedBmodeMat.rows;
        cv::minMaxIdx(croppedBmodeMat, &min, &max);
        cv::add(croppedBmodeMat, abs(min), croppedBmodeMat);
        croppedBmodeMat.convertTo(croppedBmodeMat, CV_8UC1);
        cv::minMaxIdx(croppedBmodeMat, &min, &max);
        // cv::imwrite("D:\\WorkDocument\\IITM_Bio\\UT Proj\\outputforcrop.jpg", croppedBmodeMat);
     //  std::cout << min << " , " << max << std::endl;
        return ConvertMatto2DArray(croppedBmodeMat);
    }
    catch (exception xptn)
    {

    }
    return nullptr;
}

List<cli::array<double>^>^ clsImageProcess::ApplyColorFlow(cli::array<double, 2>^ inputData, cli::array<double>^ colorFlowCursorPoints)//0->startX,1->startY,2->endX,2->endY
{
    List<cli::array<double>^>^ blobData = gcnew List<cli::array<double>^>();
    //if (this->inputClrFlowData_ != nullptr) {
    if (inputClrFlowData_ != nullptr)
    {
        //cv::Mat inputMatRaw;
        //inputMatRaw = Convert2DArraytoMat(inputData);
        //inputMatRaw.convertTo(inputMatRaw, CV_32FC1);

        int cols = inputData->GetLength(0);
        int rows = inputData->GetLength(1);

        cv::Mat inputMatRaw(rows, cols, CV_32FC1);
        for (int r = 0; r < rows; r++)
        {
            for (int c = 0; c < cols; c++)
            {
                inputMatRaw.at<float>(r, c) = inputClrFlowData_[c, r];
            }
        }

        //cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\010723\\inputMat_raw_btran.jpg", inputMatRaw);
        //int t1 = inputMatRaw.type();
        //inputMatRaw.convertTo(inputMatRaw, CV_32FC1);
        //int t2 = inputMatRaw.type();
        cv::transpose(inputMatRaw, inputMatRaw);
        // cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\010723\\inputMat_raw_atran.jpg", inputMatRaw);
         //inputMat.convertTo(inputMat8bit, CV_8UC1);
        cv::resize(inputMatRaw, inputMatRaw, cv::Size(512, 488), 0, 0, cv::INTER_LINEAR);
        //cv::resize(inputMatRaw, inputMatRaw, cv::Size(488, 512), 0, 0, cv::INTER_LINEAR);

        cv::Mat colorflowImage;


        //int rows = 512;
        //int cols = 488;
        //int width = 61;
        //int extra = 8;

        int x1 = (int)colorFlowCursorPoints[0];//0
        int y1 = (int)colorFlowCursorPoints[1];//0
        int x2 = (int)colorFlowCursorPoints[2] + 1;//img_width
        int y2 = (int)colorFlowCursorPoints[3] + 1;//img_height
        /* if image is not cropped then it should satisfy below condition
         * x=0, y=0, x2 = img.width, y2 = img.height */

        std::map <std::string, float> csv_header;
        csv_header.insert({ "rows", rows });
        csv_header.insert({ "cols", cols });
        csv_header.insert({ "width", 61 });
        csv_header.insert({ "extra", 8 });

        /*
        cv::Mat inputMat(rows, cols, CV_32FC1);
        for (int r = 0; r < rows; r++)
        {
            for (int c = 0; c < cols; c++)
            {
                inputMat.at<float>(r, c) = inputClrFlowData_[c, r];
            }
        }*/

        //  cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\010723\\inputMat.jpg", inputMatRaw);
        cv::Mat inRfMat_cropped, inputMat_rotflip;
        // Rotating the Mat to 90 degree cloclwise
        //cv::rotate(inputMat, inputMat_rotflip, cv::ROTATE_90_CLOCKWISE);
        //cv::flip(inputMat_rotflip, inputMat_rotflip, 1);


        // cv::Mat inRfMat_cropped = inputMat(cv::Range(y1, y2), cv::Range(x1, x2));

        if (x1 == 5 & y1 == 5) {
            inRfMat_cropped = inputMatRaw;
            inRfMat_cropped = inputMat_rotflip(cv::Range(y1, y2), cv::Range(x1, x2));
            // cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\inputMat_full.jpg", inRfMat_cropped);
        }
        else
        {
            //cv::Mat inputMat_draw;
            //cv::rectangle(inputMat, cv::Point(x1, y1), cv::Point(x2, y2), cv::Scalar(255, 0, 0), 2);
            // cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\inputMat_rot_draw.jpg", inputMat_rotflip);
            inRfMat_cropped = inputMatRaw(cv::Range(y1, y2), cv::Range(x1, x2));
            //inRfMat_cropped = inputMatRaw;
          //  cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\010723\\inRfMat_cropped.jpg", inRfMat_cropped);
        }

        //int inMat_rows = inputMatRaw.rows;
        //int inMat_cols = inputMatRaw.cols;
        int cropped_rows = inRfMat_cropped.rows;
        int cropped_cols = inRfMat_cropped.cols;
        int cropped_extra = 10;
        int cropped_width = int(inRfMat_cropped.cols / cropped_extra);
        //int cropped_width = int(inRfMat_cropped.rows / cropped_extra);

        csv_header.insert({ "cropped_rows", inRfMat_cropped.rows });
        csv_header.insert({ "cropped_cols", inRfMat_cropped.cols });
        csv_header.insert({ "cropped_extra", 10 });
        csv_header.insert({ "cropped_width", float(inRfMat_cropped.cols / cropped_extra) });
        //csv_header.insert({ "cropped_width", float(inRfMat_cropped.rows / cropped_extra) });
        csv_header.insert({ "cropped_nlines", cropped_width });
        csv_header.insert({ "cropped_nlines", cropped_width });
        csv_header.insert({ "w", 20 });
        csv_header.insert({ "cropped_nlines", cropped_width });
        csv_header.insert({ "cropped_ensemble", cropped_extra });
        csv_header.insert({ "cropped_nlines", cropped_width });
        csv_header.insert({ "c", 1540 });
        csv_header.insert({ "Fe", 5e+06 });
        csv_header.insert({ "Fs", 2e+07 });

        // cv::Mat RFMat = dataReshape(inputMat, rows, extra, width);
        cv::Mat RFMat = dataReshape(inRfMat_cropped, csv_header);
        // ------------> INITIALIZING THE PARAMETERS ------------
        //int Linelength = 512;
        //int W = 20;
        //int deltaW = 10;
        //int nlines = width;
        //int nW = floor((Linelength - W) / deltaW);

        // std::vector<cv::Mat> iqVec = iqDemodulation(RFMat);
        std::vector<cv::Mat> iqVec = iqDemodulation(RFMat, csv_header);
        cv::Mat I = iqVec.at(0);
        cv::Mat Q = iqVec.at(1);

        // std::vector<cv::Mat> filtIQVec = ZeroHighPassFilter(iqVec);
        std::vector<cv::Mat> filtIQVec = ZeroHighPassFilter(iqVec, csv_header);
        cv::Mat filtI = filtIQVec.at(0);
        cv::Mat filtQ = filtIQVec.at(1);
        //printf("filtering Forward completed ");

        // std::vector<cv::Mat> estimateVectorMat = autoCorrelation(I, Q, filtI, filtQ);
        std::vector<cv::Mat> estimateVectorMat = autoCorrelation(I, Q, filtI, filtQ, csv_header);
        //printf("auto correlation completed");

        // std::vector<cv::Mat> estimateVectorPostMat = postProcessing(estimateVectorMat);
        std::vector<cv::Mat> estimateVectorPostMat = postProcessing(estimateVectorMat, csv_header);
        cv::Mat filt_vel_est = estimateVectorPostMat.at(0);
        cv::Mat filt_sig_est = estimateVectorPostMat.at(1);
        cv::Mat filt_pow_est = estimateVectorPostMat.at(2);
        cv::Mat pow_est = estimateVectorPostMat.at(3);
        //printf(" Post processing completed ");

        // std::vector<cv::Mat>VelPowVector = zeroPadding(filt_vel_est, filt_pow_est);
        std::vector<cv::Mat>VelPowVector = zeroPadding(filt_vel_est, filt_pow_est, csv_header);
        cv::Mat vel_int = VelPowVector.at(0);
        cv::Mat pow_int = VelPowVector.at(1);
        //printf("zero padding completed ... ");

        // std::vector<cv::Mat>finalVector = sorting(vel_int, pow_int);
        std::vector<cv::Mat>finalVector = sorting(vel_int, pow_int, csv_header);
        cv::Mat vel_final = finalVector.at(0);
        cv::Mat pow_final = finalVector.at(1);
        //printf(" Sorting completed ... ");

        // ------> converting velocity data to Mat Format <----- //
        // cv::Mat vel_final_mat = cv::Mat::zeros(vel_final.size(), CV_8UC1);

        // cv::Mat color_img;
        // cv::resize(vel_final_mat, vel_final_mat, cv::Size(rows, cols), cv::INTER_LINEAR);
        // cv::Mat cMap = interPolatedImage(vel_final_mat, false, cv::Size(512, 260));
        cv::Mat cMap, powerMap, powerMap_pad, alphaMask_pad, pow_final_pad;
        // cv::resize(vel_final_mat, cMap, cv::Size(512, 260));
        pow_final.convertTo(pow_final, CV_8UC1);

        int pad_l = x1;
        int pad_r = inputMatRaw.cols - x2;
        int pad_t = y1;
        int pad_b = inputMatRaw.rows - y2;

        if (x1 == 5 & y1 == 5) {
            // cv::resize(powerMap, powerMap_pad, cv::Size(512, 260));
            cv::threshold(pow_final, powerMap, 30, 255, cv::THRESH_OTSU | cv::THRESH_TOZERO);
            cv::resize(powerMap, powerMap_pad, cv::Size(rows, cols));


            /*  cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\pow_final_full.jpg", pow_final);
              cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\pow_final_full_pad.jpg", powerMap_pad);*/


              // cv::resize(alphaMask, alphaMask_pad, cv::Size(488, 512));
              // cv::resize(pow_final, pow_final_pad, cv::Size(488, 512));

            cv::applyColorMap(powerMap_pad, powerMap_pad, cv::COLORMAP_HOT); // Applying colormap to 8U
          //  cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\powerMap_pad.jpg", powerMap_pad);
            // cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\pow_final.jpg", pow_final_pad);


            cv::Mat blend_img, inputMat_8bit;
            inputMatRaw.convertTo(inputMat_8bit, CV_8UC1);
            cv::cvtColor(inputMat_8bit, inputMat_8bit, cv::COLOR_GRAY2BGR);
            powerMap_pad.convertTo(powerMap_pad, CV_8UC3);

            int t1 = powerMap_pad.type();
            int t2 = inputMat_8bit.type();
            int c1 = powerMap_pad.cols;
            int c2 = inputMat_8bit.cols;
            int r1 = powerMap_pad.rows;
            int r2 = inputMat_8bit.rows;

            cv::add(inputMat_8bit, powerMap_pad, blend_img);
            //  cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\blend_img.jpg", blend_img);

        }
        else {
            cv::threshold(pow_final, powerMap, 40, 255, cv::THRESH_OTSU | cv::THRESH_TOZERO);
            //   cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\010723\\pow_final.jpg", pow_final);
              // cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\010723\\powerMap.jpg", powerMap);
            cv::resize(powerMap, powerMap, cv::Size(cropped_cols, cropped_rows));
            //    cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\010723\\powerMap_crz.jpg", powerMap);
            copyMakeBorder(powerMap, powerMap_pad, pad_t, pad_b, pad_l, pad_r, cv::BORDER_CONSTANT, cv::Scalar(0));
            //      cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\010723\\powerMap_crz2.jpg", powerMap_pad);
                  //cv::resize(powerMap_pad, powerMap_pad, cv::Size(rows, cols));
                  //cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\powerMap_crz3.jpg", powerMap_pad);

            cv::Mat powerMap_pad_map, inputMat_8bit, blend_img;
            cv::applyColorMap(powerMap_pad, powerMap_pad_map, cv::COLORMAP_HOT); // Applying colormap to 8U
            //inputMat_rotflip.convertTo(inputMat_8bit, CV_8UC1);
            //cv::cvtColor(inputMat_8bit, inputMat_8bit, cv::COLOR_GRAY2BGR);
            //powerMap_pad_map.convertTo(powerMap_pad_map, CV_8UC3);

            int t1 = inputMat_8bit.type();
            int t2 = powerMap_pad_map.type();
            int c1 = powerMap_pad_map.cols;
            int c2 = inputMat_8bit.cols;
            int r1 = powerMap_pad_map.rows;
            int r2 = inputMat_8bit.rows;

            //cv::add(inputMat_8bit, powerMap_pad_map, blend_img);
            //cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\blend_img.jpg", blend_img);

        }


        //cv::flip(powerMap_pad, powerMap_pad, 1);
        //cv::rotate(powerMap_pad, powerMap_pad, cv::ROTATE_90_COUNTERCLOCKWISE);
        //cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\result\\290623\\powerMap_flip_rot.jpg", powerMap_pad);
        int cnt = 0;
        for (int i = 0; i < powerMap_pad.cols; i++) { //
            for (int j = 0; j < powerMap_pad.rows; j++) { //
                double c_intensity = double(powerMap_pad.at<uchar>(j, i));
                if (c_intensity > 0)
                {
                    if (i == 511)
                        cnt++;
                    blobData->Add(gcnew cli::array<double>(3) { i, j, c_intensity });
                }

            }
        }
    }
    return blobData;
}

cli::array<double, 2>^ clsImageProcess::ApplyDynamicFilter(cli::array<double, 2>^ inputData, double dynamicParam)
{
    try
    {
        cv::Mat inputMat, outMat;
        double minP, maxP;
        inputMat = Convert2DArraytoMat(inputData);

        // adjusting the input image
        cv::minMaxIdx(inputMat, &minP, &maxP);
        cv::add(inputMat, std::abs(minP), outMat);// adjusting the range to 0-->max

        // Apply Gain
        outMat = outMat * dynamicParam;

        //cv::minMaxIdx(outMat, &minP, &maxP);
        //cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/UTScannerApp/150823/UTScannerApp/UTScannerApp/DynamicInMat.jpg", inputMat);
        //cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/UTScannerApp/150823/UTScannerApp/UTScannerApp/DynamicInMat.jpg", outMat);
        return ConvertMatto2DArray(outMat);
    }
    catch (exception xptn)
    {

    }
    return nullptr;
}

cli::array<double, 2>^ clsImageProcess::ApplyGain(cli::array<double, 2>^ inputData, double gain)
{
    try
    {
        cv::Mat inputMat = Convert2DArraytoMat(inputData);
        // parameters
        int t1;
        double g, minP, maxP;
        cv::Mat outMat;
        g = gain;

        // Apply Gain Process
        cv::minMaxIdx(inputMat, &minP, &maxP);
        cv::add(inputMat, std::abs(minP), outMat);// adjusting the range to 0-->max
        cv::add(outMat, g, outMat);

        // cv::minMaxIdx(outMat, &minP, &maxP);
        // cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/UTScannerApp/150823/UTScannerApp/UTScannerApp/gainInMat.jpg", inputMat);
        // cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/UTScannerApp/150823/UTScannerApp/UTScannerApp/gainOutMat.jpg", outMat);
        // outMat.convertTo(outMat, CV_8UC1);
        return ConvertMatto2DArray(outMat);
    }
    catch (exception xptn)
    {

    }
    return nullptr;
}

cli::array<double, 2>^ clsImageProcess::LoadCarotidData(cli::array<double, 2>^ inputData)
{
    cv::Mat inputMat, bModeimg;
    inputClrFlowData_ = inputData;
    // Converting array to OpenCV Mat
    inputMat = Convert2DArraytoMat(inputData);
    cv::transpose(inputMat, inputMat);
    bModeimg = GenBmode(inputMat);
    // bModeimg = interPolatedImage(bModeimg, true, cv::Size(512, 260));
    // caroidData = inputMat;
    bModeimg = interPolatedImage(bModeimg, true, cv::Size(512, 488));

    return ConvertMatto2DArray(bModeimg);
}

cv::Mat clsImageProcess::Convert2DArraytoMat(cli::array<double, 2>^ data)
{
    int cols = data->GetLength(0);
    int rows = data->GetLength(1);
    double val, val2;
    cv::Mat img = cv::Mat::zeros(rows, cols, CV_64FC1);//(rows, cols, CV_64FC1);
    //System::IO::StreamWriter^ sw = gcnew System::IO::StreamWriter("C:\\Users\\Arun\\Documents\\Naveen\\buslab_project\\data\\test.txt");

    for (int rIdx = 0; rIdx < data->GetLength(1); rIdx++)
    {
        for (int cIdx = 0; cIdx < data->GetLength(0); cIdx++)
        {
            val = data[cIdx, rIdx];
            //   sw->Write(val + ",");
            img.at<double>(rIdx, cIdx) = val;

        }
        //  sw->Write("\n");
    }
    //sw->Close();

    return img;
}

cli::array<double, 2>^ clsImageProcess::ConvertMatto2DArray(cv::Mat img) 
{
    cli::array<double, 2>^ data = gcnew cli::array<double, 2>(img.cols, img.rows);
    int cols = img.cols;
    int rows = img.rows;

    if (img.type() == 0) { // CV_8UC1 data
        for (int rIdx = 0; rIdx < rows; rIdx++) {
            for (int cIdx = 0; cIdx < cols; cIdx++) {
                data[cIdx, rIdx] = double(img.at<uchar>(rIdx, cIdx));
            }
        }
    }
    else if (img.type() == 5) { //CV_32FC1
        for (int rIdx = 0; rIdx < rows; rIdx++) {
            for (int cIdx = 0; cIdx < cols; cIdx++) {
                data[cIdx, rIdx] = double(img.at<float>(rIdx, cIdx));
            }
        }
    }
    else if (img.type() == 6) { //CV_64FC1
        for (int rIdx = 0; rIdx < rows; rIdx++) {
            for (int cIdx = 0; cIdx < cols; cIdx++) {
                data[cIdx, rIdx] = img.at<double>(rIdx, cIdx);
            }
        }
    }

    return data;
}


//data[i, j] = img.pixel<>(i, j);
// GPU Process
cli::array<double, 2>^ clsImageProcess::ReadDatabyProbe()
{
    // cli::array<double, 2>^ data = gcnew cli::array<double, 2>(20, 20);
    cli::array<double, 2>^ data2 = UTCudaLib::clsCuda::invokGPU();
    return data2;

}

cli::array<double, 2>^ clsImageProcess::ConvertMatto2DClrFlowArray(cv::Mat img)
{
    cli::array<double, 2>^ data = gcnew cli::array<double, 2>(img.cols, img.rows);
    int cols = img.cols;
    int rows = img.rows;

    for (int rIdx = 0; rIdx < rows; rIdx++) {
        for (int cIdx = 0; cIdx < cols; cIdx++) {
            if (double(img.at<uchar>(rIdx, cIdx)) != 0)
                data[cIdx, rIdx] = double(img.at<uchar>(rIdx, cIdx));
        }
    }
    //data[i, j] = img.pixel<>(i, j);
    return data;
}