
#pragma once
#include <windows.h>
#include <cuda_runtime.h>
#include <cufft.h>      /// From "cufft.lib" 
#include "cuda.h"
#include <fstream>
#include "CyAPI.h"
#include "CyUSB30_def.h"

__global__ void range(int* out_data, int min, int arr_size, int inc);	//creates an array of a range of values

__global__ void range(float* out_data, float min, int arr_size, float inc);	//creates an array of a range of values

__global__ void range(double* out_data, double min, int arr_size, double inc);	//creates an array of a range of values

__global__ void range(long double* out_data, long double min, int arr_size, long double inc);	//creates an array of a range of values

__global__ void element_division(float* mat_in, float value, int size, float* mat_out);

__global__ void element_division(long double* mat_in, float value, int size, long double* mat_out);

__global__ void aperture_distance(float* mat1, float* mat2, int Nx, int channels, float* mat_out);

__global__ void apodization(float* distance, float* aperture, int Nz, int Nx, int channels, int pixels, float* apod);

__global__ void Tx_cen_pos(float* cen_pos, int N_elements, int N_active, float pitch, int skip_frames, int num_frames, float* probe); // This function calculates TX central aperture position

__global__ void receive_delay(float* probe_ge_x, float* x_axis1, float* z_axis1, int channels, int Nx, int Nz, float del_convert, float* rx_delay); // receive_delay calculation

__global__ void transmit_delay(float* x_axis1, float* z_axis1, float* k1, float zd, int Nx, int Nz, float del_convert, int num_frames, float* tx_delay); // transmit_delay calculation

__global__ void beamformingLR3(float* beamformed_data1, float* tx_delay, float* rx_delay, float* data, float* rx_apod, int samples, int pixels, int f, int num_frames, int channels);

__global__ void isnan_test_array(float* data, int size);

__global__ void BPfilter1SharedMem(float* in, float* filt_coeff, int pixels, float* y1);

__global__ void reshape_columnwise(int col, int row, float* beamformed_data_reshaped, float* d_bfHR);

__global__ void receive_delay(float* theta, float* theta1, float rc, float* z_axis, int channels, int Nx, int Nz, float del_convert, float* rx_delay);

__global__ void theta1(float* theta_active, float* theta, int frames, int N_active, int skip_frames);

//  transmit_delay calculation
__global__ void transmit_delay(float* theta1, float* z_axis, float rc, float* theta_tx, int Nx, int Nz, float del_convert, int columns, float zd, float* tx_delay);

__global__ void add_ele(float* data, int pixels, float* out_data);

__global__ void sample1(float* tx_delay, float* rx_delay, int pixels, int channels, float c, float sampling_frequency, float* data1, float* rx_apod, float* data, int samples, int columns);

__global__ void add_columns_matrix(float* data, int columns, int pixels, float* out_data);

__global__ void parallel_try(float* tx_delay, float* rx_delay, float sampling_frequency, float c, int samples,
	int channels, int columns, float* rx_apod, int pixels, float* data, float* beamformed_data);

class cudaBackEnd {
public:
	const int MAX_ITER = 128;
	const int N_RX = 64;
	static const int MAX_LINE = 256;
	static float PI;
	static const int MASK_WIDTH = 364;
	static const int TILE_SIZE = 4;
	static int num_threads;			// (NIVIDIA) parametrs
	static float rx_f_number;			// Apodization parameters
	//** Ultrasound scanner parametrs **//
	static int samples;                // # of samples in depth direction
	static int N_elements;				// # of transducer elements
	static float sampling_frequency;   // sampling frequency
	static float c;					// speed of sound [m/s]	
	static int N_active;				// Active transmit elmeents
	static float pitch;				// spacing between the elements
	static float aper_len;				// aperture foot print 
	static float zd;					// virtual src distance from transducer array 
	static float sample_spacing;		//
	static float del_convert;			// used in delay calculation
	static float rc;					// radius_of_curvature
	static float scan_angle;			//
	static int channels;	            // number of A-lines data used for beamforming
	//** Beamforming "Grid" parameters **//
	static int Nx;						// 256 Lateral spacing
	static int Nz;						// 1024 Axial spacing
	static int pixels;					//
	static int pix_cha;				// Nz*Nx*128 This array size is used for Apodization
	static int frames;					//
	static int num_frames;				// number of low resolution images
	static int skip_frames;			// 
	static int dBvalue;				// Post processing parameters.
	//static float rximg[128 * 2040];	// Global variable to store the full image.  Can't be declared local as,alloc may fail due to large size.
	static float* rximg;	// Global variable to store the full image.  Can't be declared local as,alloc may fail due to large size.
	static int croppedBot;
	//** Device and Host memmoey used in initializer **//
	static float* filt_coeff;
	static float* d_z_axis;
	static float* d_x_axis;
	static float* d_probe;
	static float* d_rx_aperture;
	static float* d_rx_ap_distance;
	static float* d_cen_pos;
	static float* d_data;			// variable to store raw rf data
	static float* d_bfHR;			// variable to store beamformed high-resolution beamformed image 
	static float* d_tx_delay;		//
	static float* d_rx_delay;		// delay calculation
	static float* d_rx_apod;		// apodization
	static float* d_filt_coeff;	// to read filter coeff CSV
	static float* d_bfHRBP;		// variable to store beamformed high-resolution bandpass filtered data
	static float* dev_beamformed_data1;	// variable to store reshaped beamformed data
	static float* env;					// Host memory variable to store beamformed high-resolution bandpass filtered data
	//** for curveLiner Prob  **//
	static float* d_theta;
	static float* d_theta1;
	static float* d_theta_tx;

	// Hw params
	static FILE* fp;

	// H/W initilization
	static CCyUSBDevice* USBDevice;	// H/W initilization1
	static CCyControlEndPoint* ept;	// H/W initilization2
	static CCyBulkEndPoint* ept_in;	// Endpoint for reading back data


	static void wait(unsigned timeout);

	static void write_rows(CCyControlEndPoint* ept, unsigned char* ptr, unsigned int numRows);

	static bool read_chunk(CCyBulkEndPoint* ept_in, unsigned char* recvBuf, LONG& length);

	static int insert_row(unsigned char* buf, int row, short addr, int data);

	static void read_csv_mat(float* data, char* filename, int col1);

	static void read_csv_mat(long double* data, char* filename, int col1);

	static void read_csv_array(float* data, char* filename);

	static void zeroC(float* bfHR, int pixels);

	static void csv_write_mat(long double* a, const char* filename, int row1, int col1);		//writes data to memory

	static void csv_write_mat(double* a, const char* filename, int row1, int col1);		//writes data to memory

	static void csv_write_mat(float* a, const char* filename, int row1, int col1);	//for writing integer data "FUNCTION OVERLOADING"

	static void read_csv_array_test(float*, char*);

	static double** cudaBackEnd::convertsingto2darray(float* imgArray, int rows, int cols);

	//void setMemmory(int);

	static int initHW();

	static int initSettingFile(const char* path);

	static int initGPUprobeC(double* prob_params);

	static double** computeBModeImgC();

	static int initGPUprobeL(double* prob_params);

	static double** computeBModeImgL();

	static double** computeBModeImg(int a);
};