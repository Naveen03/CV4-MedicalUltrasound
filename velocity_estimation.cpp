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
# define pi 3.1416

/*A function to disply the inforations of the opencv mat*/
void getMatDetails(const cv::Mat& displayMat, const std::string& outstring){
    double min, max;
    std::string t_array[7] = {"CV_8U", "CV_8S", "CV_16U", "CV_16S", "CV_32S", "CV_32F", "CV_64F"};

    cv::minMaxIdx(displayMat, &min, &max);
    std::cout << "---------"<< outstring <<"---------------" << std::endl;
    std::cout << "matrix r*c: " << displayMat.rows << " , " << displayMat.cols << std::endl;
    std::cout << "matrix type : " << displayMat.type() << " : " << std::endl;
    std::cout << "min --> max : " << min << " , "<< max <<  std::endl;
    std::cout << "--------------------------------------------" << std::endl;
}

float*** get3darray(int xdim, int ydim, int zdim){

    float*** array3D = (float***)malloc(xdim*sizeof(float*));    
    for (int i=0; i<xdim; i++){
        array3D[i]= (float**)malloc(ydim*sizeof(array3D[i]));
        for (int j=0; j<ydim; j++){
            array3D[i][j]= (float*)malloc(zdim*sizeof(array3D[i][j]));
        }
    }

    return array3D;
}

float** get2darray(int xdim, int ydim){
    printf("xdim  %d ydim %d ", xdim, ydim);
    float** array2D = (float**)malloc(xdim*sizeof(float*));    
    for (int i=0; i<xdim; i++){
        array2D[i]= (float*)malloc(ydim*sizeof(array2D[i]));
        memset(array2D[i], 0, ydim*sizeof(array2D[i]));
    }

    return array2D;
}

void delete2darray(float** array, int xdim, int ydim){
    for (int i=0; i< xdim; i++){
        delete[] array[i];
    }
    delete[] array;

}

void delete3darray(float*** array, int xdim, int ydim, int zdim){
    for (int i=0; i<ydim; i++){
        for (int j=0; j<zdim; j++){
            delete[] array[i][j];
        }
    }
    for (int i=0; i<ydim; i++){
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

cv::Mat logTransform(const cv::Mat& inMat){
    // Performing the log transformation to the image to make it enhanced
    // Formula applied is: "output=c*log(1+input)"
    // inMat range should be 0 -->maxvalue
    double min, max;
    cv::Mat outMat(inMat.size(), CV_32FC1);
    cv::minMaxIdx(inMat, &min, &max);
    float c = 255.0 / (log10 (1 + max));
    std::cout << " const value from hilbert transform: "<< c << std::endl;

    for (int i=0; i < inMat.rows; i++){
        for (int j=0; j < inMat.cols; j++){
            outMat.at<float>(i, j) = 250*std::log10(1+ inMat.at<float>(i, j));
        }
    }

    return outMat;
}

/*A function to streatch histogram*/
void streatchHist(const cv::Mat& displayMat){
    /* stretching the histogram */
    double min1, max1, min2, max2;
    cv::minMaxIdx(displayMat, &min1, &max1);
    float ratio = 255.0/(max1 - min1);
    cv::multiply(displayMat, ratio, displayMat);
    cv::minMaxIdx(displayMat, &min2, &max2);
    //getMatDetails(displayMat, "h");
}

cv::Mat interPolatedImage(const cv::Mat& displayMat){

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

float** read_data(const char* path, float* hinfo){
    /// -------------------READING THE DATA FILE------------------------------------------
    int rows=(int)hinfo[0];
    int cols=hinfo[18]*hinfo[2];
    //int rows = 10;
    //int cols = 5;

    std::string line, word2;
    float** data = get2darray(rows, cols); 
    std::ifstream Rfdatastm;
    std::cout << "rows : " << rows << "cols : " << cols << std::endl;

    Rfdatastm.open(path, std::ios::in);
    if (Rfdatastm.is_open()){
        int i =0, j = 0;
        float v;
        while (getline(Rfdatastm, line)) {
            std::stringstream word(line);
            j = 0;
            while (getline(word, word2, ',')) {
                v = stof(word2);
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
cv::Mat convertDisplayMat(const cv::Mat& displayMat){
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

cv::Mat hilbertTrans4(const cv::Mat& rf, float factor){
    cv::Mat rfComplex(rf.rows, rf.cols, CV_32FC2);
    std::vector<cv::Mat> combiner;
    combiner.push_back(rf);
    combiner.push_back(cv::Mat::zeros(rf.size(), CV_32FC1));
    cv::merge(combiner, rfComplex);
    std::vector<cv::Mat> splitter;
    splitter.push_back(cv::Mat(rfComplex.rows, rfComplex.cols,CV_32FC1));
    splitter.push_back(cv::Mat(rfComplex.rows, rfComplex.cols,CV_32FC1));
    cv::Mat rfSpectrum = cv::Mat(rfComplex.rows, rfComplex.cols, CV_32FC2);

    // forward DFT
    cv::dft(rfComplex, rfSpectrum);
    cv::multiply(rfSpectrum, factor, rfSpectrum, 1.0, CV_32FC2);

    // inverse DFT
    cv::dft(rfSpectrum, rfComplex, DFT_INVERSE| DFT_SCALE);
    cv::split(rfComplex, splitter);

    // get imaginary part
    cv::Mat imag = splitter[1];
    cv::Mat envelope;

    cv::multiply(imag, cv::Scalar(1.0/rf.cols), imag, 1.0, CV_32FC1);
    cv::magnitude(rf, imag, envelope);
    return envelope;
}

cv::Mat GetMat(float** inData, int rows, int cols){ 
    cv::Mat DataMat(rows, cols, CV_32FC1);
    for (int r=0; r<rows; r++)
    {
        for (int c=0; c<cols; c++)
        {
            // printf("%d", r);
            DataMat.at<float>(r, c) = inData[r][c];
        }
    }
    return DataMat;
}

cv::Mat GenBmode(const cv::Mat& inRfMat){
    // input will be the raw acquired value in OpenCV Mat form    
    // performing hilber transform
    getMatDetails(inRfMat, "inRfMat");
    Mat env_dB = hilbertTrans4(inRfMat, 1.0);
    // getMatDetails(env_dB, "env_dB");
    cv::Mat log_compressed_data = logTransform(env_dB);

    return log_compressed_data;
}

cv::Mat MakeMask(const cv::Mat& inColimg){
    Mat alpha;
    cv::cvtColor(inColimg, alpha, COLOR_RGB2GRAY);
    cv::threshold(alpha, alpha, 20, 255, THRESH_BINARY);
    getMatDetails(alpha, "alpha channel");

    return alpha;
}

cv::Mat Blend(const cv::Mat& bground, const cv::Mat& fground, const cv::Mat& alpha){
    /*input 8uc3 images*/
    // convert to 0-1, 32FC3
    Mat bground_f, fground_f, alpha_f; 
    bground.convertTo(bground_f, CV_32FC3, 1.0/255);
    fground.convertTo(fground_f, CV_32FC3, 1.0/255); 
    cv::cvtColor(alpha, alpha_f, COLOR_GRAY2BGR);
    alpha_f.convertTo(alpha_f, CV_32FC3, 1.0/255); 
    
    //getMatDetails(bground_f, "bground_f");
    //getMatDetails(fground_f, "fground_f");
    //getMatDetails(alpha_f, "alpha_f");

    // Storage for output image
    Mat ouImage = Mat::zeros(fground_f.size(), fground_f.type());
 
    // Multiply the foreground with the alpha matte
    multiply(alpha_f, fground_f, fground_f); 
 
    // Multiply the background with ( 1 - alpha )
    multiply(Scalar::all(1.0)-alpha_f, bground_f, bground_f); 
 
    // Add the masked foreground and background.
    add(fground_f, bground_f, ouImage); 
    
    ouImage.convertTo(ouImage, CV_8UC3, 255);

    // Display image
    // imshow("alpha blended image", ouImage);

    return ouImage;
}

int main()
{
    clock_t t1;
    /// -------------------READING HEADER FILE TO GET THE REQUIRED INFORMATION--------------------------
    // const char* header_path = "./carotidheader_old.txt";
    const char* header_path = "./carotidheader_new.txt";
    float* hinfo = read_header(header_path);
    int rows=(int)hinfo[0];
    int cols=hinfo[18]*hinfo[2];
    int width=hinfo[2];
    int extra=hinfo[18];
    std::cout << "rows :" << rows << ", cols : " << cols << ", width : " << width << " , extra: " << extra << std::endl;

    //int rows, cols, width, extra;
    int i, j;
    float** RFdata;
    float*** RFdata3d;
    //float*;
    //float;
    cv::Mat inRfMat, BmodeMat;
    //const char* data_path = "carotidflow.csv";
    const char* data_path = "104934-66.csv";


    RFdata = read_data(data_path, hinfo);
    inRfMat = GetMat(RFdata, rows, cols); // convert Array into Mat
    // std::cout << inRfMat.rows << inRfMat.cols << std::endl;
    BmodeMat = GenBmode(inRfMat);// Converting the raw rf image into B-Mode image
    BmodeMat = convertDisplayMat(BmodeMat);// Converting the scale
    cv::cvtColor(BmodeMat, BmodeMat, COLOR_GRAY2BGR);
    cv::imwrite("BmodeMat_fromnew.png", BmodeMat);

    ////////////DATA RESHAPING////////////
   
    //double RFdata[rows][extra][width];
    //int* RFdata = (int*)malloc(rows*sizeof(int));
    
    RFdata3d = get3darray(rows, extra, width);
    cv::Mat RfMat(rows, extra, CV_64FC1);

    int pval=0;
    for (int nf=0;nf<width;nf++)
    {
        for (int c=0;c<extra;c++ )
        {
            for (int r=0;r<rows;r++)
            {
                // printf("%d", r);
                RFdata3d[r][c][nf]=RFdata[r][pval];
            }
            pval++;
        }
    }

    ////////////INITIALIZING THE PARAMETERS////////////

    int Linelength = 1760;
    int c = 1540;
    int ensemble = 8;
    int nlines = width;
    int W = 20;
    int deltaW = 10;
    int nW = floor((Linelength - W) / deltaW);
    double win[20] = { 0 };
    double Fe = hinfo[14];
    double Fs = hinfo[15];
    double Ts = (1 / Fs);
    double D = (double)(W*c) / (2.0 * Fs);
    double temp;
    double t[30] = { 0 };
    double sinterm[20] = { 0 };
    double costerm[20] = { 0 };

    std::cout << "rows : " << rows << std::endl;
    std::cout << "cols : " << cols << std::endl;
    std::cout << "width : " << width << std::endl;
    std::cout << "extra : " << extra << std::endl;
    std::cout << "Linelength : " << Linelength << std::endl;
    std::cout << "c : " << c << std::endl;
    std::cout << "ensemble : " << ensemble << std::endl;
    std::cout << "nlines : " << nlines << std::endl;
    std::cout << "W : " << W << std::endl;
    std::cout << "deltaW : " << deltaW << std::endl;
    std::cout << "nW : " << nW << std::endl;
    std::cout << "c : " << c << std::endl;
    std::cout << "Fe : " << Fe << std::endl;
    std::cout << "Fs : " << Fs << std::endl;
    std::cout << "Ts : " << Ts << std::endl;
    std::cout << "D : " << D << std::endl;


    ////////////IQ DEMODULATION///////////////
    int half=W/2;
    double sumwin=0;
    for (int n=0;n<W;n++)
    {
        if (n<half)
            {win[n]=0.5*(1-cos(2*pi*(n+1.0)/(W+1.0)));}
        else
           {win[n]=win[W-1-n];}

        sumwin+=win[n];
    }
    for (i=0;i<W;i++)
    {
        win[i]=win[i]/sumwin;
    }

    for (i=1;i<W;i++)
    {
        t[i]=t[i-1]+Ts;
    }

    for (j=0; j<W;j++)
    {
        sinterm[j] = win[j]*sin(2*pi*Fe*(j+1.0)/Fs);
        costerm[j] = win[j]*cos(2*pi*Fe*(j+1.0)/Fs);
    }

    float*** I = get3darray(nlines, nW, ensemble);
    float*** Q = get3darray(nlines, nW, ensemble);
    float*** filtI = get3darray(nlines, nW, ensemble);
    float*** filtQ = get3darray(nlines, nW, ensemble);
    //double I[nlines][nW][ensemble], Q[nlines][nW][ensemble],filtI[nlines][nW][ensemble],filtQ[nlines][nW][ensemble];
    double currentwindow[20], Reterms[20], Imterms[20], Re=0.0, Im=0.0;
    // currentline[Linelength];
    double* currentline = new double[Linelength];


    for (int le=0;le<nlines;le++)
    {
        for (int oe=0;oe<ensemble;oe++)
        {
            for (int cno=0;cno<Linelength;cno++)
            {
                temp=RFdata3d[cno][oe][le];
                currentline[cno]=temp;
            }
            for (int innerj=0;innerj<nW;innerj++)
            {
                Re=0.0;
                Im=0.0;
                for (int inval=0;inval<W;inval++)
                {
                    currentwindow[inval]=currentline[(innerj*deltaW)+inval];
                    Reterms[inval]=sinterm[inval]*currentwindow[inval];
                    Imterms[inval]=costerm[inval]*currentwindow[inval];
                    Re=Re+Reterms[inval];
                    Im=Im+Imterms[inval];
                }
                I[le][innerj][oe]=Re;
                Q[le][innerj][oe]=Im;

            }
        }
    }

    /////// Zero phase high pass filtering//////
    int filtord=2, nfact=6;
    // double tempi[ensemble],tempq[ensemble];
    double* tempi = new double[ensemble];
    double* tempq = new double[ensemble];
    int totallength=(nfact*2)+ensemble;
    //double tempi2[totallength],tempq2[totallength];
    double* tempi2 = new double[totallength];
    double* tempq2 = new double[totallength];
    double* ix = new double[totallength];
    double* iq = new double[totallength];
    double* tempirev = new double[totallength];
    double* tempqrev = new double[totallength];
    double* idata = new double[ensemble];
    double* qdata = new double[ensemble];

    for (int lp=0;lp<nlines;lp++)
    {
        for (int np=0;np<nW;np++)
        {
            for (int ne=0;ne<ensemble;ne++)
            {
                tempi[ne]=I[lp][np][ne];
                tempq[ne]=Q[lp][np][ne];
            }
            for (int tl=0;tl<totallength;tl++)
            {
                if (tl<nfact)
                {
                    tempi2[tl]= 2*tempi[0]-tempi[nfact-tl];
                    tempq2[tl]= 2*tempq[0]-tempq[nfact-tl];
                }
                else if ((tl>=nfact) & (tl<(totallength-nfact)))
                {
                    tempi2[tl]=tempi[tl-nfact];
                    tempq2[tl]=tempq[tl-nfact];
                }
                else if (tl>=(totallength-nfact))
                {
                    tempi2[tl]=(2*tempi[ensemble-1])-tempi[totallength-tl];
                    tempq2[tl]=(2*tempq[ensemble-1])-tempq[totallength-tl];
                }
            }

            /// -------------------------------FILTERING---------------------------
            /// ---------------------- Forward filtering ---------------------------
            double b[]={0.87517141414347399130946314471657, -1.7503428282869479826189262894331, 0.87517141414347399130946314471657}, a[]={1.0, -1.7346994738051471074413711903617, 0.76598618276874885779648138850462};
            double zi[]={ -0.87517141414347399130946314471657, 0.87517141414347365824255575716961};
            double zii[3],ziq[3];
            zii[0]=zi[0]*tempi2[0]; zii[1]=zi[1]*tempi2[0];zii[2]=0;
            ziq[0]=zi[0]*tempq2[0]; ziq[1]=zi[1]*tempq2[0];ziq[2]=0;
            // double ix[totallength],iq[totallength], idata[ensemble],qdata[ensemble], tempirev[totallength], tempqrev[totallength];
            // double idata[ensemble], qdata[ensemble];
            // may have to re initialize

            for (int m=0;m<totallength;m++)
            {
                ix[m]=b[0]*tempi2[m]+zii[0];
                iq[m]=b[0]*tempq2[m]+ziq[0];
                for (int minner=1;minner<=filtord;minner++)
                {
                    zii[minner-1]=b[minner]*tempi2[m]+zii[minner]-a[minner]*ix[m];
                    ziq[minner-1]=b[minner]*tempq2[m]+ziq[minner]-a[minner]*iq[m];
                }
            }
            for (int ind=0;ind<totallength;ind++)
            {
                tempirev[ind]=ix[totallength-ind-1];
                tempqrev[ind]=iq[totallength-ind-1];
            }

            /// ---------------------Reverse filtering ------------------------------
            zii[0]=zi[0]*tempirev[0]; zii[1]=zi[1]*tempirev[0]; zii[2]=0;
            ziq[0]=zi[0]*tempqrev[0]; ziq[1]=zi[1]*tempqrev[0]; ziq[2]=0;
            for (int m=0;m<totallength;m++)
            {
                ix[m]=b[0]*tempirev[m]+zii[0];
                iq[m]=b[0]*tempqrev[m]+ziq[0];
                for (int minner=1;minner<=filtord;minner++)
                {
                    zii[minner-1]=b[minner]*tempirev[m]+zii[minner]-a[minner]*ix[m];
                    ziq[minner-1]=b[minner]*tempqrev[m]+ziq[minner]-a[minner]*iq[m];
                }
            }
            for (int ind=0;ind<totallength;ind++)
            {
                tempirev[ind]=ix[totallength-ind-1];
                tempqrev[ind]=iq[totallength-ind-1];
            }

            for (int ind=0;ind<ensemble;ind++)
            {
                idata[ind]=tempirev[totallength-nfact-ind-1];
                qdata[ind]=tempqrev[totallength-nfact-ind-1];
            }

            for (int ne=0;ne<ensemble;ne++)
            {
                filtI[lp][np][ne]=idata[ne];
                filtQ[lp][np][ne]=qdata[ne];
            }

        }

    }
    
    delete[] tempi;
    delete[] tempq;
    delete[] tempi2;
    delete[] tempq2;
    delete[] ix;
    delete[] iq;
    delete[] tempirev;
    delete[] tempqrev;
    delete[] idata;
    delete[] qdata;

    printf("filtering Forward completed ");
    
    /////////////////////AUTOCORRELATION/////////////////////
    double Icurrent,Inext,Qcurrent,Qnext,nRx=0,nRy=0,nRo=0,nRt=0;
    double filtIcurrent,filtInext,filtQcurrent,filtQnext,fnRx=0,fnRy=0,fnRo=0,fnRt=0;
    // printf("nW %d , nlines %d ", nW, nlines);
    float** vel_est = get2darray(nW, nlines);
    float** sig_est = get2darray(nW, nlines);
    float** pow_est = get2darray(nW, nlines);
    float** filt_vel_est = get2darray(nW, nlines);
    float** filt_sig_est = get2darray(nW, nlines);
    float** filt_pow_est = get2darray(nW, nlines);
    // float vel_est[nW][nlines], sig_est[nW][nlines], pow_est[nW][nlines];
    // float filt_vel_est[nW][nlines], filt_sig_est[nW][nlines], filt_pow_est[nW][nlines];

    for (int le=0;le<nlines;le++)
    {
        for (j=0;j<nW;j++)
        {
            for (i=0;i<ensemble-1;i++)
            {
                //////////////IQ data//////////////
                Icurrent=I[le][j][i];
                Inext=I[le][j][i+1];
                Qcurrent=Q[le][j][i];
                Qnext=Q[le][j][i+1];

                nRy += (Icurrent*Qnext)-(Qcurrent*Inext);
                nRx += (Icurrent*Inext)+(Qcurrent*Qnext);
                nRo += (Icurrent*Icurrent)+(Qcurrent*Qcurrent);

                //////////////Filtered IQ data//////////////
                filtIcurrent=filtI[le][j][i];
                filtInext=filtI[le][j][i+1];
                filtQcurrent=filtQ[le][j][i];
                filtQnext=filtQ[le][j][i+1];

                fnRy += (filtIcurrent*filtQnext)-(filtQcurrent*filtInext);
                fnRx += (filtIcurrent*filtInext)+(filtQcurrent*filtQnext);
                fnRo += (filtIcurrent*filtIcurrent)+(filtQcurrent*filtQcurrent);
            }
            /////////////// IQ data ///////
            nRo += (Inext*Inext)*(Qnext*Qnext);
            // vel_est[j][le]= atan2(nRy,nRx);
            nRt=sqrt((nRx*nRx)+(nRy*nRy));
            sig_est[j][le]=1-(nRt/nRo);
            pow_est[j][le]=20*log10(1+(nRo/ensemble));
            nRy=0;nRx=0;nRo=0;
            //////////////filtered data///////
            fnRo += (filtInext*filtInext)*(filtQnext*filtQnext);
            filt_vel_est[j][le]= atan2(fnRy,fnRx);
            fnRt=sqrt((fnRx*fnRx)+(fnRy*fnRy));
            filt_sig_est[j][le]=1-(fnRt/fnRo);
            filt_pow_est[j][le]=20*log10(1+(fnRo/ensemble));

            fnRy=0;fnRx=0;fnRo=0;
        }

    }
    // printf("auto correlation completed");

    /////////////////////Post processing////////////////////////////
    int minpower=10, maxpower=150;
    for (i=0;i<nW;i++)
    {
        for (j=0;j<nlines;j++)
        {
            if ((filt_pow_est[i][j]<minpower) || (pow_est[i][j])> maxpower)
            {
                filt_vel_est[i][j]=0;
                filt_pow_est[i][j]=0;
                filt_sig_est[i][j]=0;
            }
        }
    }
    //printf(" Post processing completed ");
    //zero padding
    //printf("nW+2 %d , nlines+2 %d ", (nW+2), (nlines+2));

    float** vel_int = get2darray((nW+2), (nlines+2));
    float** sig_int = get2darray((nW+2), (nlines+2));
    float** pow_int = get2darray((nW+2), (nlines+2));
    float** vel_final = get2darray(nW, nlines);
    float** sig_final = get2darray(nW, nlines);
    float** pow_final = get2darray(nW, nlines);
    // double vel_int[nW+2][nlines+2],sig_int[nW+2][nlines+2],pow_int[nW+2][nlines+2],vel_final[nW][nlines],sig_final[nW][nlines],pow_final[nW][nlines];
    // memset(vel_int,0,sizeof vel_int);
    // memset(sig_int,0,sizeof sig_int);
    // memset(pow_int,0,sizeof pow_int);

    int p=0;
    double vals[9],vals_pow[9],temp_a;

    for (i=0;i<nW;i++)
    {
        for (j=0;j<nlines;j++)
        {
        vel_int[i+1][j+1]=filt_vel_est[i][j];
        pow_int[i+1][j+1]=filt_pow_est[i][j];
        }
    }
    // printf("zero padding completed ... ");


    for (i=0;i<nW;i++)
    {
        int x=i+1;
        for (j=0;j<nlines;j++)
        {
            int y=j+1;
            p=0;
            for (int k1=-1;k1<=1;k1++)
            {
                for (int k2=-1;k2<=1;k2++)
                {   // printf("%d, %d", x+k1, y+k2);
                    vals[p]=vel_int[x+k1][y+k2];
                    vals_pow[p]= pow_int[x+k1][y+k2];
                    p++;
                }
            }
            /// sorting
            for (int s1=0;s1<9;s1++)
            {
                for (int s2=0;s2<9;s2++)
                {
                    if (vals[s1]>vals[s2])
                    {
                        temp_a=vals[s1];
                        vals[s1]=vals[s2];
                        vals[s2]=temp_a;
                    }
                    if (vals_pow[s1]>vals_pow[s2])
                    {
                        temp_a=vals_pow[s1];
                        vals_pow[s1]=vals_pow[s2];
                        vals_pow[s2]=temp_a;
                    }
                }
            }
            vel_final[i][j]=vals[4];
            pow_final[i][j]=vals_pow[4];

        }
    }

    // ------> converting velocity data to Mat Format <----- //
    // std::cout << nW << int(nlines) << std::endl;
    Mat vel_final_mat = Mat::zeros(nW, nlines, CV_8UC1);
   

    for (int i = 0; i < nW; i++){
        
        for (int j=0; j< nlines; j++){
            vel_final_mat.at<uchar>(i, j) = int(pow_final[i][j]);
        }
    } 
    cv::imwrite("vel_final.png", vel_final_mat);

    // ----> Expanding the range of velocity image <----//
    double min_val, max_val;
    cv::minMaxIdx(vel_final_mat, &min_val, &max_val);
    
    vel_final_mat.convertTo(vel_final_mat, CV_8UC3, 255.0/(max_val-min_val)); //-255.0*min_val/(max_val-min_val)
    cv::cvtColor(vel_final_mat, vel_final_mat, COLOR_GRAY2RGB);
    cv::applyColorMap(vel_final_mat, vel_final_mat, COLORMAP_HOT); // Applying colormap to 8U
    cv::imwrite("./vel_final2.png", vel_final_mat);
    
   
    //----> Blend image <----//
    // Upscaling the "vel_final_mat"
    cv:: Mat color_img;
    cv::resize(vel_final_mat, color_img, BmodeMat.size(), INTER_LINEAR);
    cv::Mat alphaMask = MakeMask(color_img);
    cv::Mat blend_img = Blend(BmodeMat, color_img, alphaMask);
    cv::imwrite("./blended_image.png", blend_img);
    // waitKey(0);

    //-----> deleting arrays <------//
    delete3darray(filtQ, nlines, nW, ensemble);
    delete3darray(filtI, nlines, nW, ensemble);
    delete3darray(Q, nlines, nW, ensemble);
    delete3darray(I, nlines, nW, ensemble);
    delete2darray(vel_est, nW, nlines);
    delete2darray(sig_est, nW, nlines);
    delete2darray(pow_est, nW, nlines);
    delete2darray(filt_vel_est, nW, nlines);
    delete2darray(filt_sig_est, nW, nlines);
    delete2darray(filt_pow_est, nW, nlines);
    delete2darray(vel_int, (nW+2), (nlines+2));
    delete2darray(sig_int, (nW+2), (nlines+2));
    delete2darray(pow_int, (nW+2), (nlines+2));
    delete2darray(vel_final, nW, nlines);
    delete2darray(sig_final, nW, nlines);
    delete2darray(pow_final, nW, nlines);
    
    return 0;
   
}
