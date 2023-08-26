#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <math.h>
#include <time.h>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream>
#pragma warning (disable : 4996) // to disable fopen error

using namespace cv;
using namespace std;

# define pi 3.1416

/*A function to disply the inforations of the opencv mat*/
void getMatDetails(const cv::Mat& displayMat, const std::string& outstring) {
    double min, max;
    std::string t_array[7] = { "CV_8U", "CV_8S", "CV_16U", "CV_16S", "CV_32S", "CV_32F", "CV_64F" };

    cv::minMaxIdx(displayMat, &min, &max);
    std::cout << "---------" << outstring << "---------------" << std::endl;
    std::cout << "matrix r*c: " << displayMat.rows << " , " << displayMat.cols << std::endl;
    std::cout << "matrix type : " << displayMat.type() << " : " << std::endl;
    std::cout << "min --> max : " << min << " , " << max << std::endl;
    std::cout << "--------------------------------------------" << std::endl;
}

float*** get3darray(int xdim, int ydim, int zdim) {

    float*** array3D = (float***)malloc(xdim * sizeof(float*));
    for (int i = 0; i < xdim; i++) {
        array3D[i] = (float**)malloc(ydim * sizeof(array3D[i]));
        for (int j = 0; j < ydim; j++) {
            array3D[i][j] = (float*)malloc(zdim * sizeof(array3D[i][j]));
        }
    }

    return array3D;
}

float** get2darray(int xdim, int ydim) {
    float** array2D = (float**)malloc(xdim * sizeof(float*));
    for (int i = 0; i < xdim; i++) {
        array2D[i] = (float*)malloc(ydim * sizeof(array2D[i]));
        memset(array2D[i], 0, ydim * sizeof(array2D[i]));
    }

    return array2D;
}

void delete2darray(float** array, int xdim, int ydim) {
    for (int i = 0; i < xdim; i++) {
        delete[] array[i];
    }
    delete[] array;

}

void delete3darray(float*** array, int xdim, int ydim, int zdim) {
    for (int i = 0; i < ydim; i++) {
        for (int j = 0; j < zdim; j++) {
            delete[] array[i][j];
        }
    }
    for (int i = 0; i < ydim; i++) {
        delete[] array[i];
    }
    delete[] array;
}

float* read_header(const char* path) {
    //----------READING HEADER FILE TO GET THE REQUIRED INFORMATION-----

    float* hinfo = new float[9];
    float v;
    int i = 0;
    std::ifstream headerFile;
    headerFile.open(path, std::ios::in);
    std::string line;
    if (headerFile.is_open()) {
        while (std::getline(headerFile, line)) {
            float v = std::stof(line);
            // std::cout << v << ", ";
            hinfo[i] = v;
            i++;
        }
    }
    return hinfo;
}

cv::Mat logTransform(const cv::Mat& inMat) {
    // Performing the log transformation to the image to make it enhanced
    // Formula applied is: "output=c*log(1+input)"
    // inMat range should be 0 -->maxvalue
    double min, max;
    cv::Mat outMat(inMat.size(), CV_32FC1);
    cv::minMaxIdx(inMat, &min, &max);
    float c = 255.0 / (log10(1 + max));
    std::cout << " const value from hilbert transform: " << c << std::endl;

    for (int i = 0; i < inMat.rows; i++) {
        for (int j = 0; j < inMat.cols; j++) {
            outMat.at<float>(i, j) = 250 * std::log10(1 + inMat.at<float>(i, j));
        }
    }

    return outMat;
}

/*A function to streatch histogram*/
void streatchHist(const cv::Mat& displayMat) {
    /* stretching the histogram */
    double min1, max1, min2, max2;
    cv::minMaxIdx(displayMat, &min1, &max1);
    float ratio = 255.0 / (max1 - min1);
    cv::multiply(displayMat, ratio, displayMat);
    cv::minMaxIdx(displayMat, &min2, &max2);
    //getMatDetails(displayMat, "h");
}

cv::Mat interPolatedImage(const cv::Mat& displayMat) {

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
    cv::Mat resizedMatrix(512, 512, CV_8UC1);
    cv::minMaxIdx(displayMat, &min, &max);
    /* Conveting image to positive range */
    std::cout << "Range of image after hilbert : " << min << " , " << max << std::endl;
    cv::add(displayMat, abs(min), displayMat);
    std::cout << "adding" << std::endl;
    cv::minMaxIdx(displayMat, &min, &max);
    std::cout << "Range of image after adding min : " << min << " , " << max << std::endl;

    /* Log Transform*/
    cv::Mat logMat = logTransform(displayMat);
    cv::minMaxIdx(logMat, &min, &max);
    std::cout << "Range of image after log transform : " << min << " , " << max << std::endl;

    /* stretching the histogram */
    streatchHist(logMat);
    cv::minMaxIdx(logMat, &min, &max);
    std::cout << "Range of image after streatching : " << min << " , " << max << std::endl;
    // cv::resize(logMat, logMat, resizedMatrix.size(), 0, 0, cv::INTER_LINEAR);
    logMat.convertTo(logMat, CV_8UC1);
    return logMat;
}

//float** read_data(const char* path, float* hinfo){
//    /// -------------------READING THE DATA FILE------------------------------------------
//    int rows=(int)hinfo[0];
//    int cols=hinfo[18]*hinfo[2];
//    int width=hinfo[2];
//    int extra=hinfo[18];
//    char* record_d;
//    char* line_d;
//    char buffer_d[5000];
//    // cv::Mat DataMat(rows, cols, CV_64FC1);
//    printf("rows %d \t", rows);
//    printf("cols %d \t", cols);
//    printf("width %d \t", width);
//    printf("extra %d \t", extra);
//
//    int i=0;
//    int j=0;
//    // double data[rows][cols];
//    float** data = get2darray(rows, cols);
//
//    FILE *fptr_d = fopen(path,"r");
//    if (fptr_d==NULL)
//    {
//        printf("File opening failed \n");
//        return NULL;
//    }
//    while ((line_d=fgets(buffer_d,sizeof(buffer_d),fptr_d))!=NULL)
//    {
//        j=0;
//        record_d=strtok(line_d,",");
//        while (record_d !=NULL)
//        {
//            //printf("record : %s",record);
//            data[i][j++]=atof(record_d);
//            // DataMat.at<double>(i,j) = atof(record_d);
//            record_d=strtok(NULL,",");
//        }
//        ++i;
//    }
//    // printf("%d, %d", i, j);
//    fclose(fptr_d);
//    printf("Data read complete..\n");
//    // cv::Mat DataMat_disp = interPolatedImage(DataMat);
//    // cv::imwrite("C:\\Users\\Arun\\projects\\USI_PROCESSING_DEV\\colour_flow\\data\\initial_image.bmp", DataMat_disp);
//
//    return data;
//}

std::vector<vector<double>> read_data(const char* path, float* hinfo) {
    /// -------------------READING THE DATA FILE------------------------------------------
    int rows = (int)hinfo[0];
    int cols = hinfo[18] * hinfo[2];
    //int rows = 10;
    //int cols = 5;

    std::string line, word2;
    //float** data = get2darray(rows, cols); 
    std::vector<vector<double>> data(rows, vector<double>(vector<double>(cols)));
    std::ifstream Rfdatastm;
    std::cout << "rows : " << rows << "cols : " << cols << std::endl;

    Rfdatastm.open(path, std::ios::in);
    if (Rfdatastm.is_open()) {
        int i = 0, j = 0;
        float v;
        while (getline(Rfdatastm, line)) {
            std::stringstream word(line);
            j = 0;
            while (getline(word, word2, ',')) {
                v = stod(word2);
                // std::cout << word2 << "," << v << std::endl;
                data[i][j] = v;
                j++;
            }
            i++;
        }
    }
    Rfdatastm.close();
    //std::cout << "----------------" << std::endl;
    //for (int i = 0; i < rows; i++) {
    //    for (int j = 0; j < cols; j++) {
    //        std::cout << data[i][j] << ", ";
    //    }
    //    std::cout << std::endl;
    //}

    return data;
}

/*A function to convert any cv::Mat to 0 tp 255 range and in
CV_8UC1 format so that it can be displayed*/
cv::Mat convertDisplayMat(const cv::Mat& displayMat) {
    double min, max;
    cv::Mat displayMat1;
    cv::minMaxIdx(displayMat, &min, &max);
    cv::Mat displayOutmat;
    // cv::Mat displayOutmatHistEq(displayMat.rows, displayMat.cols, CV_64FC1);

    /*Conveting image to positive range*/
    cv::add(displayMat, abs(min), displayMat);

    std::cout << "after adding" << std::endl;

    // getMatDetails(displayMat, "before stretching");
    /* stretching the histogram */
    streatchHist(displayMat);
    displayMat.convertTo(displayMat1, CV_8UC3);

    /*Equalizing histogram*/
    cv::equalizeHist(displayMat1, displayMat1);
    // cout << "after converting" << endl;
    // getMatDetails(displayOutmatHistEq, "h");
    // imshow("displayMat1", displayMat1);
    return displayMat1;
}

cv::Mat hilbertTrans4(const cv::Mat& rf, float factor) {
    cv::Mat rfComplex(rf.rows, rf.cols, CV_32FC2);
    std::vector<cv::Mat> combiner;
    combiner.push_back(rf);
    combiner.push_back(cv::Mat::zeros(rf.size(), CV_32FC1));
    cv::merge(combiner, rfComplex);
    std::vector<cv::Mat> splitter;
    splitter.push_back(cv::Mat(rfComplex.rows, rfComplex.cols, CV_32FC1));
    splitter.push_back(cv::Mat(rfComplex.rows, rfComplex.cols, CV_32FC1));
    cv::Mat rfSpectrum = cv::Mat(rfComplex.rows, rfComplex.cols, CV_32FC2);

    // forward DFT
    cv::dft(rfComplex, rfSpectrum);
    cv::multiply(rfSpectrum, factor, rfSpectrum, 1.0, CV_32FC2);

    // inverse DFT
    cv::dft(rfSpectrum, rfComplex, DFT_INVERSE | DFT_SCALE);
    cv::split(rfComplex, splitter);

    // get imaginary part
    cv::Mat imag = splitter[1];
    cv::Mat envelope;

    cv::multiply(imag, cv::Scalar(1.0 / rf.cols), imag, 1.0, CV_32FC1);
    cv::magnitude(rf, imag, envelope);
    return envelope;
}

cv::Mat GetMat(std::vector<vector<double>> inData, int rows, int cols) {
    cv::Mat DataMat(rows, cols, CV_32FC1);
    for (int r = 0; r < rows; r++)
    {
        for (int c = 0; c < cols; c++)
        {
            // printf("%d", r);
            DataMat.at<float>(r, c) = inData[r][c];
        }
    }
    return DataMat;
}

cv::Mat GenBmode(const cv::Mat& inRfMat) {
    // input will be the raw acquired value in OpenCV Mat form    
    // performing hilber transform
    getMatDetails(inRfMat, "inRfMat");
    Mat env_dB = hilbertTrans4(inRfMat, 1.0);
    // getMatDetails(env_dB, "env_dB");
    cv::Mat log_compressed_data = logTransform(env_dB);

    return log_compressed_data;
}

cv::Mat MakeMask(const cv::Mat& inColimg) {
    Mat alpha;
    cv::cvtColor(inColimg, alpha, COLOR_RGB2GRAY);
    cv::threshold(alpha, alpha, 20, 255, THRESH_BINARY);
    getMatDetails(alpha, "alpha channel");

    return alpha;
}

cv::Mat Blend(const cv::Mat& bground, const cv::Mat& fground, const cv::Mat& alpha) {
    /*input 8uc3 images*/
    // convert to 0-1, 32FC3
    Mat bground_f, fground_f, alpha_f;
    bground.convertTo(bground_f, CV_32FC3, 1.0 / 255);
    fground.convertTo(fground_f, CV_32FC3, 1.0 / 255);
    cv::cvtColor(alpha, alpha_f, COLOR_GRAY2BGR);
    alpha_f.convertTo(alpha_f, CV_32FC3, 1.0 / 255);

    //getMatDetails(bground_f, "bground_f");
    //getMatDetails(fground_f, "fground_f");
    //getMatDetails(alpha_f, "alpha_f");

    // Storage for output image
    Mat ouImage = Mat::zeros(fground_f.size(), fground_f.type());

    // Multiply the foreground with the alpha matte
    multiply(alpha_f, fground_f, fground_f);

    // Multiply the background with ( 1 - alpha )
    multiply(Scalar::all(1.0) - alpha_f, bground_f, bground_f);

    // Add the masked foreground and background.
    add(fground_f, bground_f, ouImage);

    ouImage.convertTo(ouImage, CV_8UC3, 255);

    // Display image
    // imshow("alpha blended image", ouImage);

    return ouImage;
}

int main()
{

    /// -------------------READING HEADER FILE TO GET THE REQUIRED INFORMATION--------------------------
    // const char* header_path = "./carotidheader_old.txt";
    bool imageCropping = false;
    const char* header_path = "./carotidheader_new.txt";
    float* hinfo = read_header(header_path);
    std::map <std::string, double> probHeader;

    //int rows=(int)hinfo[0];
    //int cols=hinfo[18]*hinfo[2];
    //int width=hinfo[2];
    //int extra=hinfo[18];

    probHeader.insert({ "rows", (int)hinfo[0] });
    probHeader.insert({ "cols", hinfo[18] * hinfo[2] }); //width*extra
    probHeader.insert({ "width", hinfo[2] });
    probHeader.insert({ "extra", hinfo[18] });
    probHeader.insert({ "Linelength", (double)hinfo[0] });
    probHeader.insert({ "c", 1540.0 });
    probHeader.insert({ "ensemble", 8.0 });
    probHeader.insert({ "nlines", probHeader["width"] });
    probHeader.insert({ "W", 20.0 });
    probHeader.insert({ "deltaW", 10.0 });
    probHeader.insert({ "nW", floor((probHeader["Linelength"] - probHeader["W"]) / probHeader["deltaW"]) });
    probHeader.insert({ "Fe", hinfo[14] });
    probHeader.insert({ "Fs", hinfo[15] });
    probHeader.insert({ "Ts", 1 / probHeader["Fs"] });
    probHeader.insert({ "D", (double)(probHeader["W"] * probHeader["c"]) / (2.0 * probHeader["Fs"]) });
    int i, j;
    std::vector<vector<double>> RFdata;
    cv::Mat inRfMat, BmodeMat, inRfMatCropped, BmodeMatCrop;;
    const char* data_path = "104934-66.csv";

    RFdata = read_data(data_path, hinfo);
    inRfMat = GetMat(RFdata, probHeader["rows"], probHeader["cols"]); // convert Array into Mat
    // std::cout << inRfMat.rows << inRfMat.cols << std::endl;
    BmodeMat = GenBmode(inRfMat);// Converting the raw rf image into B-Mode image
    BmodeMat = convertDisplayMat(BmodeMat);// Converting the scale
    cv::cvtColor(BmodeMat, BmodeMat, COLOR_GRAY2BGR);
    cv::imwrite("BmodeMat_fromnew.png", BmodeMat);

    ////////////DATA RESHAPING////////////

    if (imageCropping == true) {
        int pad_l, pad_r, pad_t, pad_b, cropped_rows, cropped_cols, cropped_extra, cropped_width, x1, y1, x2, y2;

        pad_l = 600;
        pad_r = 600;
        pad_t = 300;
        pad_b = 600;
        x1 = 750; y1 = 660;
        x2 = 1250; y2 = 1100;
        //BmodeMat_cropped = BmodeMat(Range(pad_t, probHeader["rows"] - pad_b), Range(pad_l, probHeader["cols"] -pad_r));
        cv::rectangle(BmodeMat, cv::Point(x1, y1), cv::Point(x2, y2), (0, 0, 255), 2); //drawing cropped box in B-mode image
        cout << "BmodeMat.type : " << BmodeMat.type() << std::endl;
        BmodeMatCrop = BmodeMat(Range(y1, y2), Range(x1, x2));
        inRfMatCropped = inRfMat(Range(y1, y2), Range(x1, x2));
        cropped_rows = inRfMatCropped.rows;
        cropped_cols = inRfMatCropped.cols;
        float cRowRatio = cropped_rows / probHeader["rows"]; // use to scale Linelength
        float cColRatio = cropped_cols / probHeader["cols"]; // use to scale width, extra

        probHeader["rows"] = cropped_rows;
        probHeader["cols"] = cropped_cols;
        probHeader["width"] = int(probHeader["width"] * cColRatio * 2);
        probHeader["extra"] = int(probHeader["extra"] * cColRatio * 2);
        probHeader["Linelength"] = cropped_rows;
        probHeader["nlines"] = probHeader["width"];
        probHeader["nW"] = floor((probHeader["Linelength"] - probHeader["W"]) / probHeader["deltaW"]);

        //probHeader.insert({ "rows", (int)hinfo[0] });
        //probHeader.insert({ "cols", hinfo[18] * hinfo[2] }); //width*extra
        //probHeader.insert({ "width", hinfo[2] });
        //probHeader.insert({ "extra", hinfo[18] });
        //probHeader.insert({ "Linelength", (double)hinfo[0] });
        //probHeader.insert({ "c", 1540.0 });
        //probHeader.insert({ "ensemble", 8.0 });
        //probHeader.insert({ "nlines", probHeader["width"] });
        //probHeader.insert({ "W", 20.0 });
        //probHeader.insert({ "deltaW", 10.0 });
        //probHeader.insert({ "nW", floor((probHeader["Linelength"] - probHeader["W"]) / probHeader["deltaW"]) });
        //probHeader.insert({ "Fe", hinfo[14] });
        //probHeader.insert({ "Fs", hinfo[15] });
        //probHeader.insert({ "Ts", 1 / probHeader["Fs"] });
        //probHeader.insert({ "D", (double)(probHeader["W"] * probHeader["c"]) / (2.0 * probHeader["Fs"]) });

        cout << "readjusted values for cropped image " << endl;
        std::cout << probHeader["rows"] << ", " << probHeader["cols"] << " , " << probHeader["width"] << " , "
            << probHeader["extra"] << ", " << probHeader["Linelength"] << " , " << probHeader["nlines"] << ", " << probHeader["nW"] << endl;

    }
    else {
        inRfMatCropped = inRfMat;
    }

    chrono::high_resolution_clock::time_point t1 = chrono::high_resolution_clock::now();
    std::vector<vector<vector<double>>> RFdata3d(probHeader["rows"], vector<vector<double>>(probHeader["extra"], vector<double>(probHeader["width"])));
    cv::Mat RfMat(probHeader["rows"], probHeader["extra"], CV_64FC1);
    int pval = 0;
    for (int nf = 0; nf < probHeader["width"]; nf++)
    {
        for (int c = 0; c < probHeader["extra"]; c++)
        {
            for (int r = 0; r < probHeader["rows"]; r++)
            {
                // printf("%d", r);
                // RFdata3d[r][c][nf]=RFdata[r][pval];
                //Fdata3d[r][c][nf] = RFdata[r][pval];
                RFdata3d[r][c][nf] = inRfMatCropped.at<float>(r, pval);
            }
            pval++;
        }
    }

    ////////////INITIALIZING THE PARAMETERS////////////
    //int Linelength = (int)hinfo[0];
    //int c = 1540;
    //int ensemble = 8;
    //int nlines = width;
    //int W = 20;
    //int deltaW = 10;
    //int nW = floor((Linelength - W) / deltaW);
    //double Fe = hinfo[14];
    //double Fs = hinfo[15];
    //double Ts = (1 / Fs);
    //double D = (double)(W*c) / (2.0 * Fs);
    //std::cout << "rows : " << rows << std::endl;
    //std::cout << "cols : " << cols << std::endl;
    //std::cout << "width : " << width << std::endl;
    //std::cout << "extra : " << extra << std::endl;
    //std::cout << "Linelength : " << Linelength << std::endl;
    //std::cout << "c : " << c << std::endl;
    //std::cout << "ensemble : " << ensemble << std::endl;
    //std::cout << "nlines : " << nlines << std::endl;
    //std::cout << "W : " << W << std::endl;
    //std::cout << "deltaW : " << deltaW << std::endl;
    //std::cout << "nW : " << nW << std::endl;
    //std::cout << "c : " << c << std::endl;
    //std::cout << "Fe : " << Fe << std::endl;
    //std::cout << "Fs : " << Fs << std::endl;
    //std::cout << "Ts : " << Ts << std::endl;
    //std::cout << "D : " << D << std::endl;

    double temp;
    double win[20] = { 0 };
    double t[30] = { 0 };
    double sinterm[20] = { 0 };
    double costerm[20] = { 0 };

    ////////////IQ DEMODULATION///////////////
    int half = probHeader["W"] / 2;
    double sumwin = 0;
    for (int n = 0; n < probHeader["W"]; n++)
    {
        if (n < half)
        {
            win[n] = 0.5 * (1 - cos(2 * pi * (n + 1.0) / (probHeader["W"] + 1.0)));
        }
        else
        {
            win[n] = win[int(probHeader["W"]) - 1 - n];
        }

        sumwin += win[n];
    }
    for (i = 0; i < probHeader["W"]; i++)
    {
        win[i] = win[i] / sumwin;
    }

    for (i = 1; i < probHeader["W"]; i++)
    {
        t[i] = t[i - 1] + probHeader["Ts"];
    }

    for (j = 0; j < probHeader["W"]; j++)
    {
        sinterm[j] = win[j] * sin(2 * pi * probHeader["Fe"] * (j + 1.0) / probHeader["Fs"]);
        costerm[j] = win[j] * cos(2 * pi * probHeader["Fe"] * (j + 1.0) / probHeader["Fs"]);
    }

    //float*** I = get3darray(probHeader["nlines"], probHeader["nW"], probHeader["ensemble"]);
    //float*** Q = get3darray(probHeader["nlines"], probHeader["nW"], probHeader["ensemble"]);
    //float*** filtI = get3darray(probHeader["nlines"], probHeader["nW"], probHeader["ensemble"]);
    //float*** filtQ = get3darray(probHeader["nlines"], probHeader["nW"], probHeader["ensemble"]);
    //double I[nlines][nW][ensemble], Q[nlines][nW][ensemble],filtI[nlines][nW][ensemble],filtQ[nlines][nW][ensemble];
    //double* currentline = new double[probHeader["Linelength"]];

    vector<vector<vector<double>>> I(probHeader["nlines"], vector<vector<double>>(probHeader["nW"], vector<double>(probHeader["ensemble"])));
    vector<vector<vector<double>>> Q(probHeader["nlines"], vector<vector<double>>(probHeader["nW"], vector<double>(probHeader["ensemble"])));
    vector<vector<vector<double>>> filtI(probHeader["nlines"], vector<vector<double>>(probHeader["nW"], vector<double>(probHeader["ensemble"])));
    vector<vector<vector<double>>> filtQ(probHeader["nlines"], vector<vector<double>>(probHeader["nW"], vector<double>(probHeader["ensemble"])));
    vector<double> currentline(int(probHeader["Linelength"]), 0);
    double currentwindow[20], Reterms[20], Imterms[20], Re = 0.0, Im = 0.0;

    for (int le = 0; le < probHeader["nlines"]; le++)
    {
        for (int oe = 0; oe < probHeader["ensemble"]; oe++)
        {
            for (int cno = 0; cno < probHeader["Linelength"]; cno++)
            {
                temp = RFdata3d[cno][oe][le];
                currentline[cno] = temp;
            }
            for (int innerj = 0; innerj < probHeader["nW"]; innerj++)
            {
                Re = 0.0;
                Im = 0.0;
                for (int inval = 0; inval < probHeader["W"]; inval++)
                {
                    currentwindow[inval] = currentline[(innerj * int(probHeader["deltaW"])) + inval];
                    Reterms[inval] = sinterm[inval] * currentwindow[inval];
                    Imterms[inval] = costerm[inval] * currentwindow[inval];
                    Re = Re + Reterms[inval];
                    Im = Im + Imterms[inval];
                }
                I[le][innerj][oe] = Re;
                Q[le][innerj][oe] = Im;

            }
        }
    }

    /////// Zero phase high pass filtering//////
    int filtord = 2, nfact = 6;
    int totallength = (nfact * 2) + probHeader["ensemble"];
    // double tempi[ensemble],tempq[ensemble];    
    //double tempi2[totallength],tempq2[totallength];
    //double* tempi = new double[probHeader["ensemble"]];
    //double* tempq = new double[probHeader["ensemble"]];
    //double* tempi2 = new double[totallength];
    //double* tempq2 = new double[totallength];
    //double* ix = new double[totallength];
    //double* iq = new double[totallength];
    //double* tempirev = new double[totallength];
    //double* tempqrev = new double[totallength];
    //double* idata = new double[probHeader["ensemble"]];
    //double* qdata = new double[probHeader["ensemble"]];

    vector<double> tempi(probHeader["ensemble"], 0);
    vector<double> tempq(probHeader["ensemble"], 0);
    vector<double> tempi2(totallength, 0);
    vector<double> tempq2(totallength, 0);
    vector<double> ix(totallength, 0);
    vector<double> iq(totallength, 0);
    vector<double> tempirev(totallength, 0);
    vector<double> tempqrev(totallength, 0);
    vector<double> idata(probHeader["ensemble"], 0);
    vector<double> qdata(probHeader["ensemble"], 0);

    for (int lp = 0; lp < probHeader["nlines"]; lp++)
    {
        for (int np = 0; np < probHeader["nW"]; np++)
        {
            for (int ne = 0; ne < probHeader["ensemble"]; ne++)
            {
                tempi[ne] = I[lp][np][ne];
                tempq[ne] = Q[lp][np][ne];
            }
            for (int tl = 0; tl < totallength; tl++)
            {
                if (tl < nfact)
                {
                    tempi2[tl] = 2 * tempi[0] - tempi[nfact - tl];
                    tempq2[tl] = 2 * tempq[0] - tempq[nfact - tl];
                }
                else if ((tl >= nfact) & (tl < (totallength - nfact)))
                {
                    tempi2[tl] = tempi[tl - nfact];
                    tempq2[tl] = tempq[tl - nfact];
                }
                else if (tl >= (totallength - nfact))
                {
                    tempi2[tl] = (2 * tempi[int(probHeader["ensemble"]) - 1]) - tempi[totallength - tl];
                    tempq2[tl] = (2 * tempq[int(probHeader["ensemble"]) - 1]) - tempq[totallength - tl];
                }
            }

            /// -------------------------------FILTERING---------------------------
            /// ---------------------- Forward filtering ---------------------------
            double b[] = { 0.87517141414347399130946314471657, -1.7503428282869479826189262894331, 0.87517141414347399130946314471657 }, a[] = { 1.0, -1.7346994738051471074413711903617, 0.76598618276874885779648138850462 };
            double zi[] = { -0.87517141414347399130946314471657, 0.87517141414347365824255575716961 };
            double zii[3], ziq[3];
            zii[0] = zi[0] * tempi2[0]; zii[1] = zi[1] * tempi2[0]; zii[2] = 0;
            ziq[0] = zi[0] * tempq2[0]; ziq[1] = zi[1] * tempq2[0]; ziq[2] = 0;
            // double ix[totallength],iq[totallength], idata[ensemble],qdata[ensemble], tempirev[totallength], tempqrev[totallength];
            // double idata[ensemble], qdata[ensemble];
            // may have to re initialize

            for (int m = 0; m < totallength; m++)
            {
                ix[m] = b[0] * tempi2[m] + zii[0];
                iq[m] = b[0] * tempq2[m] + ziq[0];
                for (int minner = 1; minner <= filtord; minner++)
                {
                    zii[minner - 1] = b[minner] * tempi2[m] + zii[minner] - a[minner] * ix[m];
                    ziq[minner - 1] = b[minner] * tempq2[m] + ziq[minner] - a[minner] * iq[m];
                }
            }
            for (int ind = 0; ind < totallength; ind++)
            {
                tempirev[ind] = ix[totallength - ind - 1];
                tempqrev[ind] = iq[totallength - ind - 1];
            }

            /// ---------------------Reverse filtering ------------------------------
            zii[0] = zi[0] * tempirev[0]; zii[1] = zi[1] * tempirev[0]; zii[2] = 0;
            ziq[0] = zi[0] * tempqrev[0]; ziq[1] = zi[1] * tempqrev[0]; ziq[2] = 0;
            for (int m = 0; m < totallength; m++)
            {
                ix[m] = b[0] * tempirev[m] + zii[0];
                iq[m] = b[0] * tempqrev[m] + ziq[0];
                for (int minner = 1; minner <= filtord; minner++)
                {
                    zii[minner - 1] = b[minner] * tempirev[m] + zii[minner] - a[minner] * ix[m];
                    ziq[minner - 1] = b[minner] * tempqrev[m] + ziq[minner] - a[minner] * iq[m];
                }
            }
            for (int ind = 0; ind < totallength; ind++)
            {
                tempirev[ind] = ix[totallength - ind - 1];
                tempqrev[ind] = iq[totallength - ind - 1];
            }

            for (int ind = 0; ind < probHeader["ensemble"]; ind++)
            {
                idata[ind] = tempirev[totallength - nfact - ind - 1];
                qdata[ind] = tempqrev[totallength - nfact - ind - 1];
            }

            for (int ne = 0; ne < probHeader["ensemble"]; ne++)
            {
                filtI[lp][np][ne] = idata[ne];
                filtQ[lp][np][ne] = qdata[ne];
            }

        }

    }

    //delete[] tempi;
    //delete[] tempq;
    //delete[] tempi2;
    //delete[] tempq2;
    //delete[] ix;
    //delete[] iq;
    //delete[] tempirev;
    //delete[] tempqrev;
    //delete[] idata;
    //delete[] qdata;

    std::cout << "filtering Forward completed" << std::endl;

    /////////////////////AUTOCORRELATION/////////////////////
    double Icurrent, Inext, Qcurrent, Qnext, nRx = 0, nRy = 0, nRo = 0, nRt = 0;
    double filtIcurrent, filtInext, filtQcurrent, filtQnext, fnRx = 0, fnRy = 0, fnRo = 0, fnRt = 0;
    // printf("nW %d , nlines %d ", nW, nlines);
    // float vel_est[nW][nlines], sig_est[nW][nlines], pow_est[nW][nlines];
    // float filt_vel_est[nW][nlines], filt_sig_est[nW][nlines], filt_pow_est[nW][nlines];
    //float** vel_est = get2darray(probHeader["nW"], probHeader["nlines"]);
    //float** sig_est = get2darray(probHeader["nW"], probHeader["nlines"]);
    //float** pow_est = get2darray(probHeader["nW"], probHeader["nlines"]);
    //float** filt_vel_est = get2darray(probHeader["nW"], probHeader["nlines"]);
    //float** filt_sig_est = get2darray(probHeader["nW"], probHeader["nlines"]);
    //float** filt_pow_est = get2darray(probHeader["nW"], probHeader["nlines"]);

    vector<vector<double>> vel_est(probHeader["nW"], vector<double>(probHeader["nlines"]));
    vector<vector<double>> sig_est(probHeader["nW"], vector<double>(probHeader["nlines"]));
    vector<vector<double>> pow_est(probHeader["nW"], vector<double>(probHeader["nlines"]));
    vector<vector<double>> filt_vel_est(probHeader["nW"], vector<double>(probHeader["nlines"]));
    vector<vector<double>> filt_sig_est(probHeader["nW"], vector<double>(probHeader["nlines"]));
    vector<vector<double>> filt_pow_est(probHeader["nW"], vector<double>(probHeader["nlines"]));

    for (int le = 0; le < probHeader["nlines"]; le++)
    {
        for (j = 0; j < probHeader["nW"]; j++)
        {
            for (i = 0; i < probHeader["ensemble"] - 1; i++)
            {
                //////////////IQ data//////////////
                Icurrent = I[le][j][i];
                Inext = I[le][j][i + 1];
                Qcurrent = Q[le][j][i];
                Qnext = Q[le][j][i + 1];

                nRy += (Icurrent * Qnext) - (Qcurrent * Inext);
                nRx += (Icurrent * Inext) + (Qcurrent * Qnext);
                nRo += (Icurrent * Icurrent) + (Qcurrent * Qcurrent);

                //////////////Filtered IQ data//////////////
                filtIcurrent = filtI[le][j][i];
                filtInext = filtI[le][j][i + 1];
                filtQcurrent = filtQ[le][j][i];
                filtQnext = filtQ[le][j][i + 1];

                fnRy += (filtIcurrent * filtQnext) - (filtQcurrent * filtInext);
                fnRx += (filtIcurrent * filtInext) + (filtQcurrent * filtQnext);
                fnRo += (filtIcurrent * filtIcurrent) + (filtQcurrent * filtQcurrent);
            }
            /////////////// IQ data ///////
            nRo += (Inext * Inext) * (Qnext * Qnext);
            // vel_est[j][le]= atan2(nRy,nRx);
            nRt = sqrt((nRx * nRx) + (nRy * nRy));
            sig_est[j][le] = 1 - (nRt / nRo);
            pow_est[j][le] = 20 * log10(1 + (nRo / probHeader["ensemble"]));
            nRy = 0; nRx = 0; nRo = 0;
            //////////////filtered data///////
            fnRo += (filtInext * filtInext) * (filtQnext * filtQnext);
            filt_vel_est[j][le] = atan2(fnRy, fnRx);
            fnRt = sqrt((fnRx * fnRx) + (fnRy * fnRy));
            filt_sig_est[j][le] = 1 - (fnRt / fnRo);
            filt_pow_est[j][le] = 20 * log10(1 + (fnRo / probHeader["ensemble"]));

            fnRy = 0; fnRx = 0; fnRo = 0;
        }

    }
    // printf("auto correlation completed");

    /////////////////////Post processing////////////////////////////
    int minpower = 10, maxpower = 150;
    for (i = 0; i < probHeader["nW"]; i++)
    {
        for (j = 0; j < probHeader["nlines"]; j++)
        {
            if ((filt_pow_est[i][j] < minpower) || (pow_est[i][j]) > maxpower)
            {
                filt_vel_est[i][j] = 0;
                filt_pow_est[i][j] = 0;
                filt_sig_est[i][j] = 0;
            }
        }
    }
    std::cout << "Post processing completed" << endl;


    //zero padding
    int nW = probHeader["nW"];
    int nlines = probHeader["nlines"];
    //float** vel_int = get2darray((nW+2), (nlines+2));
    //float** sig_int = get2darray((nW+2), (nlines+2));
    //float** pow_int = get2darray((nW+2), (nlines+2));
    //float** vel_final = get2darray(nW, nlines);
    //float** vel_final = get2darray(nW, nlines);
    //float** pow_final = get2darray(nW, nlines);
    // double vel_int[nW+2][nlines+2],sig_int[nW+2][nlines+2],pow_int[nW+2][nlines+2],vel_final[nW][nlines],sig_final[nW][nlines],pow_final[nW][nlines];
    // memset(vel_int,0,sizeof vel_int);
    // memset(sig_int,0,sizeof sig_int);
    // memset(pow_int,0,sizeof pow_int);

    vector<vector<double>> vel_int((nW + 2), vector<double>((nlines + 2)));
    vector<vector<double>> sig_int((nW + 2), vector<double>((nlines + 2)));
    vector<vector<double>> pow_int((nW + 2), vector<double>((nlines + 2)));
    vector<vector<double>> vel_final((nW + 2), vector<double>((nlines + 2)));
    vector<vector<double>> pow_final((nW + 2), vector<double>((nlines + 2)));

    int p = 0;
    double vals[9], vals_pow[9], temp_a;

    for (i = 0; i < nW; i++)
    {
        for (j = 0; j < nlines; j++)
        {
            vel_int[i + 1][j + 1] = filt_vel_est[i][j];
            pow_int[i + 1][j + 1] = filt_pow_est[i][j];
        }
    }
    // printf("zero padding completed ... ");


    for (i = 0; i < nW; i++)
    {
        int x = i + 1;
        for (j = 0; j < nlines; j++)
        {
            int y = j + 1;
            p = 0;
            for (int k1 = -1; k1 <= 1; k1++)
            {
                for (int k2 = -1; k2 <= 1; k2++)
                {   // printf("%d, %d", x+k1, y+k2);
                    vals[p] = vel_int[x + k1][y + k2];
                    vals_pow[p] = pow_int[x + k1][y + k2];
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
            vel_final[i][j] = vals[4];
            pow_final[i][j] = vals_pow[4];

        }
    }

    // ------> converting velocity data to Mat Format <----- //
    // std::cout << nW << int(nlines) << std::endl;
    Mat velFinalMat1 = Mat::zeros(nW, nlines, CV_8UC1);
    Mat velFinalMat2 = Mat::zeros(BmodeMat.size(), CV_8UC1); // to store full resoluton
    int x1, y1;
    x1 = 750; y1 = 660;

    for (int i = 0; i < nW; i++) {
        for (int j = 0; j < nlines; j++) {
            velFinalMat1.at<uchar>(i, j) = int(pow_final[i][j]);
        }
    }
    cv::imwrite("velFinalMat1.png", velFinalMat1);

    cv::Mat colorImgPad = cv::Mat::zeros(BmodeMat.size(), CV_8UC1);
    if (imageCropping == true) {
        int x1, y1;
        x1 = 750; y1 = 660;
        cv::resize(velFinalMat1, velFinalMat1, BmodeMatCrop.size(), INTER_LINEAR);

        for (int i = 0; i < BmodeMatCrop.rows; i++) {
            for (int j = 0; j < BmodeMatCrop.cols; j++) {
                colorImgPad.at<uchar>(y1 + i, x1 + j) = velFinalMat1.at<uchar>(i, j);
            }
        }
        cv::imwrite("./colorImgPad.png", colorImgPad);
    }
    else {

        cv::resize(velFinalMat1, velFinalMat1, BmodeMat.size(), INTER_LINEAR);
        for (int i = 0; i < BmodeMat.rows; i++) {
            for (int j = 0; j < BmodeMat.cols; j++) {
                colorImgPad.at<uchar>(i, j) = velFinalMat1.at<uchar>(i, j);
            }
        }
        cv::imwrite("./colorImgPad.png", colorImgPad);
    }

    // ----> Expanding the range of velocity image <----//
    double min_val, max_val;
    cv::Mat velFinalFmat;
    cv::Mat colorImgPad2;
    cv::minMaxIdx(colorImgPad, &min_val, &max_val);
    colorImgPad.convertTo(colorImgPad2, CV_8UC3, 255.0 / (max_val - min_val)); //-255.0*min_val/(max_val-min_val)
    cv::cvtColor(colorImgPad2, colorImgPad2, COLOR_GRAY2RGB);
    cv::applyColorMap(colorImgPad2, colorImgPad2, COLORMAP_HOT); // Applying colormap to 8U
    cv::imwrite("./vel_final2.png", colorImgPad2);

    //----> Blend image <----//

    cv::Mat alphaMask = MakeMask(colorImgPad2);
    cv::imwrite("./alphaMask.png", alphaMask);
    cv::Mat blendImg = Blend(BmodeMat, colorImgPad2, alphaMask);
    cv::imwrite("./blended_image.png", blendImg);

    chrono::high_resolution_clock::time_point t2 = chrono::high_resolution_clock::now();
    chrono::duration<double> time_span = chrono::duration_cast<chrono::duration<double>>(t2 - t1);
    std::cout << "velocity estimation took " << time_span.count() << " seconds.";
    std::cout << std::endl;

    return 0;

}
