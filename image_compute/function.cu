
// It reconstructs LR images separately and then add them to get HR image.
// Delay values and apodization are reshaped into [1 1024, 1 1024, ... pixels] ...
#include <stdlib.h>
#include <stdio.h>
#include <iomanip>
#include <ctime>
#include <math.h>
#include <string.h>
#include <time.h>
#include <exception>

// includes, project
#include <cuda_runtime.h>
#include <cufft.h>      /// From "cufft.lib" 
#include "cuda.h"
#include <windows.h>

#include "cudaHeader.cuh"
#include <stdlib.h>
#include <stdio.h>
#include <iomanip>
#include <ctime>
#include <math.h>
#include <string.h>
#include <time.h>
#include <fstream>

// include OpenCV Header
#include <opencv2/opencv.hpp>
// #include <opencv2/highgui.hpp>
// #include "mat_operations.h"
 #include "CyAPI.h"
 #include "CyUSB30_def.h"

namespace imageComputeCudaWrap {

	////////////////////////////////
	// Parameters for Linear Prob///
	////////////////////////////////

	// perform b-mode generation here using cuda
	const int TILE_SIZE = 4;
	int MASK_WIDTH = 364;
	const int MAX_LINE = 256;
	//// Computer (NIVIDIA) parametrs
	int num_threads = 1024;
	/// Apodization parameters
	float rx_f_number = 2.0;
	/////// Ultrasound scanner parametrs
	//float depth = 49.28;      // Depth of imaging in mm
	int samples = 2040;         // # of samples in depth direction
	int N_elements = 64;        // # of transducer elements
	float sampling_frequency = 32e6;   // sampling frequency
	float c = 1540.0;		 // speed of sound [m/s]	
	int N_active = 8;        // Active transmit elmeents
	float pitch = 0.3 / 1000;// spacing between the elements
	float aper_len = (N_elements - 1) * pitch * 1000;  //aperture foot print 
	float zd = pitch * N_active / (float)2;            // virtual src distance from transducer array 
	float sample_spacing = c / sampling_frequency / (float)2;
	float del_convert = sampling_frequency / c;  // used in delay calculation
	int channels = 64;							 // number of A-lines data used for beamforming
	//// Beamforming "Grid" parameters
	int Nx = 256;			// 256 Lateral spacing
	int Nz = 1024;			//1024 Axial spacing
	int pixels = Nz * Nx;
	int pix_cha = pixels * channels;// Nz*Nx*128 This array size is used for Apodization
	int num_frames = 57;			// number of low resolution images
	int skip_frames = 1;			//
	// Global variable to store the full image.  Cannot be declared local as memory alloc may fail due to large size.
	float rximg[64 * 2040];
	// Device and Host memmoey used in initializer
	float* filt_coeff = new float[MASK_WIDTH];
	float* d_z_axis = 0;
	float* d_x_axis = 0;
	float* d_probe = 0;
	float* d_rx_aperture = 0;
	float* d_rx_ap_distance = 0;
	float* d_cen_pos = 0;
	float* d_data = 0;					// variable to store raw rf data
	float* d_bfHR = 0;					// variable to store beamformed high-resolution beamformed image 
	float* d_tx_delay = 0;
	float* d_rx_delay = 0;				// delay calculation
	float* d_rx_apod = 0;				//apodization
	float* d_filt_coeff = 0;			//to read filter coeff CSV
	float* d_bfHRBP = 0;				// variable to store beamformed high-resolution bandpass filtered data
	float* dev_beamformed_data1 = 0;	// variable to store reshaped beamformed data
	float* env = new float[pixels];		// Host memory variable to store beamformed high-resolution bandpass filtered data		// Host memory variable to store beamformed high-resolution bandpass filtered data
	// for curveLiner Prob
	float* d_theta = 0;
	float* d_theta1 = 0;
	float* d_theta_tx = 0;
	// H/W initilization
	CCyUSBDevice* USBDevice;
	CCyControlEndPoint* ept;

	////////////////////////////////////
	/// Parameters for CurvLinear Prob//
	////////////////////////////////////

	////const int MAX_ITER = 128;
	////const int N_RX = 64;
	////const int MAX_LINE = 256;
	////float PI = 3.14;
	//const int MASK_WIDTH = 364;
	////const int TILE_SIZE = 4;
	//////// Computer (NIVIDIA) parametrs
	////int num_threads = 1024;
	/////// Apodization parameters
	////float rx_f_number = 2.0;
	/////////// Ultrasound scanner parametrs
	////int samples = 2040;						// # of samples in depth direction
	////int N_elements = 128;					// # of transducer elements
	////float sampling_frequency = 32e6;		// sampling frequency
	////float c = 1540.0;						// speed of sound [m/s]	
	////int N_active = 8;                       // Active transmit elmeents
	////float pitch = 0.465 / 1000;				// spacing between the elements
	////float aper_len = (N_elements - 1) * pitch * 1000;		//aperture foot print 
	////float zd = pitch * N_active / (float)2;					// virtual src distance from transducer array 
	////float sample_spacing = c / sampling_frequency / (float)2;
	////float del_convert = sampling_frequency / c;				// used in delay calculation
	////float rc = 60.1 / 1000;									// radius_of_curvature
	////float scan_angle = (58 * PI) / 180;
	////int channels = 128;										// number of A-lines data used for beamforming
	//////// Beamforming "Grid" parameters
	////int Nx = 256;							// 256 Lateral spacing
	////int Nz = 1024;							//1024 Axial spacing
	////int pixels = Nz * Nx;
	////int pix_cha = pixels * channels;		// Nz*Nx*128 This array size is used for Apodization
	////int frames = 121;
	////int num_frames = 121;					// number of low resolution images
	////int skip_frames = 1;  
	////// Post processing parameters.
	////int dBvalue = 60;
	//// Global variable to store the full image.  Cannot be declared local as memory alloc may fail due to large size.
	//float rximg[128 * 2040];
	//// parameters for matrix processing
	//int croppedBot = 300;
	//// cv::Mat outMat, outMatCrp, envolepMat, logcMat;



	////////////////////////////////////
	/// Parameters to read from CSV   //
	////////////////////////////////////

	//// perform b-mode generation here using cuda
	//const int TILE_SIZE = 4;
	//int MASK_WIDTH = 364;
	//const int MAX_LINE = 256;
	////// Computer (NIVIDIA) parametrs
	//int num_threads = 1024;
	///// Apodization parameters
	//float rx_f_number = 2.0;
	///////// Ultrasound scanner parametrs
	////float depth = 49.28;      // Depth of imaging in mm
	//int samples = 2040;         // # of samples in depth direction
	//int N_elements = 64;        // # of transducer elements
	//float sampling_frequency = 32e6;   // sampling frequency
	//float c = 1540.0;		 // speed of sound [m/s]	
	//int N_active = 8;        // Active transmit elmeents
	//float pitch = 0.3 / 1000;// spacing between the elements
	//float aper_len = (N_elements - 1) * pitch * 1000;  //aperture foot print 
	//float zd = pitch * N_active / (float)2;            // virtual src distance from transducer array 
	//float sample_spacing = c / sampling_frequency / (float)2;
	//float del_convert = sampling_frequency / c;  // used in delay calculation
	//int channels = 64;							 // number of A-lines data used for beamforming
	////// Beamforming "Grid" parameters
	//int Nx = 256;			// 256 Lateral spacing
	//int Nz = 1024;			//1024 Axial spacing
	//int pixels = Nz * Nx;
	//int pix_cha = pixels * channels;// Nz*Nx*128 This array size is used for Apodization
	//int num_frames = 57;			// number of low resolution images
	//int skip_frames = 1;			//
	//// Global variable to store the full image.  Cannot be declared local as memory alloc may fail due to large size.
	//float rximg[64 * 2040];
	//float* filt_coeff = new float[MASK_WIDTH];
	//float* d_z_axis = 0;
	//float* d_x_axis = 0;
	//float* d_probe = 0;
	//float* d_rx_aperture = 0;
	//float* d_rx_ap_distance = 0;
	//float* d_cen_pos = 0;
	//float* d_data = 0;   // variable to store raw rf data
	//float* d_bfHR = 0;  // variable to store beamformed high-resolution beamformed image 
	//float* d_tx_delay = 0;
	//float* d_rx_delay = 0;// delay calculation
	//float* d_rx_apod = 0; //apodization
	//float* d_filt_coeff = 0; //to read filter coeff CSV
	//float* d_bfHRBP = 0;  // variable to store beamformed high-resolution bandpass filtered data
	//float* dev_beamformed_data1 = 0;   // variable to store reshaped beamformed data
	//float* env = new float[pixels]; // Host memory variable to store beamformed high-resolution bandpass filtered data



	void wait(unsigned timeout)
	{
		timeout += std::clock();
		while (std::clock() < timeout) continue;
	}

	void write_rows(CCyControlEndPoint* ept, unsigned char* ptr, unsigned int numRows)
	{
		int len = numRows * 16; // each row is 16 bytes to send
		int sent = 0;
		unsigned char* tPtr = ptr;
		while (sent < len) {
			LONG buflen = len - sent;
			if (buflen > 192) buflen = 192;
			//for (int i = 0; i < buflen; i += 16) {
			//	for (int j = 0; j < 16; j++) {
			//		printf("%02X\t ", ptr[i + j]);
			//	}
			//	printf("\n");
			//}
			ept->XferData(tPtr, buflen);
			tPtr += buflen;
			sent += buflen;
		}
		//printf("Sent %d bytes to EPT\n", sent);
	}

	bool read_chunk(CCyBulkEndPoint* ept_in, unsigned char* recvBuf, LONG& length)
	{
		bool result;
		LONG intlen = length;
		result = ept_in->XferData(recvBuf, intlen, NULL, true);
		//if (result) {
		//	printf("Received data ------------- : %d\n", intlen);
		//}
		//else {
		//	printf("***   ERROR receiving data - expected %d, got %d\n", length, intlen);
		//}
		ept_in->Abort();
		ept_in->Reset();
		return result;
	}

	int insert_row(unsigned char* buf, int row, short addr, int data)
	{
		int o = row * 16;
		buf[o] = 0xff; buf[o + 1] = 0xaa; buf[o + 2] = 0x01; buf[o + 3] = 0x07;
		buf[o + 4] = 0x00; buf[o + 5] = 0x00; buf[o + 6] = 0x00; buf[o + 7] = 0x01;
		buf[o + 8] = (addr & 0xff); buf[o + 9] = (addr & 0xff00) >> 8;
		buf[o + 10] = (data & 0xff); buf[o + 11] = (data & 0xff00) >> 8;
		buf[o + 12] = (data & 0xff0000) >> 16; buf[o + 13] = (data & 0xff000000) >> 24;
		buf[o + 14] = 0x00; buf[o + 15] = 0x00;
		return row + 1;
	}

	__global__ void range(int* out_data, int min, int arr_size, int inc)	//creates an array of a range of values
	{
		int i = blockDim.x * blockIdx.x + threadIdx.x;								//min=starting value of array
																					//max=final value of the array
		if (i < arr_size)																//arr_size==array size
		{																			//inc=increment needed
			out_data[i] = min + (i * inc);
		}
	}

	__global__ void range(float* out_data, float min, int arr_size, float inc)	//creates an array of a range of values
	{
		int i = blockDim.x * blockIdx.x + threadIdx.x;								//min=starting value of array
																					//max=final value of the array
		if (i < arr_size)																//arr_size==array size
		{																			//inc=increment needed
			out_data[i] = min + (i * inc);
		}
	}

	__global__ void range(double* out_data, double min, int arr_size, double inc)	//creates an array of a range of values
	{
		int i = blockDim.x * blockIdx.x + threadIdx.x;								//min=starting value of array
																					//max=final value of the array
		if (i < arr_size)																//arr_size==array size
		{																			//inc=increment needed
			out_data[i] = min + (i * inc);
		}
	}

	__global__ void range(long double* out_data, long double min, int arr_size, long double inc)	//creates an array of a range of values
	{
		int i = blockDim.x * blockIdx.x + threadIdx.x;								//min=starting value of array
																					//max=final value of the array
		if (i < arr_size)																//arr_size==array size
		{																			//inc=increment needed
			out_data[i] = min + (i * inc);
		}
	}

	__global__ void element_division(float* mat_in, float value, int size, float* mat_out)
	{
		int i = blockDim.x * blockIdx.x + threadIdx.x;								//min=starting value of array
																					   //max=final value of the array
		if (i < size)
		{
			mat_out[i] = mat_in[i] / value;
		}
	}

	__global__ void element_division(long double* mat_in, float value, int size, long double* mat_out)
	{
		int i = blockDim.x * blockIdx.x + threadIdx.x;								//min=starting value of array
																					   //max=final value of the array
		if (i < size)
		{
			mat_out[i] = mat_in[i] / value;
		}
	}

	__global__ void aperture_distance(float* mat1, float* mat2, int Nx, int channels, float* mat_out)
	{
		int x = blockDim.x * blockIdx.x + threadIdx.x;
		//int y = blockDim.y * blockIdx.y + threadIdx.y;
		int i = x / channels;
		int j = x % channels;

		if (x < Nx * channels)
		{
			mat_out[i * channels + j] = fabs(mat1[i] - mat2[j]);
		}
	}

	__global__ void apodization(float* distance, float* aperture, int Nz, int Nx, int channels, int pixels, float* apod)
	{
		int x = blockDim.x * blockIdx.x + threadIdx.x;
		int i = x / Nz;
		int ii = i % Nx;
		int j = x % Nz;
		int nrx = x / pixels;
		float PI = 3.14159;

		if (x < pixels * channels)
		{
			bool temp = distance[ii * channels + nrx] <= (aperture[j] / 2);
			apod[i * Nz + j] = temp * (0.5 + 0.5 * cos(2 * PI * distance[ii * channels + nrx] / aperture[j]));
		}
	}

	// This function calculates TX central aperture position
	__global__ void Tx_cen_pos(float* cen_pos, int N_elements, int N_active, float pitch, int skip_frames, int num_frames, float* probe)
	{

		int x = threadIdx.x;

		if (x < num_frames)
		{
			//cen_pos[x] = pitch * ((N_active / 2) + (N_active * (x)-N_elements / 2));
			cen_pos[x] = probe[x * skip_frames + 4];
		}
	}

	// receive_delay calculation
	__global__ void receive_delay(float* probe_ge_x, float* x_axis1, float* z_axis1, int channels, int Nx, int Nz, float del_convert, float* rx_delay)
	{
		unsigned int x = blockDim.x * blockIdx.x + threadIdx.x;

		if (x < Nx * Nz * channels)
		{
			int i = x / Nz;
			int ii = i % Nx;
			int j = x % Nz;
			int nrx = x / (Nx * Nz);
			rx_delay[i * Nz + j] = (sqrt((probe_ge_x[nrx] - x_axis1[ii]) * (probe_ge_x[nrx] - x_axis1[ii]) + ((z_axis1[j]) * (z_axis1[j])))) * del_convert;
			// 1867 - 210 = 1657
			//rx_delay[i * Nx + j] = sqrt(rc * rc + (rc + z_axis[ii]) * (rc + z_axis[ii]) - 2 * rc * (rc + z_axis[ii]) * cos(theta[nrx] - theta1[j])) * del_convert;
		}
	}

	//  transmit_delay calculation
	__global__ void transmit_delay(float* x_axis1, float* z_axis1, float* k1, float zd, int Nx, int Nz, float del_convert, int num_frames, float* tx_delay)
	{
		int x = blockDim.x * blockIdx.x + threadIdx.x;
		int i = x / Nz;
		int ii = i % Nx;
		int j = x % Nz;
		int f = x / (Nx * Nz);

		if (x < Nx * Nz * num_frames)
		{
			tx_delay[i * Nz + j] = (sqrt(((k1[f] - x_axis1[ii]) * (k1[f] - x_axis1[ii])) + ((zd + z_axis1[j]) * (zd + z_axis1[j])))) * del_convert;
			// 1875-210 = 1665
			//tx_delay[i * Nx + j] = (zd + sqrt(rc * rc + (rc + z_axis[ii]) * (rc + z_axis[ii]) - 2 * rc * (rc + z_axis[ii]) * cos(theta_tx[f] - theta1[j]))) * del_convert;
			//first 256*1024 for frame 1, next 256*1024 for frame 2........
		}
	}

	void read_csv_mat(float* data, char* filename, int col1)
	{
		char buffer[6240];  //6240
		char* token;

		int i = 0, j = 0;
		FILE* file;
		file = fopen(filename, "r");
		if (file == NULL)
		{
			// printf("Can't open the file");
		}
		else
		{
			while (fgets(buffer, sizeof(buffer), file) != 0)            // end-of-file indicator
			{
				token = strtok(buffer, ",");
				j = 0;
				while (token != NULL)
				{
					data[i * col1 + j] = atof(token);     //converts the string argument str to float
					token = strtok(NULL, ",");
					j++;
				}

				i++;
			}
			fclose(file);
			// printf("Complete reading from file %s\n", filename);
		}
	}

	void read_csv_mat(long double* data, char* filename, int col1)
	{
		char buffer[6240];  //6240
		char* token;

		int i = 0, j = 0;
		FILE* file;
		file = fopen(filename, "r");
		if (file == NULL)
		{
			// printf("Can't open the file");
		}
		else
		{
			while (fgets(buffer, sizeof(buffer), file) != 0)            // end-of-file indicator
			{
				token = strtok(buffer, ",");
				j = 0;
				while (token != NULL)
				{
					data[i * col1 + j] = atof(token);     //converts the string argument str to float
					token = strtok(NULL, ",");
					j++;
				}

				i++;
			}
			fclose(file);
			// printf("Complete reading from file %s\n", filename);
		}
	}

	void read_csv_array(float* data, char* filename)
	{
		char buffer[6240];  //6240
		char* token;
		int i = 0;
		FILE* file;

		file = fopen(filename, "r");
		if (file == NULL)
		{
			throw std::exception("File did not open");
		}

		while (fgets(buffer, sizeof(buffer), file) != 0)            // end-of-file indicator
		{
			token = strtok(buffer, ",");
			//j = 0;
			while (token != NULL)
			{
				data[i] = atof(token);     //converts the string argument str to float
				token = strtok(NULL, ",");
				//j++;
			}

			i++;
		}
		fclose(file);
		// printf("Complete reading from file %s\n", filename);

	}

	__global__ void beamformingLR3(float* beamformed_data1, float* tx_delay, float* rx_delay, float* data, float* rx_apod, int samples, int pixels, int f, int num_frames, int channels)
	{
		unsigned int x = blockDim.x * blockIdx.x + threadIdx.x;
		int nrx = x / pixels;   // nrx - nth A-line
		int pix = x & (pixels - 1); // x% pixels;     // pixel location

		int pixel_pos = round((float)tx_delay[f * pixels + pix] + (float)rx_delay[x]);   // delay value estimation from tx and rx delay values

		if (pixel_pos < samples)
		{
			beamformed_data1[pix] += rx_apod[x] * data[(nrx * samples + pixel_pos - 1)];   // Extract data based on the delay values and multiplying with apodization value
		}
	}

	__global__ void isnan_test_array(float* data, int size)
	{
		int idx = threadIdx.x + blockDim.x * blockIdx.x;
		if (idx < size)
		{
			if (isnan(data[idx]) == 1)
			{
				data[idx] = 0;
			}
			else
			{
				data[idx] = data[idx];
			}

		}


	}

	__global__ void BPfilter1SharedMem(float* in, float* filt_coeff, int pixels, float* y1) {

		const int TILE_SIZE = 4;
		int MASK_WIDTH = 364;

		int x = blockIdx.x * blockDim.x + threadIdx.x;
		__shared__ float N_s[TILE_SIZE];
		N_s[threadIdx.x] = in[x];
		__syncthreads();

		int PtileStartPt = blockIdx.x * blockDim.x;
		int NtileStartPt = (blockIdx.x + 1) * blockDim.x;
		int n_start_pt = x - (MASK_WIDTH / 2);

		float temp = 0;

		for (int j = 0; j < MASK_WIDTH; j++) {
			int N_index = n_start_pt + j;

			if (N_index >= 0 && N_index < pixels) {
				if ((N_index >= PtileStartPt) && (N_index < NtileStartPt)) {
					temp += N_s[threadIdx.x + j - (MASK_WIDTH / 2)] * filt_coeff[j];
				}
				else {
					temp += in[N_index] * filt_coeff[j];
				}
			}
		}
		y1[x] = temp;
	}

	__global__ void reshape_columnwise(int col, int row, float* beamformed_data_reshaped, float* d_bfHR)
	{
		int x = blockDim.x * blockIdx.x + threadIdx.x;
		//int y = blockDim.y * blockIdx.y + threadIdx.y;
		int i = x / row;
		int j = x % row;

		if (x < col * row)
		{
			beamformed_data_reshaped[j * col + i] = d_bfHR[x];

		}
	}

	/// <Curvilinear Prob>

	// receive_delay calculation
	__global__ void receive_delay(float* theta, float* theta1, float rc, float* z_axis, int channels, int Nx, int Nz, float del_convert, float* rx_delay)
	{
		int x = blockDim.x * blockIdx.x + threadIdx.x;

		if (x < Nz * Nx * channels)
		{
			int i = x / Nz;
			int ii = i % Nx;
			int j = x % Nz;
			int nrx = x / (Nx * Nz);
			rx_delay[i * Nz + j] = sqrt(rc * rc + (rc + z_axis[j]) * (rc + z_axis[j]) - 2 * rc * (rc + z_axis[j]) * cos(theta[nrx] - theta1[ii])) * del_convert;
		}
	}

	__global__ void theta1(float* theta_active, float* theta, int frames, int N_active, int skip_frames)
	{

		int x = threadIdx.x;
		int f = 0;
		for (int i = 1; i <= frames; i += skip_frames)
		{
			theta_active[f] = theta[i + 3 - 1];
			f++;
		}
	}

	//  transmit_delay calculation
	__global__ void transmit_delay(float* theta1, float* z_axis, float rc, float* theta_tx, int Nx, int Nz, float del_convert, int columns, float zd, float* tx_delay)
	{
		int x = blockDim.x * blockIdx.x + threadIdx.x;
		int i = x / Nz;
		int j = x % Nz;
		int f = x / (Nx * Nz);


		if (x < Nx * Nz * columns)
		{
			tx_delay[i * Nz + j] = (zd + sqrt(rc * rc + (rc + z_axis[j]) * (rc + z_axis[j]) - 2 * rc * (rc + z_axis[j]) * cos(theta_tx[f] - theta1[i % Nx]))) * del_convert;
		}
	}

	__global__ void add_ele(float* data, int pixels, float* out_data)
	{
		int x = blockDim.x * blockIdx.x + threadIdx.x;
		//int y = blockDim.y * blockIdx.y + threadIdx.y;
		if (x < pixels)
		{
			out_data[x] += data[x];
		}
	}

	__global__ void sample1(float* tx_delay, float* rx_delay, int pixels, int channels, float c, float sampling_frequency, float* data1, float* rx_apod, float* data, int samples, int columns)
	{
		int x = blockDim.x * blockIdx.x + threadIdx.x;
		int f = blockDim.y * blockIdx.y + threadIdx.y;
		int nrx = x / pixels; //channels
		int pix = x % pixels; //pixels


		if (f < columns)
		{
			float delay = ((float)tx_delay[f * pixels + pix] + (float)rx_delay[(nrx % channels) * pixels + pix]) / c;
			float p = delay * sampling_frequency;
			int pixel_pos = round(p);

			//data1 = rx_apod[(nrx % channels) + (pix * channels)] * data[((nrx % channels) * samples + pixel_pos - 1) * columns + f];
		}
	}

	__global__ void add_columns_matrix(float* data, int columns, int pixels, float* out_data)
	{
		int x = blockDim.x * blockIdx.x + threadIdx.x;
		//int y = blockDim.y * blockIdx.y + threadIdx.y;
		if (x < pixels)
		{
			for (int f = 0; f < columns; f++)
				out_data[x] += data[x * columns + f];
		}
	}

	__global__ void parallel_try(float* tx_delay, float* rx_delay, float sampling_frequency, float c, int samples,
		int channels, int columns, float* rx_apod, int pixels, float* data, float* beamformed_data)
	{
		//__shared__ double* beamformed_data_1;
		int pix = blockDim.x * blockIdx.x + threadIdx.x;
		int nrx = blockDim.y * blockIdx.y + threadIdx.y;
		//int f = x / pixels; int pix = x % pixels; //int nrx = x % 128;
		int f = blockDim.z * blockIdx.z + threadIdx.z;
		//int nrx = x / pixels; //channels
		//int pix = x % pixels; //pixels
		//int f = x / (pixels * channels);

		if (f < columns && pix < pixels && nrx < channels)
		{
			//for (int nrx = 0; nrx < channels; nrx++)
			//{

			float delay = ((float)tx_delay[f * pixels + pix] + (float)rx_delay[(nrx)*pixels + pix]) / c;
			float p = delay * sampling_frequency;
			int pixel_pos = round(p);

			if ((0 < pixel_pos) && (pixel_pos < samples))
			{
				//double ans= beamformed_data[pix] + rx_apod[channels * nrx + pix] * data[nrx * 2600 + pixel_pos];
				beamformed_data[pix * columns + f] += rx_apod[nrx + (pix * channels)] * data[(nrx * samples + pixel_pos - 1) * columns + f];

			}
			//}
		}
	}

	void zeroC(float* bfHR, int pixels)
	{
		for (int j = 0; j < pixels; j++)
		{
			bfHR[j] = 0;
		}
	}

	/// </Curvilinear Prob>

	void csv_write_mat(long double* a, const char* filename, int row1, int col1)		//writes data to memory
	{
		FILE* fp;
		int i;

		fp = fopen(filename, "w+");

		for (i = 0; i < row1; ++i)
		{
			for (int j = 0; j < col1; j++)
			{
				if (j == col1 - 1)					//for the last value in the column "," is not appended
				{									//matrix dimension error can occur with the presence of extra comma at last of the column
					fprintf(fp, "%g", a[i * col1 + j]);
				}
				else
					fprintf(fp, "%g,", a[i * col1 + j]);
			}



			fprintf(fp, "\n");
		}


		fclose(fp);
		// printf("\n %s file is created\n", filename);
	}

	void csv_write_mat(double* a, const char* filename, int row1, int col1)		//writes data to memory
	{
		FILE* fp;
		int i;

		fp = fopen(filename, "w+");

		for (i = 0; i < row1; ++i)
		{
			for (int j = 0; j < col1; j++)
			{
				if (j == col1 - 1)					//for the last value in the column "," is not appended
				{									//matrix dimension error can occur with the presence of extra comma at last of the column
					fprintf(fp, "%g", a[i * col1 + j]);
				}
				else
					fprintf(fp, "%g,", a[i * col1 + j]);
			}



			fprintf(fp, "\n");
		}


		fclose(fp);
		printf("\n %s file is created\n", filename);
	}

	void csv_write_mat(float* a, const char* filename, int row1, int col1)	//for writing integer data "FUNCTION OVERLOADING"
	{
		FILE* fp;
		int i;

		fp = fopen(filename, "w+");

		for (i = 0; i < row1; ++i)
		{
			for (int j = 0; j < col1; j++)
			{
				if (j == col1 - 1)
				{
					fprintf(fp, "%f", a[i * col1 + j]);
				}
				else

					fprintf(fp, "%f,", a[i * col1 + j]);
			}



			fprintf(fp, "\n");
		}


		fclose(fp);
		// printf("\n %s file is created\n", filename);
	}

	//double** ConvertMatto2DArray(cv::Mat img)
	//{
	//	double** array2D = (double**)malloc(img.rows * sizeof(double*));
	//	for (int i = 0; i < img.rows; i++) {
	//		array2D[i] = (double*)malloc(img.cols * sizeof(double));
	//	}
	//	// Fill the values
	//	for (int i = 0; i < img.rows; i++) {
	//		for (int j = 0; j < img.cols; j++) {
	//			array2D[i][j] = img.at<double>(i, j);
	//		}
	//	}
	//	return array2D;
	//}

	double** convertsingto2darray(float* imgArray, int rows, int cols) {

		double** array2D = (double**)malloc(rows * sizeof(double*));
		for (int i = 0; i < rows; i++) {
			array2D[i] = (double*)malloc(cols * sizeof(double));
		}

		for (int i = 0; i < rows; i++) {
			for (int j = 0; j < cols; j++) {
				array2D[i][j] = (double)imgArray[i * cols + j];
			}
		}

		return array2D;
	}

	// Function to initialize the CUDA memmory if read from CSV
	extern std::string cuMemInit() {

		const int MAX_ITER = 128;
		const int N_RX = 64;
		const int MAX_LINE = 256;
		float PI = 3.14;
		const int MASK_WIDTH = 364;
		const int TILE_SIZE = 4;
		int num_threads = 1024;
		float rx_f_number = 2.0;
		int samples = 2040;
		int N_elements = 128;
		float sampling_frequency = 32.0e6;
		float c = 1540.0;
		int N_active = 8;
		int channels = 128;
		int	Nx = 256;
		int Nz = 1024;
		int frames = 121;
		//int num_frames = 121;
		int skip_frames = 1;
		int	dBvalue = 60;
		float pitch = 0.000465;
		float aper_len = 59.055;
		float zd = 0.00186;
		float sample_spacing = 2.40625e-05;
		float del_convert = 20779.2;
		float rc = 0.0601;
		float scan_angle = 1.01178;
		int pixels = 262144;
		int pix_cha = 33554432;

		std::ofstream mFile;
		mFile.open("sample_output/test_meminit.txt");
		std::string out_string = "OK";

			int num_frames = 57;

		try {
			char filename1[200];
			sprintf(filename1, "b_10M.csv");
			filt_coeff = new float[MASK_WIDTH];
			read_csv_array(filt_coeff, filename1);    // csv file read
		}

		catch (std::exception& err) {
			return err.what();
		}

		cudaMalloc((void**)&d_filt_coeff, sizeof(float) * MASK_WIDTH);
		cudaMemcpy(d_filt_coeff, filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);

		////////////// z value////////////////////
		float dz = sample_spacing * samples / Nz;  // depth / (Nz - 1) / 1000;   // spacing in axial (z) direction in mm;
		cudaMalloc((void**)&d_z_axis, Nz * sizeof(float));
		range << <Nz / num_threads + 1, num_threads >> > (d_z_axis, 0, Nz, dz);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////////////////////////// x value////////////////////////////////
		float dx = aper_len / (Nx - 1);
		cudaMalloc((void**)&d_x_axis, Nx * sizeof(float));    // 167.939 us
		range << <Nx / num_threads + 1, num_threads >> > (d_x_axis, (-aper_len / 2000), Nx, dx / 1000);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////////// Probe geometry, this info can be taken from transducer file ////////////////////
		cudaMalloc((void**)&d_probe, N_elements * sizeof(float));
		range << <1, N_elements >> > (d_probe, (-aper_len / 2000), N_elements, pitch);
		cudaGetLastError();
		cudaDeviceSynchronize();

		/////////////////rx aperture calculation using Fnumber///////////////////////////////
		// rx_aper=rfsca.z/rf_number
		cudaMalloc((void**)&d_rx_aperture, Nz * sizeof(float));
		element_division << <Nz / num_threads + 1, num_threads >> > (d_z_axis, rx_f_number, Nz, d_rx_aperture);
		cudaGetLastError();
		cudaDeviceSynchronize();

		////////////////////////rx aerture distance////////
		cudaMalloc((void**)&d_rx_ap_distance, channels * Nx * sizeof(float));
		aperture_distance << <Nx * channels / num_threads + 1, num_threads >> > (d_x_axis, d_probe, Nx, channels, d_rx_ap_distance);
		cudaGetLastError();
		cudaDeviceSynchronize();

		///////////////////apodization/////////////////
		cudaMalloc((void**)&d_rx_apod, sizeof(float) * Nz * channels * Nx);
		apodization << <pixels * channels / num_threads + 1, num_threads >> > (d_rx_ap_distance, d_rx_aperture, Nz, Nx, channels, pixels, d_rx_apod);
		cudaGetLastError();
		cudaDeviceSynchronize();
		cudaFree(d_rx_aperture);
		cudaFree(d_rx_ap_distance);

		/////////////////// calculate central positions transmit subaperture ////////////////////
		cudaMalloc((void**)&d_cen_pos, num_frames * sizeof(float));
		Tx_cen_pos << < 1, num_frames >> > (d_cen_pos, N_elements, N_active, pitch, skip_frames, num_frames, d_probe);
		/////////////receive delay calculation /////////////////////////////////////////////
		cudaMalloc((void**)&d_rx_delay, pix_cha * sizeof(float));
		receive_delay << < pixels * channels / num_threads + 1, num_threads >> > (d_probe, d_x_axis, d_z_axis, channels, Nx, Nz, del_convert, d_rx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();

		////////////Initialize d_bfHR to store final high-resolution beamformed image /////////////////////////////
		cudaMalloc((void**)&d_bfHR, pixels * sizeof(float));
		//zeros << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);  
		cudaMemset(d_bfHR, 0, pixels * sizeof(float));

		/////////////////// Transmit delay calculation ////////////////////
		cudaMalloc((void**)&d_tx_delay, pixels * num_frames * sizeof(float));
		//transmit delay for all frames,   
		transmit_delay << < pixels * num_frames / num_threads + 1, num_threads >> > (d_x_axis, d_z_axis, d_cen_pos, zd, Nx, Nz, del_convert, num_frames, d_tx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();

		////////////Free cuda memory (one time use) ///////////////////////////
		cudaFree(d_probe);
		cudaFree(d_x_axis);
		cudaFree(d_z_axis);
		cudaFree(d_cen_pos);

		mFile << "minit end" << std::endl;
		mFile.close();

		return out_string;
	}

	// Function to compute the B-mode image if read from CSV
	extern double** computeImg() {

		// test values
		const int MAX_ITER = 128;
		const int N_RX = 64;
		const int MAX_LINE = 256;
		float PI = 3.14;
		const int MASK_WIDTH = 364;
		const int TILE_SIZE = 4;
		int num_threads = 1024;
		float rx_f_number = 2.0;
		int samples = 2040;
		int N_elements = 128;
		float sampling_frequency = 32.0e6;
		float c = 1540.0;
		int N_active = 8;
		int channels = 128;
		int	Nx = 256;
		int Nz = 1024;
		int frames = 121;
		//int num_frames = 121;
		int skip_frames = 1;
		int	dBvalue = 60;
		float pitch = 0.000465;
		float aper_len = 59.055;
		float zd = 0.00186;
		float sample_spacing = 2.40625e-05;
		float del_convert = 20779.2;
		float rc = 0.0601;
		float scan_angle = 1.01178;
		int pixels = 262144;
		int pix_cha = 33554432;

		float* data = new float[samples * channels];
		float* d_data = 0;
		cudaMalloc((void**)&d_data, sizeof(float) * samples * channels);
		int num_frames = 57;

		for (int f = 0; f < num_frames; f++)
		{
			char filename[200];
			sprintf(filename, "inputs/raw_rf_dbsat_Ptsca_arr_%d.csv", f); //all the LR inputs are arranged in a single file

			read_csv_mat(data, filename, 1);    // csv file read

			clock_t begin = clock();   // clock intiated

			cudaMemcpy(d_data, data, sizeof(float) * samples * channels, cudaMemcpyHostToDevice);

			beamformingLR3 << <(pixels / 256) * channels, 256 >> > (d_bfHR, d_tx_delay, d_rx_delay, d_data, d_rx_apod, samples, pixels, f, num_frames, channels);
			cudaGetLastError();
			cudaDeviceSynchronize();

			clock_t end = clock();
			float elapsed_secs = float(end - begin) / CLOCKS_PER_SEC;
			//printf("Time for beamforming in ms: %f\n", elapsed_secs * 1000);

		}

		//// check for nan values,
		isnan_test_array << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);
		cudaGetLastError();
		cudaDeviceSynchronize();

		cudaMalloc((void**)&d_bfHRBP, sizeof(float) * pixels);

		//////////// Bandpass filtering using shared memory /////////////////////
		BPfilter1SharedMem << <(pixels + TILE_SIZE - 1) / TILE_SIZE, TILE_SIZE >> > (d_bfHR, d_filt_coeff, pixels, d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////////// reshape of the beamformed data ///////////////
		cudaMalloc((void**)&dev_beamformed_data1, pixels * sizeof(float));   //234.130 us
		reshape_columnwise << <pixels / num_threads + 1, num_threads >> > (Nx, Nz, dev_beamformed_data1, d_bfHRBP);  //48.864 us
		cudaGetLastError();
		cudaDeviceSynchronize();

		cudaMemcpy(env, dev_beamformed_data1, Nz * Nx * sizeof(float), cudaMemcpyDeviceToHost);
		const char* fileout = "sample_output/b_csv_mode.csv";
		csv_write_mat(env, fileout, Nz, Nx);

		//////////////// Free cuda memory (that will be used again) ///////////////
		cudaFree(d_data);
		cudaFree(d_bfHR);
		cudaFree(d_tx_delay);
		cudaFree(d_rx_delay);
		cudaFree(d_rx_apod);
		cudaFree(dev_beamformed_data1);
		cudaFree(d_bfHRBP);

		double** outArray = convertsingto2darray(env, Nz, Nx);


		return outArray;
	}

	//// Function to initialize the CUDA memmory if read from Linear prob

	extern int cuMemInitLinear() {

	
		char filename3[200];
		sprintf(filename3, "b_10M.csv");
		read_csv_array(filt_coeff, filename3);    // csv file read
		//cv::imwrite("okMat3.png", testMat0);
	
		// float* d_filt_coeff = 0;
		cudaMalloc((void**)&d_filt_coeff, sizeof(float) * MASK_WIDTH);
		cudaMemcpy(d_filt_coeff, filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);
	
		////////  Intialization &(or) Memory allocation  //////////////////
		// float* d_data = 0;   // variable to store raw rf data
		cudaMalloc((void**)&d_data, sizeof(float) * samples * channels);
	
		// float* d_bfHR = 0;  // variable to store beamformed high-resolution beamformed image 
		cudaMalloc((void**)&d_bfHR, pixels * sizeof(float));
		//zeros << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);  
		cudaMemset(d_bfHR, 0, pixels * sizeof(float));
	
		// float* dev_beamformed_data1 = 0;   // variable to store reshaped beamformed data
		cudaMalloc((void**)&dev_beamformed_data1, pixels * sizeof(float));
	
		// float* d_bfHRBP = 0;  // variable to store beamformed high-resolution bandpass filtered data
		cudaMalloc((void**)&d_bfHRBP, sizeof(float) * pixels);
	
		// float* env = new float[pixels]; // Host memory variable to store beamformed high-resolution bandpass filtered data
	
		////////////// z value////////////////////
		float dz = sample_spacing * samples / Nz;  // depth / (Nz - 1) / 1000;   // spacing in axial (z) direction in mm;
		// float* d_z_axis = 0;
		cudaMalloc((void**)&d_z_axis, Nz * sizeof(float));
		range << <Nz / num_threads + 1, num_threads >> > (d_z_axis, 0, Nz, dz);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		//////////////////////////////// x value////////////////////////////////
		float dx = aper_len / (Nx - 1);
		// float* d_x_axis = 0;
		cudaMalloc((void**)&d_x_axis, Nx * sizeof(float));    // 167.939 us
		range << <Nx / num_threads + 1, num_threads >> > (d_x_axis, (-aper_len / 2000), Nx, dx / 1000);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		//////////////// Probe geometry, this info can be taken from transducer file ////////////////////
		//float* d_probe = 0;
		cudaMalloc((void**)&d_probe, N_elements * sizeof(float));
		range << <1, N_elements >> > (d_probe, (-aper_len / 2000), N_elements, pitch);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		/////////////////rx aerture calculation using Fnumber///////////////////////////////
		// rx_aper=rfsca.z/rf_number
		// float* d_rx_aperture = 0;
		cudaMalloc((void**)&d_rx_aperture, Nz * sizeof(float));
		element_division << <Nz / num_threads + 1, num_threads >> > (d_z_axis, rx_f_number, Nz, d_rx_aperture);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		////////////////////////rx aerture distance////////
		// float* d_rx_ap_distance = 0;
		cudaMalloc((void**)&d_rx_ap_distance, channels * Nx * sizeof(float));
		aperture_distance << <Nx * channels / num_threads + 1, num_threads >> > (d_x_axis, d_probe, Nx, channels, d_rx_ap_distance);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		///////////////////apodization/////////////////
		// float* d_rx_apod = 0;
		cudaMalloc((void**)&d_rx_apod, sizeof(float) * Nz * channels * Nx);
		apodization << <pixels * channels / num_threads + 1, num_threads >> > (d_rx_ap_distance, d_rx_aperture, Nz, Nx, channels, pixels, d_rx_apod);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		cudaFree(d_rx_aperture);
		cudaFree(d_rx_ap_distance);
	
		/////////////////// calculate central positions transmit subaperture ////////////////////
		// float* d_cen_pos = 0;
		cudaMalloc((void**)&d_cen_pos, num_frames * sizeof(float));
		Tx_cen_pos << < 1, num_frames >> > (d_cen_pos, N_elements, N_active, pitch, skip_frames, num_frames, d_probe);
	
		/////////////receive delay calculation /////////////////////////////////////////////
		// float* d_rx_delay = 0;
		cudaMalloc((void**)&d_rx_delay, pix_cha * sizeof(float));
		receive_delay << < pixels * channels / num_threads + 1, num_threads >> > (d_probe, d_x_axis, d_z_axis, channels, Nx, Nz, del_convert, d_rx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		/////////////////// Transmit delay calculation ////////////////////
		// float* d_tx_delay = 0;
		cudaMalloc((void**)&d_tx_delay, pixels * num_frames * sizeof(float));
		//transmit delay for all frames,   
		transmit_delay << < pixels * num_frames / num_threads + 1, num_threads >> > (d_x_axis, d_z_axis, d_cen_pos, zd, Nx, Nz, del_convert, num_frames, d_tx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		////////////Free cuda memory (one time use) ///////////////////////////
		cudaFree(d_probe);
		cudaFree(d_x_axis);
		cudaFree(d_z_axis);
		cudaFree(d_cen_pos);
	
		//cv::Mat testMat0 = cv::Mat::zeros(250, 200, CV_8UC1);
		//cv::imwrite("btestMat5.png", testMat0);
		//// Memmory allocation problem in cuda
		//cv::Mat testMat0 = cv::Mat::zeros(250, 200, CV_8UC1);
		//cv::imwrite("btestMat0.png", testMat0);
		//return -1;
	
		USBDevice = new CCyUSBDevice(NULL);
		// Obtain the control endpoint pointer
		ept = USBDevice->ControlEndPt;
		if (!ept) {
			// Could not get Control endpoin
			// printf("Could not get Control endpoint.\n");
			//cv::Mat testMat0 = cv::Mat::zeros(250, 200, CV_8UC1);
			//cv::imwrite("errorMat1.png", testMat0);
			return 2;
		}
	
		//	Any h/w initialization Error
		//	cv::Mat testMat0 = cv::Mat::zeros(250, 200, CV_8UC1);
		//	cv::imwrite("btestMat3.png", testMat0);
		//	return -3;
	
		return 0;
	
	}

	// Function to initialize the CUDA memmory if read from CurvLinear prob

	extern int cuMemInitCurv(double* probPrms) {
	
		//std::ofstream mFile1, mFile2;
		//mFile1.open("sample_output/curve_params.txt");
		//mFile2.open("sample_output/curve_params2.txt");

		//for (int i = 0; i < 29; i++) {
		//	mFile1  << probPrms[i] << std::endl;
		//}

		const int MAX_ITER = (int)probPrms[0]; //mFile2 << MAX_ITER << std::endl;
		const int N_RX = (int)probPrms[1];// mFile2 << N_RX << std::endl;
		const int MAX_LINE = (int)probPrms[2]; //mFile2 << MAX_LINE << std::endl;
		float PI = (float)probPrms[3]; //mFile2 << PI << std::endl;
		const int MASK_WIDTH = (int)probPrms[4];// mFile2 << MASK_WIDTH << std::endl;
		const int TILE_SIZE = (int)probPrms[5]; //mFile2 << TILE_SIZE << std::endl;
		int num_threads = (int)probPrms[6]; //mFile2 << num_threads << std::endl;
		float rx_f_number = (float)probPrms[7]; //mFile2 << rx_f_number << std::endl;
		int samples = (int)probPrms[8]; ///mFile2 << samples << std::endl;
		int N_elements = (int)probPrms[9]; //mFile2 << N_elements << std::endl;
		float sampling_frequency = (float)probPrms[10]; ///mFile2 << sampling_frequency << std::endl;
		float c = (float)probPrms[11]; //mFile2 << c << std::endl;
		int N_active = (int)probPrms[12]; //mFile2 << N_active << std::endl;
		int channels = (int)probPrms[13]; //mFile2 << channels << std::endl;
		int	Nx = (int)probPrms[14]; //mFile2 << Nx << std::endl;
		int Nz = (int)probPrms[15]; //mFile2 << Nz << std::endl;
		int frames = (int)probPrms[16]; //mFile2 << frames << std::endl;
		int num_frames = (int)probPrms[17]; //mFile2 << num_frames << std::endl;
		int skip_frames = (int)probPrms[18]; //mFile2 << skip_frames << std::endl;
		int	dBvalue = (int)probPrms[19];// mFile2 << dBvalue << std::endl;
		float pitch = (float)probPrms[20]; //mFile2 << pitch << std::endl;
		float aper_len = (float)probPrms[21];// mFile2 << aper_len << std::endl;
		float zd = (float)probPrms[22]; //mFile2 << zd << std::endl;
		float sample_spacing = (float)probPrms[23]; //mFile2 << sample_spacing << std::endl;
		float del_convert = (float)probPrms[24]; //mFile2 << del_convert << std::endl;
		float rc = (float)probPrms[25]; //mFile2 << rc << std::endl;
		float scan_angle = (float)probPrms[26]; //mFile2 << scan_angle  << std::endl;
		int pixels = (int)probPrms[27]; //mFile2 << pixels << std::endl;
		int pix_cha = (int)probPrms[28]; //mFile2 << pix_cha << std::endl;

		//mFile1.close();
		//mFile2.close();


		//const int MAX_ITER = 128;
		//const int N_RX =  64;
		//const int MAX_LINE = 256;
		//float PI = 3.14;
		//const int MASK_WIDTH = 364;
		//const int TILE_SIZE = 4;
		//int num_threads = 1024;
		//float rx_f_number = 2.0;
		//int samples = 2040;
		//int N_elements = 128;
		//float sampling_frequency = 32.0e6;
		//float c = 1540.0;
		//int N_active = 8;
		//int channels = 128;
		//int	Nx = 256;
		//int Nz = 1024;
		//int frames = 121;
		//int num_frames = 121;
		//int skip_frames = 1;
		//int	dBvalue = 60;
		//float pitch = 0.000465;
		//float aper_len = 59.055;
		//float zd = 0.00186;
		//float sample_spacing = 2.40625e-05;
		//float del_convert = 20779.2;
		//float rc = 0.0601;
		//float scan_angle = 1.01178;
		//int pixels = 262144;
		//int pix_cha = 33554432;

		float* filt_coeff = new float[MASK_WIDTH];
		char filename1[200];
		sprintf(filename1, "b_10M.csv");
		read_csv_array(filt_coeff, filename1);    // csv file read
	
		//float* d_filt_coeff = 0;
		cudaMalloc((void**)&d_filt_coeff, sizeof(float) * MASK_WIDTH);
		cudaMemcpy(d_filt_coeff, filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);
	
		////////  Intialization &(or) Memory allocation  //////////////////
		//float* d_data = 0;   // variable to store raw rf data
		cudaMalloc((void**)&d_data, sizeof(float) * samples * channels);
	
		//float* d_bfHR = 0;  // variable to store beamformed high-resolution beamformed image 
		cudaMalloc((void**)&d_bfHR, pixels * sizeof(float));
		//zeros << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);  
		cudaMemset(d_bfHR, 0, pixels * sizeof(float));
	
		//float* dev_beamformed_data1 = 0;   // variable to store reshaped beamformed data
		cudaMalloc((void**)&dev_beamformed_data1, pixels * sizeof(float));
	
		//float* d_bfHRBP = 0;  // variable to store beamformed high-resolution bandpass filtered data
		cudaMalloc((void**)&d_bfHRBP, sizeof(float) * pixels);
	
		//float* env = new float[pixels]; // Host memory variable to store beamformed high-resolution bandpass filtered data
	
		/////////////////// theta positions for all elements ////////////////////
		//float* d_theta = 0;
		cudaMalloc((void**)&d_theta, N_elements * sizeof(float));
		range << <Nx / num_threads + 1, num_threads >> > (d_theta, (-scan_angle / 2), N_elements, (scan_angle / (N_elements - 1)));
	
	
		///////////// theta for grid /////////////////  theta = -scan_angle / 2 : scan_angle / (elements - 1) : scan_angle / 2;
		//float* d_theta1 = 0;
		cudaMalloc((void**)&d_theta1, Nx * sizeof(float));
		range << <Nx / num_threads + 1, num_threads >> > (d_theta1, (-scan_angle / 2), Nx, (scan_angle / (Nx - 1)));
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		////////////// z value////////////////////
		float dz = sample_spacing * samples / Nz;  // depth / (Nz - 1) / 1000;   // spacing in axial (z) direction in mm;
		float* d_z_axis = 0;
		cudaMalloc((void**)&d_z_axis, Nz * sizeof(float));
		range << <Nz / num_threads + 1, num_threads >> > (d_z_axis, 0, Nz, dz);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		//////////////////////////////// x value////////////////////////////////
		float dx = aper_len / (Nx - 1);
		float* d_x_axis = 0;
		cudaMalloc((void**)&d_x_axis, Nx * sizeof(float));
		range << <Nx / num_threads + 1, num_threads >> > (d_x_axis, (-aper_len / 2000), Nx, dx / 1000);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		//////////////// Probe geometry, this info can be taken from transducer file ////////////////////
		//float* d_probe = 0;
		cudaMalloc((void**)&d_probe, N_elements * sizeof(float));
		//cudaMemcpy(d_probe, probe_ge_x, N_elements * sizeof(double), cudaMemcpyHostToDevice);
		range << <1, N_elements >> > (d_probe, (-aper_len / 2000), N_elements, pitch);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		/////////////////rx aerture calculation using Fnumber///////////////////////////////
		// rx_aper=rfsca.z/rf_number
		//float* d_rx_aperture = 0;
		cudaMalloc((void**)&d_rx_aperture, Nz * sizeof(float));
		element_division << <Nz / num_threads + 1, num_threads >> > (d_z_axis, rx_f_number, Nz, d_rx_aperture);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		////////////////////////rx aerture distance////////
		//float* d_rx_ap_distance = 0;
		cudaMalloc((void**)&d_rx_ap_distance, channels * Nx * sizeof(float));  //20.087 us
		aperture_distance << <Nx * channels / num_threads + 1, num_threads >> > (d_x_axis, d_probe, Nx, channels, d_rx_ap_distance);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		///////////////////apodization/////////////////
		//float* d_rx_apod = 0;
		cudaMalloc((void**)&d_rx_apod, sizeof(float) * Nz * channels * Nx);
		apodization << <pixels * channels / num_threads + 1, num_threads >> > (d_rx_ap_distance, d_rx_aperture, Nz, Nx, channels, pixels, d_rx_apod);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		//// check for nan values,
		isnan_test_array << <pixels * channels / num_threads + 1, num_threads >> > (d_rx_apod, pixels * channels);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		cudaFree(d_rx_aperture);
		cudaFree(d_rx_ap_distance);
	
		/////////////receive delay calculation /////////////////////////////////////////////
		//float* d_rx_delay = 0;
		cudaMalloc((void**)&d_rx_delay, pix_cha * sizeof(float));
		receive_delay << < pixels * channels / num_threads + 1, num_threads >> > (d_theta, d_theta1, rc, d_z_axis, channels, Nx, Nz, del_convert, d_rx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		/////////////////// theta positions for all elements ////////////////////
		//float* d_theta_tx = 0;
		cudaMalloc((void**)&d_theta_tx, num_frames * sizeof(float));
		theta1 << < 1, num_frames >> > (d_theta_tx, d_theta, frames, N_active, skip_frames);
	
		/////////////////// Transmit delay calculation ////////////////////
		//float* d_tx_delay = 0;
		cudaMalloc((void**)&d_tx_delay, pixels * num_frames * sizeof(float));
		//transmitter delay for 16 frames,  
		transmit_delay << < pixels * num_frames / num_threads + 1, num_threads >> > (d_theta1, d_z_axis, rc, d_theta_tx, Nx, Nz, del_convert, num_frames, zd, d_tx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();
	
		cudaFree(d_theta1);
		cudaFree(d_probe);
		cudaFree(d_x_axis);
		cudaFree(d_z_axis);
		cudaFree(d_theta_tx);
	
		//mFile << "pitch : " << pitch << std::endl << " aper_len:  " << aper_len << " zd : " << zd <<
		//	" sample_spacing : " << sample_spacing << " del_convert : " << del_convert << " rc : " << rc <<
		//	" scan_angle " << scan_angle << " pixels " << pixels << " pix_cha " << pix_cha << std::endl;
	
		zeroC(rximg, samples * N_elements);   // set rx_img array values to zero.
	
		USBDevice = new CCyUSBDevice(NULL);
		// Obtain the control endpoint pointer
		ept = USBDevice->ControlEndPt;
		if (!ept) {
			//printf("Could not get Control endpoint.\n");
			return 1;
		}

		
		return 0;
	}

	// Function to compute the B - mode image if read from Linear prob

	extern double** computeLinearImg() {

		static double pix2 = 0.0;
		// cv::Mat testMat0 = cv::Mat::zeros(250, 1000, CV_8UC1);
		//for (double pix = 0; pix < 255.000; pix++)
		//{
		unsigned char buf[16 * 1024];
		int row = 0;  // Keep track of how many rows have been added
		errno_t err;
		char line[MAX_LINE]; // Max possible line length?
		FILE* fp;
		if ((err = fopen_s(&fp, "out25.txt", "r")) != 0) {
			//printf("Could not open config file for reading.\n");
			//cv::imwrite("errorMat2.png", testMat0);
			exit(1);
		}
		// Send a vendor request (bRequest = 0x05) to the device
		ept->Target = TGT_DEVICE;
		ept->ReqType = REQ_VENDOR;
		ept->Direction = DIR_TO_DEVICE;
		ept->ReqCode = 0x05;
		ept->Value = 1;
		ept->Index = 0;
		ept->TimeOut = 100;  // set timeout to 100ms for quick response
		// Endpoint for reading back data
		CCyBulkEndPoint* ept_in;
		ept_in = USBDevice->BulkInEndPt;
		if (!ept_in) {
			//printf("No IN endpoint??\n");
			exit(1);
		}
		ept_in->MaxPktSize = 16384;
		ept_in->TimeOut = 100;  // set timeout to 100ms for reading
		int iteration = 0;
		int errcount = 0;
		unsigned int addr, data;
		unsigned char recvbuf[2048 * 64 * 2];
		const int MAXROWS = 2040;
		LONG rxlen = MAXROWS * 64 * 2;
	
		// unsigned int start = clock();
		while (fgets(line, MAX_LINE, fp)) {
			line[strcspn(line, "\n")] = 0; // Trim trailing newline
			if ((strlen(line) == 0) || (line[0] == ' ') || (line[0] == '#')) {
				//printf("Skipping [%s]\n", line);
			}
			else if (line[0] == 'O') {
				sscanf_s(line, "O %04X %08X ", &addr, &data);
				//printf("Write %08X to Obelix %04X\n", data, addr);
				row = insert_row(buf, row, addr, data);
			}
			else if (line[0] == 'T') {
				sscanf_s(line, "T %04X %08X ", &addr, &data);
				row = insert_row(buf, row, 0x6, 0x40000000 | addr);
				row = insert_row(buf, row, 0x7, data);
				row = insert_row(buf, row, 0x6, 0xC0000000 | addr);
				//printf("Write %08X to TX %04X\n", data, addr);
			}
			else if (line[0] == 'A') {
				sscanf_s(line, "A %04X %08X ", &addr, &data);
				row = insert_row(buf, row, 0x6, 0x00000000 | addr);
				row = insert_row(buf, row, 0x7, data);
				row = insert_row(buf, row, 0x6, 0x80000000 | addr);
				//printf("Write %08X to AFE %04X\n", data, addr);
			}
			else if (line[0] == 'C') {  // CAPTURE
				//wait(100);
				row = insert_row(buf, row, 0x4, 0x01);
				//write_rows(ept, buf, row);  // Send commands
				//wait(100);
				row = insert_row(buf, row, 0x4, 0x10);
				//write_rows(ept, buf, row);  // Send commands
				//wait(100);
				row = insert_row(buf, row, 0x4, 0x00);
				ept_in->Abort();
				ept_in->Reset();
				write_rows(ept, buf, row);  // Send commands
				wait(1);
				if (read_chunk(ept_in, recvbuf, rxlen)) {
					short* rxdata = (short*)(recvbuf);
					for (int i = 0; i < rxlen / 2; i++) {
						if (rxdata[i] >= 512) rxdata[i] -= 1024;
					}
					// Trying to read only first N-1 rows and discard 1st sample
					for (int i = 0; i < 64; i++) {
						for (int j = 0; j < MAXROWS - 1; j++) {
							//rximg[iteration][i][j] = rxdata[j*64+i+2];
							rximg[i * MAXROWS + j] = rxdata[j * 64 + i + 2];
						}
					}
					//saveToFile(iteration, rxlen, recvbuf);
				}
				else {
					errcount++;
				}
				cudaMemcpy(d_data, rximg, sizeof(float) * samples * channels, cudaMemcpyHostToDevice);
				beamformingLR3 << <(pixels / 256) * channels, 256 >> > (d_bfHR, d_tx_delay, d_rx_delay, d_data, d_rx_apod, samples, pixels, iteration, num_frames, channels);
				cudaGetLastError();
				cudaDeviceSynchronize();
				iteration++; // Increment iteration after saving to image
				row = 0;   // Reset buffer for next iteration
			}
			else {
				printf("Don't know how to handle [%s] yet.\n", line);
			}
		}
	
		//// check for nan values,
		isnan_test_array << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);
		cudaGetLastError();
		cudaDeviceSynchronize();
		//////////// Bandpass filtering using shared memory /////////////////////
		BPfilter1SharedMem << <(pixels + TILE_SIZE - 1) / TILE_SIZE, TILE_SIZE >> > (d_bfHR, d_filt_coeff, pixels, d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();
		//////////////// reshape of the beamformed data ///////////////
		reshape_columnwise << <pixels / num_threads + 1, num_threads >> > (Nx, Nz, dev_beamformed_data1, d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();
		cudaMemcpy(env, dev_beamformed_data1, Nz * Nx * sizeof(float), cudaMemcpyDeviceToHost);
		char fileout[200];
		//sprintf(fileout, "b_mode_%d.csv", 1); //all the 16 inputs are arranged in a single file
		//csv_write_mat(env, fileout, Nz, Nx);
		double** outArray = convertsingto2darray(env, Nz, Nx);
	
		//outMatCrp = outMat(cv::Range(0, Nz - croppedBot), cv::Range(0, Nx));
		//envolepMat = hilbertTrans4(outMatCrp, 1.0);
		//// log compression
		//logcMat = logTransform(envolepMat);
		//cv::Mat outMat = cv::Mat::zeros(1024, 254, CV_64FC1);
		//for (int r = 0; r < 1024; r++) {
		//	for (int c = 0; c < 254; c++) {
		//		outMat.at<double>(r, c) = pix2;
		//	}
		//}
		//cv::imwrite("sample_output/inLogMat" + std::to_string(pix2) + ".png", logcMat);
		//pix2 = pix2 + 10.0;
		//}
	
		//////////////// Free cuda memory (that will be used again) ///////////////
		cudaFree(d_data);
		cudaFree(d_bfHR);
		cudaFree(d_tx_delay);
		cudaFree(d_rx_delay);
		cudaFree(d_rx_apod);
		cudaFree(dev_beamformed_data1);
		cudaFree(d_bfHRBP);
		cudaFree(d_filt_coeff);
	
		return outArray;
		//return ConvertMatto2DArray(logcMat);
	}

	// Function to compute the B - mode image if read from Linear prob

	extern double** computeCurveImg(double* probPrms)
	{

		const int MAX_ITER = 128;
		const int N_RX = 64;
		const int MAX_LINE = 256;
		//float PI = 3.14;
		//const int MASK_WIDTH = 364;
		//const int TILE_SIZE = 4;
		//int num_threads = 1024;
		//float rx_f_number = 2.0;
		//int samples = 2040;
		//int N_elements = 128;
		//float sampling_frequency = 32.0e6;
		//float c = 1540.0;
		//int N_active = 8;
		//int channels = 128;
		//int	Nx = 256;
		//int Nz = 1024;
		//int frames = 121;
		//int num_frames = 121;
		//int skip_frames = 1;
		//int	dBvalue = 60;
		//float pitch = 0.000465;
		//float aper_len = 59.055;
		//float zd = 0.00186;
		//float sample_spacing = 2.40625e-05;
		//float del_convert = 20779.2;
		//float rc = 0.0601;
		//float scan_angle = 1.01178;
		//int pixels = 262144;
		//int pix_cha = 33554432;

		//const int MAX_ITER = (const int)probPrms[0]; //mFile2 << MAX_ITER << std::endl;
		//const int N_RX = (const int)probPrms[1];// mFile2 << N_RX << std::endl;
		//const int MAX_LINE = (const int)probPrms[2]; //mFile2 << MAX_LINE << std::endl;
		float PI = (float)probPrms[3]; //mFile2 << PI << std::endl;
		const int MASK_WIDTH = (int)probPrms[4];// mFile2 << MASK_WIDTH << std::endl;
		const int TILE_SIZE = (int)probPrms[5]; //mFile2 << TILE_SIZE << std::endl;
		int num_threads = (int)probPrms[6]; //mFile2 << num_threads << std::endl;
		float rx_f_number = (float)probPrms[7]; //mFile2 << rx_f_number << std::endl;
		int samples = (int)probPrms[8]; ///mFile2 << samples << std::endl;
		int N_elements = (int)probPrms[9]; //mFile2 << N_elements << std::endl;
		float sampling_frequency = (float)probPrms[10]; ///mFile2 << sampling_frequency << std::endl;
		float c = (float)probPrms[11]; //mFile2 << c << std::endl;
		int N_active = (int)probPrms[12]; //mFile2 << N_active << std::endl;
		int channels = (int)probPrms[13]; //mFile2 << channels << std::endl;
		int	Nx = (int)probPrms[14]; //mFile2 << Nx << std::endl;
		int Nz = (int)probPrms[15]; //mFile2 << Nz << std::endl;
		int frames = (int)probPrms[16]; //mFile2 << frames << std::endl;
		int num_frames = (int)probPrms[17]; //mFile2 << num_frames << std::endl;
		int skip_frames = (int)probPrms[18]; //mFile2 << skip_frames << std::endl;
		int	dBvalue = (int)probPrms[19];// mFile2 << dBvalue << std::endl;
		float pitch = (float)probPrms[20]; //mFile2 << pitch << std::endl;
		float aper_len = (float)probPrms[21];// mFile2 << aper_len << std::endl;
		float zd = (float)probPrms[22]; //mFile2 << zd << std::endl;
		float sample_spacing = (float)probPrms[23]; //mFile2 << sample_spacing << std::endl;
		float del_convert = (float)probPrms[24]; //mFile2 << del_convert << std::endl;
		float rc = (float)probPrms[25]; //mFile2 << rc << std::endl;
		float scan_angle = (float)probPrms[26]; //mFile2 << scan_angle  << std::endl;
		int pixels = (int)probPrms[27]; //mFile2 << pixels << std::endl;
		int pix_cha = (int)probPrms[28]; //mFile2 << pix_cha << std::endl;

	
		//for (int i = 0; i < 2; i++) {
		cv::Mat testMat0 = cv::Mat::zeros(250, 1000, CV_8UC1);
		unsigned char buf[16 * 1024];
	
		errno_t err;
		char line[MAX_LINE]; // Max possible line length?
		FILE* fp;
		if ((err = fopen_s(&fp, "out25_curvi.txt", "r")) != 0) {
			//printf("Could not open config file for reading.\n");
			//exit(1);
			return nullptr;
		}
	
		// Send a vendor request (bRequest = 0x05) to the device
		ept->Target = TGT_DEVICE;
		ept->ReqType = REQ_VENDOR;
		ept->Direction = DIR_TO_DEVICE;
		ept->ReqCode = 0x05;
		ept->Value = 1;
		ept->Index = 0;
		ept->TimeOut = 100;  // set timeout to 100ms for quick response
		cv::imwrite("sample_output/testMat3.png", testMat0);
	
		// Endpoint for reading back data
		CCyBulkEndPoint* ept_in;
		ept_in = USBDevice->BulkInEndPt;
		if (!ept_in) {
			//printf("No IN endpoint??\n");
			//exit(1);
			cv::imwrite("sample_output/errorMat3.png", testMat0);
			return nullptr;
		}
		ept_in->MaxPktSize = 16384;
		ept_in->TimeOut = 100;  // set timeout to 100ms for readin
		int iteration = 0;
		int errcount = 0;
		int row = 0;  // Keep track of how many rows have been added
	
		unsigned int addr, data;
		unsigned char recvbuf[2048 * N_RX * 2];
		const int MAXROWS = 2040;
		LONG rxlen = MAXROWS * N_RX * 2;
		cv::imwrite("sample_output/testMat4.png", testMat0);
		//unsigned int start = clock();
		while (fgets(line, MAX_LINE, fp)) {
			line[strcspn(line, "\n")] = 0; // Trim trailing newline
			if ((strlen(line) == 0) || (line[0] == ' ') || (line[0] == '#')) {
				//printf("Skipping [%s]\n", line);
			}
			else if (line[0] == 'O') {
				sscanf_s(line, "O %04X %08X ", &addr, &data);
				//printf("Write %08X to Obelix %04X\n", data, addr);
				row = insert_row(buf, row, addr, data);
			}
			else if (line[0] == 'T') {
				sscanf_s(line, "T %04X %08X ", &addr, &data);
				row = insert_row(buf, row, 0x6, 0x40000000 | addr);
				row = insert_row(buf, row, 0x7, data);
				row = insert_row(buf, row, 0x6, 0xC0000000 | addr);
				//printf("Write %08X to TX %04X\n", data, addr);
			}
			else if (line[0] == 'A') {
				sscanf_s(line, "A %04X %08X ", &addr, &data);
				row = insert_row(buf, row, 0x6, 0x00000000 | addr);
				row = insert_row(buf, row, 0x7, data);
				row = insert_row(buf, row, 0x6, 0x80000000 | addr);
				//printf("Write %08X to AFE %04X\n", data, addr);
			}
			else if (line[0] == 'C') {  // CAPTURE
				//wait(100);
				row = insert_row(buf, row, 0x4, 0x01);
				//write_rows(ept, buf, row);  // Send commands
				//wait(100);
				row = insert_row(buf, row, 0x4, 0x10);
				//write_rows(ept, buf, row);  // Send commands
				//wait(100);
				row = insert_row(buf, row, 0x4, 0x00);
	
				ept_in->Abort();
				ept_in->Reset();
	
				write_rows(ept, buf, row);  // Send commands
				//wait(100);
				//row = insert_row(buf, row, 0x4, 0x03);
				//row = insert_row(buf, row, 0x4, 0x10);
				//row = insert_row(buf, row, 0x4, 0x00);
				//printf("CAPTURE %2d: ", iteration);
				//write_rows(ept, buf, row);  // Send commands
				// One iteration should have 2048 samples * 64 channels * 2 bytes each
	
	
				wait(1);
				if (read_chunk(ept_in, recvbuf, rxlen)) {
					short* rxdata = (short*)(recvbuf);
					for (int i = 0; i < rxlen / 2; i++) {
						if (rxdata[i] >= 512) rxdata[i] -= 1024;
					}
	
					// Trying to read only first N-1 rows and discard 1st sample
					for (int i = 0; i < N_RX; i++) {
						for (int j = 0; j < MAXROWS - 1; j++) {
							//rximg[iteration][i][j] = rxdata[j*64+i+2];
							if (iteration < 29) {      // start from 0 index, so 30-1 
								rximg[i * MAXROWS + j] = rxdata[j * N_RX + i + 2];
							}
							else if (iteration > 91) {
								rximg[(i + 64) * MAXROWS + j] = rxdata[j * N_RX + i + 2];
							}
							else {
								rximg[(i + iteration - 28) * MAXROWS + j] = rxdata[j * N_RX + i + 2];
							}
							//rximg[i * MAXROWS + j] = rxdata[j * N_RX + i + 2];
						}
					}
					//saveToFile(iteration, rxlen, recvbuf);
				}
				else {
					errcount++;
				}
	
				//clock_t begin = clock();   // clock intiated
	
				cudaMemcpy(d_data, rximg, sizeof(float) * samples * channels, cudaMemcpyHostToDevice);
	
				beamformingLR3 << <(pixels / 256) * channels, 256 >> > (d_bfHR, d_tx_delay, d_rx_delay, d_data, d_rx_apod, samples, pixels, iteration, num_frames, channels);
				cudaGetLastError();
				cudaDeviceSynchronize();
	
				//clock_t end = clock();
				//float elapsed_secs = float(end - begin) / CLOCKS_PER_SEC;
				//printf("Time for beamforming in ms: %f\n", elapsed_secs * 1000);
	
	
				iteration++; // Increment iteration after saving to image
				row = 0;   // Reset buffer for next iteration
			}
			else {
				printf("Don't know how to handle [%s] yet.\n", line);
				cv::imwrite("sample_output/errorMat3.png", testMat0);
			}
		}
		//unsigned int stop = clock();
		//printf("\n\n\n******\n");
		//printf("Ran %d iterations with %d errors in %d ms\n", iteration, errcount, stop - start);
	
		cv::imwrite("sample_output/testMat5.png", testMat0);
		//////////// Bandpass filtering using shared memory /////////////////////
		BPfilter1SharedMem << <(pixels + TILE_SIZE - 1) / TILE_SIZE, TILE_SIZE >> > (d_bfHR, d_filt_coeff, pixels, d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();
		//////////////// reshape of the beamformed data ///////////////
		reshape_columnwise << <pixels / num_threads + 1, num_threads >> > (Nx, Nz, dev_beamformed_data1, d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();
		cudaMemcpy(env, dev_beamformed_data1, Nz * Nx * sizeof(float), cudaMemcpyDeviceToHost);
		char fileout[200];
		sprintf(fileout, "sample_output/b_curve_mode.csv"); //all the 16 inputs are arranged in a single file
		csv_write_mat(env, fileout, Nz, Nx);
		cv::imwrite("sample_output/testMat6.png", testMat0);
		double** outArray = convertsingto2darray(env, Nz, Nx);
		//////////////// Free cuda memory (that will be used again) ///////////////
		cudaFree(d_data);
		cudaFree(d_bfHR);
		cudaFree(d_tx_delay);
		cudaFree(d_rx_delay);
		cudaFree(d_rx_apod);
		cudaFree(dev_beamformed_data1);
		return outArray;
	}

}