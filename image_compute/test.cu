#include <cuda_runtime.h>
#include <cufft.h>      /// From "cufft.lib" 
#include "cuda.h"
#include <fstream>
#include "testheader.cuh"
#include "device_launch_parameters.h"
#include <chrono>
using std::chrono::high_resolution_clock;
using std::chrono::duration_cast;
using std::chrono::duration;
using std::chrono::milliseconds;


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

//** <Curvilinear Prob> **//

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


__global__ void real2complex(float* f, cufftComplex* fc) {
	//int i = threadIdx.x;
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	fc[i].x = f[i];
	fc[i].y = 0.0f;
}

__global__ void splitComplex(cufftComplex* inComplex, float* outReal, float* outImag) {

	int i = blockIdx.x * blockDim.x + threadIdx.x;
	outReal[i] = inComplex[i].x;
	outImag[i] = inComplex[i].y;

}

__global__ void scalarMult(float* inArray, float* outArray, float c) {

	int i = blockIdx.x * blockDim.x + threadIdx.x;
	outArray[i] = inArray[i] * c;

}

__global__ void magnitide(float* inX, float* inY, float* outW) {

	int i = blockIdx.x * blockDim.x + threadIdx.x;
	outW[i] = std::sqrtf(std::pow(inX[i], 2) + std::pow(inY[i], 2));

}

__global__ void logCompresion(float* inArray, float* outArray, float c= 20.0) {

	int i = blockIdx.x * blockDim.x + threadIdx.x;
	outArray[i] = c * std::log10(1 + inArray[i]);

}



//cudaBackEnd::cudaBackEnd() {
//
//	int num_threads = 1024;
//	float rx_f_number = 2.0;
//	int samples = 2040;						// # of samples in depth direction
//	int N_elements = 128;					// # of transducer elements
//	float sampling_frequency = 32e6;		// sampling frequency
//	float c = 1540.0;						// speed of sound [m/s]	
//	int N_active = 8;						// Active transmit elmeents
//	float pitch = 0.465 / 1000;				// spacing between the elements
//	float aper_len = (N_elements - 1) * pitch * 1000;	//aperture foot print 
//	float zd = pitch * N_active / (float)2;				// virtual src distance from transducer array 
//	float sample_spacing = c / sampling_frequency / (float)2;
//	float del_convert = sampling_frequency / c;			// used in delay calculation
//	float rc = 60.1 / 1000;					// radius_of_curvature
//	float scan_angle = (58 * PI) / 180;
//	int channels = 128;						// number of A-lines data used for beamforming
//	int Nx = 256;							// 256 Lateral spacing
//	int Nz = 1024;							//1024 Axial spacing
//	int pixels = Nz * Nx;
//	int pix_cha = pixels * channels;		// Nz*Nx*128 This array size is used for Apodization
//	int frames = 121;
//	int num_frames = 121;					// number of low resolution images
//	int skip_frames = 1;					// 
//	int dBvalue = 60;
//	float rximg[128 * 2040];
//	int croppedBot = 300;
//	//float* filt_coeff = new float[364];
//	//float* d_z_axis = 0;
//	//float* d_x_axis = 0;
//	//float* d_probe = 0;
//	//float* d_rx_aperture = 0;
//	//float* d_rx_ap_distance = 0;
//	//float* d_cen_pos = 0;
//	//float* d_data = 0;   // variable to store raw rf data
//	//float* d_bfHR = 0;  // variable to store beamformed high-resolution beamformed image 
//	//float* d_tx_delay = 0;
//	//float* d_rx_delay = 0;// delay calculation
//	//float* d_rx_apod = 0; //apodization
//	//float* d_filt_coeff = 0; //to read filter coeff CSV
//	//float* d_bfHRBP = 0;  // variable to store beamformed high-resolution bandpass filtered data
//	//float* dev_beamformed_data1 = 0;   // variable to store reshaped beamformed data
//	//float* env = new float[pixels]; // Host memory variable to store beamformed high-resolution bandpass filtered data
//	//float* d_theta = 0;
//	//float* d_theta1 = 0;
//	//float* d_theta_tx = 0;
//
//	USBDevice = new CCyUSBDevice(NULL);
//	// Obtain the control endpoint pointer
//	ept = USBDevice->ControlEndPt;
//	if (!ept) {
//		printf("Could not get Control endpoint.\n");
//		//return 1;
//	}
//
//}

int cudaBackEnd::num_threads = 0;
float cudaBackEnd::rx_f_number = 0;
float cudaBackEnd::PI = 0;
int cudaBackEnd::samples = 0;						// # of samples in depth direction
int cudaBackEnd::N_elements = 0;						// # of transducer elements
float cudaBackEnd::sampling_frequency = 0;			// sampling frequency
float cudaBackEnd::c = 0;							// speed of sound [m/s]	
int cudaBackEnd::N_active = 0;							// Active transmit elmeents
float cudaBackEnd::pitch = 0;				// spacing between the elements
float cudaBackEnd::aper_len = 0;	//aperture foot print 
float cudaBackEnd::zd = 0;			// virtual src distance from transducer array 
float cudaBackEnd::sample_spacing = 0;
float cudaBackEnd::del_convert = 0;			// used in delay calculation
float cudaBackEnd::rc = 0;					// radius_of_curvature
float cudaBackEnd::scan_angle = 0;
int cudaBackEnd::channels = 0;						// number of A-lines data used for beamforming
int cudaBackEnd::Nx = 0;								// 256 Lateral spacing
int cudaBackEnd::Nz = 0;								//1024 Axial spacing
int cudaBackEnd::pixels = 0;
int cudaBackEnd::pix_cha = 0;			// Nz*Nx*128 This array size is used for Apodization
int cudaBackEnd::frames = 0;
int cudaBackEnd::num_frames = 0;						// number of low resolution images
int cudaBackEnd::skip_frames = 0;						// 
int cudaBackEnd::dBvalue = 0;

float* cudaBackEnd::filt_coeff = new float[364];
//float* cudaBackEnd::env = new float[cudaBackEnd::pixels];
float* cudaBackEnd::env = 0;
float* cudaBackEnd::rximg2 = 0;
float* cudaBackEnd::d_filt_coeff = 0;
float* cudaBackEnd::d_z_axis = 0;
float* cudaBackEnd::d_x_axis = 0;
float* cudaBackEnd::d_probe = 0;
float* cudaBackEnd::d_rx_aperture = 0;
float* cudaBackEnd::d_rx_ap_distance = 0;
float* cudaBackEnd::d_cen_pos = 0;
float* cudaBackEnd::d_data = 0;
float* cudaBackEnd::d_bfHR = 0;
float* cudaBackEnd::d_tx_delay = 0;
float* cudaBackEnd::d_rx_delay = 0;
float* cudaBackEnd::d_rx_apod = 0;
float* cudaBackEnd::d_bfHRBP = 0;
float* cudaBackEnd::dev_beamformed_data1 = 0;
//** for curveLiner Prob  **//
float* cudaBackEnd::d_theta = 0;
float* cudaBackEnd::d_theta1 = 0;
float* cudaBackEnd::d_theta_tx = 0;
float cudaBackEnd::rximg[128 * 2040] = { 0 };
FILE* cudaBackEnd::fp = 0;
// for envelop detcetion
//------------------------

float cudaBackEnd::log_c = 20.0;
float* cudaBackEnd::d_envelop;
float* cudaBackEnd::d_logComp;
// init the cufft handles here
int cudaBackEnd::NBK1 = 0;
int cudaBackEnd::NBK2 = 0;
int cudaBackEnd::NBK3 = 0;
int cudaBackEnd::BKZ1 = 0;
int cudaBackEnd::BKZ2 = 0;
int cudaBackEnd::BKZ3 = 0; // declared in function calculateThreads

//dim3 cudaBackEnd::BKZ = 0;
cufftHandle cudaBackEnd::plan;
cudaStream_t cudaBackEnd::stream;
float* cudaBackEnd::d_xflat = 0;
float* cudaBackEnd::d_ifftI = 0;
float* cudaBackEnd::d_ifftR = 0;
cufftComplex* cudaBackEnd::d_xflatComplex=0;
cufftComplex* cudaBackEnd::d_fftComplex=0;
cufftComplex* cudaBackEnd::d_ifftComplex=0;
cufftComplex* cudaBackEnd::xflatComplex=0;
cufftComplex* cudaBackEnd::fftComplex=0;
cufftComplex* cudaBackEnd::ifftComplex=0;


std::ofstream cudaBackEnd::cudaLog("sample_output/cudaLog_file.txt", std::ofstream::out);
//std::ofstream cudaBackEnd::cudaLog.open("sample_output/cudaLog_file.txt");
const char* log_file_path = "cudaLog_file.txt";

CCyUSBDevice* cudaBackEnd::USBDevice = new CCyUSBDevice(NULL);
CCyControlEndPoint* cudaBackEnd::ept = cudaBackEnd::USBDevice->ControlEndPt;
CCyBulkEndPoint* cudaBackEnd::ept_in = cudaBackEnd::USBDevice->BulkInEndPt;


//void cudaDisplay::init(int rows, int cols) {
//
//	// init the cufft handles here
//	NBK = cols;
//	BKZ = dim3(rows);
//	cufftPlan2d(&plan, cols, rows, CUFFT_C2C);
//
//	cudaMalloc((void**)&d_xflat, sizeof(float) * rows * cols);
//	cudaMalloc((void**)&d_ifftI, sizeof(float) * rows * cols);
//	cudaMalloc((void**)&d_ifftR, sizeof(float) * rows * cols);
//	//cudaMalloc((void**)&d_envelop, sizeof(float) * rows * cols);
//	//cudaMalloc((void**)&d_logComp, sizeof(float) * rows * cols);
//
//	xflatComplex = new cufftComplex[rows * cols];
//	fftComplex = new cufftComplex[rows * cols];
//	ifftComplex = new cufftComplex[rows * cols];
//	cudaMalloc((void**)&d_fftComplex, sizeof(cufftComplex) * rows * cols);
//	cudaMalloc((void**)&d_ifftComplex, sizeof(cufftComplex) * rows * cols);
//	cudaMalloc((void**)&d_xflatComplex, sizeof(cufftComplex) * rows * cols);
//}
//
//void cudaDisplay::fetchEnvolep(float* d_inImg, float* d_envelop, int rows, int cols) {
//	// calculate the hilber transform here
//
//	real2complex << <NBK, BKZ >> > (d_inImg, d_xflatComplex);
//	cufftExecC2C(plan, d_xflatComplex, d_fftComplex, CUFFT_FORWARD);
//	cufftExecC2C(plan, d_fftComplex, d_ifftComplex, CUFFT_INVERSE);
//	// convert t real and imaginary parts
//	splitComplex << <NBK, BKZ >> > (d_ifftComplex, d_ifftR, d_ifftI);
//	scalarMult << <NBK, BKZ >> > (d_ifftI, d_ifftI, (float)(1.0 / rows));
//	magnitide << <NBK, BKZ >> > (d_inImg, d_ifftI, d_envelop);
//}
//
//void cudaDisplay::logTransform(float* d_inImg, float* d_logComp, float c, float rows, float cols) {
//	// Performing the log transformation to the image to make it enhanced
//	// d_envelop is from previous function
//	logCompresion << <NBK, BKZ >> > (d_inImg, d_logComp, c);
//	//cudaMemcpy(outImg, d_envelop, sizeof(float) * rows * cols, cudaMemcpyDeviceToHost);
//}


void cudaBackEnd::wait(unsigned timeout)
{
	timeout += std::clock();
	while (std::clock() < timeout) continue;
}

void cudaBackEnd::write_rows(CCyControlEndPoint* ept, unsigned char* ptr, unsigned int numRows)
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

bool cudaBackEnd::read_chunk(CCyBulkEndPoint* ept_in, unsigned char* recvBuf, LONG& length)
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

int cudaBackEnd::insert_row(unsigned char* buf, int row, short addr, int data)
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

void cudaBackEnd::read_csv_mat(float* data, char* filename, int col1)
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

void cudaBackEnd::read_csv_mat(long double* data, char* filename, int col1)
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

void cudaBackEnd::read_csv_array(float* data, char* filename)
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

void cudaBackEnd::zeroC(float* bfHR, int pixels)
{
	for (int j = 0; j < pixels; j++)
	{
		bfHR[j] = 0;
	}
}

void cudaBackEnd::onesC(float* bfHR, int pixels)
{
	for (int j = 0; j < pixels; j++)
	{
		bfHR[j] = 1.10;
	}
}

//** <Curvilinear Prob> **//

void cudaBackEnd::csv_write_mat(long double* a, const char* filename, int row1, int col1)		//writes data to memory
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

void cudaBackEnd::csv_write_mat(double* a, const char* filename, int row1, int col1)		//writes data to memory
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

void cudaBackEnd::csv_write_mat(float* a, const char* filename, int row1, int col1)	//for writing integer data "FUNCTION OVERLOADING"
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

float** cudaBackEnd::convertsingto2darray(float* imgArray, int rows, int cols) {

	float** array2D = (float**)malloc(rows * sizeof(float*));
	for (int i = 0; i < rows; i++) {
		array2D[i] = (float*)malloc(cols * sizeof(float));
	}

	for (int i = 0; i < rows; i++) {
		for (int j = 0; j < cols; j++) {
			array2D[i][j] = (float)imgArray[i * cols + j];
		}
	}

	return array2D;
}

//int cudaBackEnd::num_threads = 1024;
//float cudaBackEnd::rx_f_number = 2.0;
//float cudaBackEnd::PI = 3.14;
//int cudaBackEnd::samples = 2040;						// # of samples in depth direction
//int cudaBackEnd::N_elements = 128;						// # of transducer elements
//float cudaBackEnd::sampling_frequency = 32e6;			// sampling frequency
//float cudaBackEnd::c = 1540.0;							// speed of sound [m/s]	
//int cudaBackEnd::N_active = 8;							// Active transmit elmeents
//float cudaBackEnd::pitch = 0.465 / 1000;				// spacing between the elements
//float cudaBackEnd::aper_len = (N_elements - 1) * pitch * 1000;	//aperture foot print 
//float cudaBackEnd::zd = pitch * N_active / (float)2;			// virtual src distance from transducer array 
//float cudaBackEnd::sample_spacing = c / sampling_frequency / (float)2;
//float cudaBackEnd::del_convert = sampling_frequency / c;			// used in delay calculation
//float cudaBackEnd::rc = 60.1 / 1000;					// radius_of_curvature
//float cudaBackEnd::scan_angle = (58 * PI) / 180;
//int cudaBackEnd::channels = 128;						// number of A-lines data used for beamforming
//int cudaBackEnd::Nx = 256;								// 256 Lateral spacing
//int cudaBackEnd::Nz = 1024;								//1024 Axial spacing
//int cudaBackEnd::pixels = Nz * Nx;
//int cudaBackEnd::pix_cha = pixels * channels;			// Nz*Nx*128 This array size is used for Apodization
//int cudaBackEnd::frames = 121;
//int cudaBackEnd::num_frames = 121;						// number of low resolution images
//int cudaBackEnd::skip_frames = 1;						// 
//int cudaBackEnd::dBvalue = 60;

//// constructor
//cudaBackEnd::cudaBackEnd() {
//
//	cudaBackEnd::cudaLog->open(log_file_path);
//
//}
//
//// destructor
//cudaBackEnd::~cudaBackEnd() {
//
//	cudaBackEnd::cudaLog->close();
//
//}

int cudaBackEnd::initHW(bool debug)
{
	//cudaBackEnd::USBDevice = new CCyUSBDevice(NULL);
	//cudaBackEnd::ept = cudaBackEnd::USBDevice->ControlEndPt;
	//cudaBackEnd::ept_in = cudaBackEnd::USBDevice->BulkInEndPt;
	//cudaBackEnd::cudaLog.open("sample_output/cudaLog_file.txt");

	if (debug)
		cudaBackEnd::cudaLog << "initHW start " << std::endl;

	if (!cudaBackEnd::ept) {
		//printf("Could not get Control endpoint.\n");
		if (debug)
			cudaBackEnd::cudaLog << "Error : Could not get Control endpoint " << std::endl;
		return 3;
	}

	if (!cudaBackEnd::ept_in) {
		if (debug)
			cudaBackEnd::cudaLog << "Error : No IN endpoint " << std::endl;
		//printf("No IN endpoint??\n");
		return 4;
	}

	// Send a vendor request (bRequest = 0x05) to the device
	cudaBackEnd::ept->Target = TGT_DEVICE;
	cudaBackEnd::ept->ReqType = REQ_VENDOR;
	cudaBackEnd::ept->Direction = DIR_TO_DEVICE;
	cudaBackEnd::ept->ReqCode = 0x05;
	cudaBackEnd::ept->Value = 1;
	cudaBackEnd::ept->Index = 0;
	cudaBackEnd::ept->TimeOut = 100;				// set timeout to 100ms for quick response
	cudaBackEnd::ept_in->MaxPktSize = 16384;
	cudaBackEnd::ept_in->TimeOut = 100;			// set timeout to 100ms for readin

	//std::ofstream mFile;
	//mFile.open("sample_output/initHW.txt");
	//mFile << "H/w init done" << std::endl;
	//mFile.close();

	if (debug)
		cudaBackEnd::cudaLog << "initHW sucessfull1 " << std::endl;

	return 0;
}

int cudaBackEnd::initcudaFFT() {

	//cudaBackEnd::cudaDisplayHandle->init(rows, cols);

	return 0;

}

int cudaBackEnd::initSettingFile(const char* path, bool debug)
{
	static int call_cout = 0;
	errno_t err;
	//FILE* fp;
	// path = "out25_curvi.txt"; for curvilieanr prob
	if ((err = fopen_s(&cudaBackEnd::fp, path, "r")) != 0) {
		if (debug)
			cudaBackEnd::cudaLog << "Could not open config file for reading " << std::endl;
		//printf("Could not open config file for reading.\n");
		return 5;
	}

	//std::ofstream mFile;
	//mFile.open("sample_output/setting.txt");
	//mFile << "setting file rEADING  done" << std::endl;
	//mFile.close();

	if (debug && call_cout == 0)
		cudaBackEnd::cudaLog << "Setting file Reading  done " << std::endl;

	call_cout++;
	return 0;
}

int cudaBackEnd::initGPUprobeC(double* probPrms, bool debug) {

	const int MASK_WIDTH = 364;

	if (debug)
		cudaBackEnd::cudaLog << "CUDA memmory init starting " << std::endl;

	try {
		cudaBackEnd::PI = (float)probPrms[3];
		//cudaBackEnd::MASK_WIDTH		= (int)probPrms[4];// mFile2 << MASK_WIDTH << std::endl;
		//cudaBackEnd::TILE_SIZE		= (int)probPrms[5]; //mFile2 << TILE_SIZE << std::endl;
		cudaBackEnd::num_threads = (int)probPrms[6];
		cudaBackEnd::rx_f_number = (float)probPrms[7];
		cudaBackEnd::samples = (int)probPrms[8];
		cudaBackEnd::N_elements = (int)probPrms[9];
		cudaBackEnd::sampling_frequency = (float)probPrms[10];
		cudaBackEnd::c = (float)probPrms[11];
		cudaBackEnd::N_active = (int)probPrms[12];
		cudaBackEnd::channels = (int)probPrms[13];
		cudaBackEnd::Nx = (int)probPrms[14];
		cudaBackEnd::Nz = (int)probPrms[15];
		cudaBackEnd::frames = (int)probPrms[16];
		cudaBackEnd::num_frames = (int)probPrms[17];
		cudaBackEnd::skip_frames = (int)probPrms[18];
		cudaBackEnd::dBvalue = (int)probPrms[19];
		cudaBackEnd::pitch = (float)probPrms[20];
		cudaBackEnd::aper_len = (float)probPrms[21];
		cudaBackEnd::zd = (float)probPrms[22];
		cudaBackEnd::sample_spacing = (float)probPrms[23];
		cudaBackEnd::del_convert = (float)probPrms[24];
		cudaBackEnd::rc = (float)probPrms[25];
		cudaBackEnd::scan_angle = (float)probPrms[26];
		cudaBackEnd::pixels = (int)probPrms[27];
		cudaBackEnd::pix_cha = (int)probPrms[28];
	}
	catch (std::exception& e) {
		return 6;
	}


	if (debug)
	{
		cudaBackEnd::cudaLog << "PI : " << PI << std::endl;
		cudaBackEnd::cudaLog << "rx_f_number : " << rx_f_number << std::endl;
		cudaBackEnd::cudaLog << "samples : " << samples << std::endl;
		cudaBackEnd::cudaLog << "N_elements : " << N_elements << std::endl;
		cudaBackEnd::cudaLog << "sampling_frequency : " << sampling_frequency << std::endl;
		cudaBackEnd::cudaLog << "c : " << c << std::endl;
		cudaBackEnd::cudaLog << "N_active : " << N_active << std::endl;
		cudaBackEnd::cudaLog << "channels : " << channels << std::endl;
		cudaBackEnd::cudaLog << "Nx : " << Nx << std::endl;
		cudaBackEnd::cudaLog << "Nz : " << Nz << std::endl;
		cudaBackEnd::cudaLog << "frames : " << frames << std::endl;
		cudaBackEnd::cudaLog << "num_frames : " << num_frames << std::endl;
		cudaBackEnd::cudaLog << "skip_frames : " << skip_frames << std::endl;
		cudaBackEnd::cudaLog << "dBvalue : " << dBvalue << std::endl;
		cudaBackEnd::cudaLog << "pitch : " << pitch << std::endl;
		cudaBackEnd::cudaLog << "aper_len : " << aper_len << std::endl;
		cudaBackEnd::cudaLog << "zd : " << zd << std::endl;
		cudaBackEnd::cudaLog << "sample_spacing : " << sample_spacing << std::endl;
		cudaBackEnd::cudaLog << "del_convert : " << del_convert << std::endl;
		cudaBackEnd::cudaLog << "rc : " << rc << std::endl;
		cudaBackEnd::cudaLog << "scan_angle : " << scan_angle << std::endl;
		cudaBackEnd::cudaLog << "pixels : " << pixels << std::endl;
		cudaBackEnd::cudaLog << "pix_cha : " << pix_cha << std::endl;
		cudaBackEnd::cudaLog << "param reading done " << std::endl;
	}


	try
	{
		cudaBackEnd::env = new float[cudaBackEnd::pixels];
		zeroC(cudaBackEnd::rximg, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.

		char filename1[200];
		sprintf(filename1, "b_10M.csv");
		cudaBackEnd::read_csv_array(cudaBackEnd::filt_coeff, filename1);    // csv file read

		//float* d_filt_coeff = 0;
		cudaMalloc((void**)&cudaBackEnd::d_filt_coeff, sizeof(float) * MASK_WIDTH);
		cudaMemcpy(cudaBackEnd::d_filt_coeff, filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);

		////////  Intialization &(or) Memory allocation  //////////////////
		//float* d_data = 0;   // variable to store raw rf data
		cudaMalloc((void**)&cudaBackEnd::d_data, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels);

		//float* d_bfHR = 0;  // variable to store beamformed high-resolution beamformed image 
		cudaMalloc((void**)&cudaBackEnd::d_bfHR, cudaBackEnd::pixels * sizeof(float));
		//zeros << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);  
		cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));

		//float* dev_beamformed_data1 = 0;   // variable to store reshaped beamformed data
		cudaMalloc((void**)&cudaBackEnd::dev_beamformed_data1, cudaBackEnd::pixels * sizeof(float));

		//float* d_bfHRBP = 0;  // variable to store beamformed high-resolution bandpass filtered data
		cudaMalloc((void**)&cudaBackEnd::d_bfHRBP, sizeof(float) * cudaBackEnd::pixels);

		/////////////////// theta positions for all elements ////////////////////
		//float* d_theta = 0;
		cudaMalloc((void**)&cudaBackEnd::d_theta, cudaBackEnd::N_elements * sizeof(float));
		range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta, (-cudaBackEnd::scan_angle / 2), cudaBackEnd::N_elements, (cudaBackEnd::scan_angle / (cudaBackEnd::N_elements - 1)));


		///////////// theta for grid /////////////////  theta = -scan_angle / 2 : scan_angle / (elements - 1) : scan_angle / 2;
		//float* d_theta1 = 0;
		cudaMalloc((void**)&cudaBackEnd::d_theta1, cudaBackEnd::Nx * sizeof(float));
		range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta1, (-cudaBackEnd::scan_angle / 2), cudaBackEnd::Nx, (cudaBackEnd::scan_angle / (cudaBackEnd::Nx - 1)));
		cudaGetLastError();
		cudaDeviceSynchronize();

		////////////// z value////////////////////
		float dz = cudaBackEnd::sample_spacing * cudaBackEnd::samples / cudaBackEnd::Nz;  // depth / (Nz - 1) / 1000;   // spacing in axial (z) direction in mm;
		//float* d_z_axis = 0;
		cudaMalloc((void**)&cudaBackEnd::d_z_axis, cudaBackEnd::Nz * sizeof(float));
		range << <cudaBackEnd::Nz / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_z_axis, 0, cudaBackEnd::Nz, dz);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////////////////////////// x value////////////////////////////////
		float dx = aper_len / (Nx - 1);
		//float* d_x_axis = 0;
		cudaMalloc((void**)&cudaBackEnd::d_x_axis, cudaBackEnd::Nx * sizeof(float));
		range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, (-cudaBackEnd::aper_len / 2000), cudaBackEnd::Nx, dx / 1000);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////////// Probe geometry, this info can be taken from transducer file ////////////////////
		//float* d_probe = 0;
		cudaMalloc((void**)&cudaBackEnd::d_probe, cudaBackEnd::N_elements * sizeof(float));
		//cudaMemcpy(d_probe, probe_ge_x, N_elements * sizeof(double), cudaMemcpyHostToDevice);
		range << <1, cudaBackEnd::N_elements >> > (cudaBackEnd::d_probe, (-cudaBackEnd::aper_len / 2000), cudaBackEnd::N_elements, cudaBackEnd::pitch);
		cudaGetLastError();
		cudaDeviceSynchronize();

		/////////////////rx aerture calculation using Fnumber///////////////////////////////
		// rx_aper=rfsca.z/rf_number
		//float* d_rx_aperture = 0;
		cudaMalloc((void**)&cudaBackEnd::d_rx_aperture, cudaBackEnd::Nz * sizeof(float));
		element_division << <cudaBackEnd::Nz / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_z_axis, cudaBackEnd::rx_f_number, cudaBackEnd::Nz, cudaBackEnd::d_rx_aperture);
		cudaGetLastError();
		cudaDeviceSynchronize();

		////////////////////////rx aerture distance////////
		//float* d_rx_ap_distance = 0;
		cudaMalloc((void**)&cudaBackEnd::d_rx_ap_distance, cudaBackEnd::channels * cudaBackEnd::Nx * sizeof(float));  //20.087 us
		aperture_distance << <cudaBackEnd::Nx * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, cudaBackEnd::d_probe, cudaBackEnd::Nx, cudaBackEnd::channels, cudaBackEnd::d_rx_ap_distance);
		cudaGetLastError();
		cudaDeviceSynchronize();

		///////////////////apodization/////////////////
		//float* d_rx_apod = 0;
		cudaMalloc((void**)&cudaBackEnd::d_rx_apod, sizeof(float) * cudaBackEnd::Nz * cudaBackEnd::channels * cudaBackEnd::Nx);
		apodization << <cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_rx_ap_distance, cudaBackEnd::d_rx_aperture, cudaBackEnd::Nz, cudaBackEnd::Nx, cudaBackEnd::channels, cudaBackEnd::pixels, cudaBackEnd::d_rx_apod);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//// check for nan values,
		isnan_test_array << <cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_rx_apod, cudaBackEnd::pixels * cudaBackEnd::channels);
		cudaGetLastError();
		cudaDeviceSynchronize();

		cudaFree(cudaBackEnd::d_rx_aperture);
		cudaFree(cudaBackEnd::d_rx_ap_distance);

		/////////////receive delay calculation /////////////////////////////////////////////
		//float* d_rx_delay = 0;
		cudaMalloc((void**)&cudaBackEnd::d_rx_delay, cudaBackEnd::pix_cha * sizeof(float));
		receive_delay << < cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta, cudaBackEnd::d_theta1, cudaBackEnd::rc, cudaBackEnd::d_z_axis, cudaBackEnd::channels, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::d_rx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();

		/////////////////// theta positions for all elements ////////////////////
		//float* d_theta_tx = 0;
		cudaMalloc((void**)&cudaBackEnd::d_theta_tx, cudaBackEnd::num_frames * sizeof(float));
		theta1 << < 1, cudaBackEnd::num_frames >> > (cudaBackEnd::d_theta_tx, cudaBackEnd::d_theta, cudaBackEnd::frames, cudaBackEnd::N_active, cudaBackEnd::skip_frames);

		/////////////////// Transmit delay calculation ////////////////////
		//float* d_tx_delay = 0;
		cudaMalloc((void**)&cudaBackEnd::d_tx_delay, cudaBackEnd::pixels * cudaBackEnd::num_frames * sizeof(float));
		//transmitter delay for 16 frames,  
		transmit_delay << < cudaBackEnd::pixels * cudaBackEnd::num_frames / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta1, cudaBackEnd::d_z_axis, cudaBackEnd::rc, cudaBackEnd::d_theta_tx, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::num_frames, cudaBackEnd::zd, cudaBackEnd::d_tx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();

		if (debug)
			cudaBackEnd::cudaLog << "CUDA memmory allocation completed succefully " << std::endl;
	}
	catch (std::exception& e) {
		return 7;
	}

	cudaFree(cudaBackEnd::d_theta1);
	cudaFree(cudaBackEnd::d_probe);
	cudaFree(cudaBackEnd::d_x_axis);
	cudaFree(cudaBackEnd::d_z_axis);
	cudaFree(cudaBackEnd::d_theta_tx);

	return 0;
}

float** cudaBackEnd::computeBModeImgDev(bool debug) {

	const int MAX_LINE = 256;
	const int N_RX = 64;
	unsigned char buf[16 * 1024];
	static int call_count = 0; // parms counts the number of time this function calls

	if (debug && call_count == 0)
		cudaBackEnd::cudaLog << "b_mode image generation starts " << std::endl;

	//-----------------------
	int ok = cudaBackEnd::initSettingFile("out25.txt");
	//-----------------------

	char line[MAX_LINE]; // Max possible line length?
	int iteration = 0;
	int errcount = 0;
	int row = 0;					// Keep track of how many rows have been added
	unsigned int addr, data;
	unsigned char recvbuf[2048 * N_RX * 2];
	const int MAXROWS = 2040;
	LONG rxlen = MAXROWS * N_RX * 2;
	//cudaBackEnd::env = new float[cudaBackEnd::pixels];

	if (debug && call_count == 0)
		cudaBackEnd::cudaLog << "setting file reading done " << std::endl;

	try
	{
		//unsigned int start = clock();
		while (fgets(line, cudaBackEnd::MAX_LINE, cudaBackEnd::fp))
		{
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
			else if (line[0] == 'C') {  // CAPTURE STARTS
				//wait(100);
				row = insert_row(buf, row, 0x4, 0x01);
				//write_rows(ept, buf, row);  // Send commands
				//wait(100);
				row = insert_row(buf, row, 0x4, 0x10);
				//write_rows(ept, buf, row);  // Send commands
				//wait(100);
				row = insert_row(buf, row, 0x4, 0x00);

				cudaBackEnd::ept_in->Abort();
				cudaBackEnd::ept_in->Reset();

				write_rows(cudaBackEnd::ept, buf, row);  // Send commands

				wait(1);
				if (read_chunk(cudaBackEnd::ept_in, recvbuf, rxlen)) {
					short* rxdata = (short*)(recvbuf);
					for (int i = 0; i < rxlen / 2; i++) {
						if (rxdata[i] >= 512) rxdata[i] -= 1024;
					}
					// Trying to read only first N-1 rows and discard 1st sample
					for (int i = 0; i < N_RX; i++) {
						for (int j = 0; j < MAXROWS - 1; j++) {
							//rximg[iteration][i][j] = rxdata[j*64+i+2];
							if (iteration < 29) {      // start from 0 index, so 30-1 
								cudaBackEnd::rximg[i * MAXROWS + j] = rxdata[j * N_RX + i + 2];
							}
							else if (iteration > 91) {
								cudaBackEnd::rximg[(i + 64) * MAXROWS + j] = rxdata[j * N_RX + i + 2];
							}
							else {
								cudaBackEnd::rximg[(i + iteration - 28) * MAXROWS + j] = rxdata[j * N_RX + i + 2];
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

				cudaMemcpy(cudaBackEnd::d_data, cudaBackEnd::rximg, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels, cudaMemcpyHostToDevice);

				beamformingLR3 << <(cudaBackEnd::pixels / 256) * cudaBackEnd::channels, 256 >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_tx_delay, cudaBackEnd::d_rx_delay, cudaBackEnd::d_data, cudaBackEnd::d_rx_apod, cudaBackEnd::samples, cudaBackEnd::pixels, iteration, cudaBackEnd::num_frames, cudaBackEnd::channels);
				cudaGetLastError();
				cudaDeviceSynchronize();

				iteration++;	// Increment iteration after saving to image
				row = 0;		// Reset buffer for next iteration
			}
			else {
				if (debug) {
					cudaBackEnd::cudaLog << "Error : Don't know how to handle [%s] yet " << std::endl;
					cudaBackEnd::cudaLog << line << std::endl;

				}
				return nullptr;
			}


		}
		// while loop completed
		if (debug && call_count == 0)
			cudaBackEnd::cudaLog << "while loop completed " << std::endl;


	}
	catch (std::exception& e)
	{
		return nullptr;
	}

	try
	{
		//////////// Bandpass filtering using shared memory /////////////////////
		BPfilter1SharedMem << <(cudaBackEnd::pixels + cudaBackEnd::TILE_SIZE - 1) / cudaBackEnd::TILE_SIZE, cudaBackEnd::TILE_SIZE >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_filt_coeff, cudaBackEnd::pixels, cudaBackEnd::d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();

		if (debug && call_count == 0)
			cudaBackEnd::cudaLog << "BPF done" << std::endl;

		//////////////// reshape of the beamformed data ///////////////
		reshape_columnwise << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();
		cudaMemcpy(cudaBackEnd::env, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);

		if (debug && call_count == 0)
		{
			char fileout[200];
			sprintf(fileout, "sample_output/b_curve_mode.csv"); //all the 16 inputs are arranged in a single file
			csv_write_mat(cudaBackEnd::env, fileout, cudaBackEnd::Nz, cudaBackEnd::Nx);
			cudaBackEnd::cudaLog << "Copy to host completed" << std::endl;
		}



	}
	catch (std::exception& e)
	{
		return nullptr;

	}

	float** outArray = convertsingto2darray(cudaBackEnd::env, cudaBackEnd::Nz, cudaBackEnd::Nx);

	if (debug && call_count == 0)
	{
		cudaBackEnd::cudaLog << "First image capture completed" << std::endl;
		cudaBackEnd::cudaLog.close();
	}


	// For next iteration
	//cudaMalloc((void**)&cudaBackEnd::d_data, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels);
	//cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));
	//cudaMemset(cudaBackEnd::dev_beamformed_data1, 0, cudaBackEnd::pixels * sizeof(float));
	zeroC(cudaBackEnd::rximg, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
	call_count++;

	return outArray;

}

int cudaBackEnd::initGPUprobeL(double* prob_params, bool debug)
{
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

	if (debug)
		cudaBackEnd::cudaLog << "CUDA memm init for linear prob starts " << std::endl;

	// perform b-mode generation here using cuda
	const int TILE_SIZE = prob_params[0];
	int MASK_WIDTH = prob_params[1];
	const int MAX_LINE = prob_params[2];


	try {
		cudaBackEnd::num_threads = prob_params[3];
		cudaBackEnd::rx_f_number = prob_params[4];	// Apodization parameters
		cudaBackEnd::samples = prob_params[5];	// # of samples in depth direction
		cudaBackEnd::N_elements = prob_params[6];	// # of transducer elements
		cudaBackEnd::sampling_frequency = prob_params[7];   // sampling frequency
		cudaBackEnd::c = prob_params[8];	// speed of sound [m/s]	
		cudaBackEnd::N_active = prob_params[9];   // Active transmit elmeents
		cudaBackEnd::pitch = prob_params[10];	// spacing between the elements
		cudaBackEnd::aper_len = prob_params[11];  // aperture foot print 
		cudaBackEnd::zd = prob_params[12];  // virtual src distance from transducer array 
		cudaBackEnd::sample_spacing = prob_params[13];
		cudaBackEnd::del_convert = prob_params[14];  // used in delay calculation
		cudaBackEnd::channels = prob_params[15];	// number of A-lines data used for beamforming
		cudaBackEnd::Nx = prob_params[16];	// 256 Lateral spacing Beamforming "Grid" parameters
		cudaBackEnd::Nz = prob_params[17];	// 1024 Axial spacing
		cudaBackEnd::pixels = prob_params[18];
		cudaBackEnd::pix_cha = prob_params[19];	// Nz*Nx*128 This array size is used for Apodization
		cudaBackEnd::num_frames = prob_params[20];	// number of low resolution images
		cudaBackEnd::skip_frames = prob_params[21];	//
	}
	catch (std::exception& e) {
		return 8;
	}

	if (debug)
	{
		cudaBackEnd::cudaLog << "num_threads : " << prob_params[3] << std::endl;
		cudaBackEnd::cudaLog << "rx_f_number : " << prob_params[4] << std::endl;
		cudaBackEnd::cudaLog << "samples : " << prob_params[5] << std::endl;
		cudaBackEnd::cudaLog << "N_elements : " << prob_params[6] << std::endl;
		cudaBackEnd::cudaLog << "sampling_frequency : " << prob_params[7] << std::endl;
		cudaBackEnd::cudaLog << "c : " << prob_params[8] << std::endl;
		cudaBackEnd::cudaLog << "N_active : " << prob_params[9] << std::endl;
		cudaBackEnd::cudaLog << "pitch : " << prob_params[10] << std::endl;
		cudaBackEnd::cudaLog << "aper_len : " << prob_params[11] << std::endl;
		cudaBackEnd::cudaLog << "zd : " << prob_params[12] << std::endl;
		cudaBackEnd::cudaLog << "sample_spacing : " << prob_params[13] << std::endl;
		cudaBackEnd::cudaLog << "del_convert : " << prob_params[14] << std::endl;
		cudaBackEnd::cudaLog << "channels : " << prob_params[15] << std::endl;
		cudaBackEnd::cudaLog << "Nx : " << prob_params[16] << std::endl;
		cudaBackEnd::cudaLog << "Nz : " << prob_params[17] << std::endl;
		cudaBackEnd::cudaLog << "pixels : " << prob_params[18] << std::endl;
		cudaBackEnd::cudaLog << "pix_cha : " << prob_params[19] << std::endl;
		cudaBackEnd::cudaLog << "num_frames : " << prob_params[20] << std::endl;
		cudaBackEnd::cudaLog << "skip_frames : " << prob_params[21] << std::endl;
	}

	try
	{
		char filename3[200];
		sprintf(filename3, "b_10M.csv");
		read_csv_array(cudaBackEnd::filt_coeff, filename3);    // csv file read
		//cv::imwrite("okMat3.png", testMat0);

		// float* d_filt_coeff = 0;
		cudaMalloc((void**)&cudaBackEnd::d_filt_coeff, sizeof(float) * MASK_WIDTH);
		cudaMemcpy(cudaBackEnd::d_filt_coeff, cudaBackEnd::filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);

		////////  Intialization &(or) Memory allocation  //////////////////
		cudaMalloc((void**)&cudaBackEnd::d_data, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels);// variable to store raw rf data

		cudaMalloc((void**)&cudaBackEnd::d_bfHR, cudaBackEnd::pixels * sizeof(float)); // variable to store beamformed high-resolution beamformed image 
		cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));

		cudaMalloc((void**)&cudaBackEnd::dev_beamformed_data1, cudaBackEnd::pixels * sizeof(float));// variable to store reshaped beamformed data

		cudaMalloc((void**)&cudaBackEnd::d_bfHRBP, sizeof(float) * cudaBackEnd::pixels);// variable to store beamformed high-resolution bandpass filtered data

		////////////// z value////////////////////
		float dz = sample_spacing * samples / Nz;  // depth / (Nz - 1) / 1000;   // spacing in axial (z) direction in mm;
		cudaMalloc((void**)&cudaBackEnd::d_z_axis, cudaBackEnd::Nz * sizeof(float));
		range << <cudaBackEnd::Nz / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_z_axis, 0, cudaBackEnd::Nz, dz);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////////////////////////// x value////////////////////////////////
		float dx = aper_len / (cudaBackEnd::Nx - 1);
		// float* d_x_axis = 0;
		cudaMalloc((void**)&cudaBackEnd::d_x_axis, cudaBackEnd::Nx * sizeof(float));    // 167.939 us
		range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, (-cudaBackEnd::aper_len / 2000), cudaBackEnd::Nx, dx / 1000);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////////// Probe geometry, this info can be taken from transducer file ////////////////////
		//float* d_probe = 0;
		cudaMalloc((void**)&cudaBackEnd::d_probe, cudaBackEnd::N_elements * sizeof(float));
		range << <1, cudaBackEnd::N_elements >> > (cudaBackEnd::d_probe, (-cudaBackEnd::aper_len / 2000), cudaBackEnd::N_elements, cudaBackEnd::pitch);
		cudaGetLastError();
		cudaDeviceSynchronize();

		/////////////////rx aerture calculation using Fnumber///////////////////////////////
		cudaMalloc((void**)&cudaBackEnd::d_rx_aperture, cudaBackEnd::Nz * sizeof(float));
		element_division << <cudaBackEnd::Nz / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_z_axis, cudaBackEnd::rx_f_number, cudaBackEnd::Nz, cudaBackEnd::d_rx_aperture);
		cudaGetLastError();
		cudaDeviceSynchronize();

		////////////////////////rx aerture distance////////
		cudaMalloc((void**)&cudaBackEnd::d_rx_ap_distance, cudaBackEnd::channels * cudaBackEnd::Nx * sizeof(float));
		aperture_distance << <cudaBackEnd::Nx * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, cudaBackEnd::d_probe, cudaBackEnd::Nx, cudaBackEnd::channels, cudaBackEnd::d_rx_ap_distance);
		cudaGetLastError();
		cudaDeviceSynchronize();

		///////////////////apodization/////////////////
		// float* d_rx_apod = 0;
		cudaMalloc((void**)&cudaBackEnd::d_rx_apod, sizeof(float) * cudaBackEnd::Nz * cudaBackEnd::channels * cudaBackEnd::Nx);
		apodization << <cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_rx_ap_distance, cudaBackEnd::d_rx_aperture, cudaBackEnd::Nz, cudaBackEnd::Nx, cudaBackEnd::channels, cudaBackEnd::pixels, cudaBackEnd::d_rx_apod);
		cudaGetLastError();
		cudaDeviceSynchronize();

		cudaFree(d_rx_aperture);
		cudaFree(d_rx_ap_distance);

		/////////////////// calculate central positions transmit subaperture ////////////////////
		cudaMalloc((void**)&cudaBackEnd::d_cen_pos, cudaBackEnd::num_frames * sizeof(float));
		Tx_cen_pos << < 1, cudaBackEnd::num_frames >> > (cudaBackEnd::d_cen_pos, cudaBackEnd::N_elements, cudaBackEnd::N_active, cudaBackEnd::pitch, cudaBackEnd::skip_frames, cudaBackEnd::num_frames, cudaBackEnd::d_probe);

		/////////////receive delay calculation /////////////////////////////////////////////
		cudaMalloc((void**)&cudaBackEnd::d_rx_delay, cudaBackEnd::pix_cha * sizeof(float));
		receive_delay << < cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_probe, cudaBackEnd::d_x_axis, cudaBackEnd::d_z_axis, cudaBackEnd::channels, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::d_rx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();

		/////////////////// Transmit delay calculation ////////////////////
		cudaMalloc((void**)&cudaBackEnd::d_tx_delay, cudaBackEnd::pixels * cudaBackEnd::num_frames * sizeof(float));
		transmit_delay << < cudaBackEnd::pixels * cudaBackEnd::num_frames / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, cudaBackEnd::d_z_axis, cudaBackEnd::d_cen_pos, cudaBackEnd::zd, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::num_frames, cudaBackEnd::d_tx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////// Host to device and back /////////
		//cudaBackEnd::env = new float[cudaBackEnd::pixels];
		//cudaBackEnd::rximg2 = new float[cudaBackEnd::N_elements * cudaBackEnd::samples];
		cudaMallocHost(&cudaBackEnd::env, sizeof(float)* cudaBackEnd::pixels);
		cudaMallocHost(&cudaBackEnd::rximg2, sizeof(float)* cudaBackEnd::pixels);
		
		/////////////////////////////////////////////////

		///////  for envelop detection /////////
		//cudaBackEnd::NBK = cudaBackEnd::Nx;
		//cudaBackEnd::BKZ = dim3(cudaBackEnd::Nz);
		cufftPlan2d(&cudaBackEnd::plan, cudaBackEnd::Nx, cudaBackEnd::Nz, CUFFT_C2C);
		cudaMalloc((void**)&cudaBackEnd::d_xflat, sizeof(float)* cudaBackEnd::Nz* cudaBackEnd::Nx);
		cudaMalloc((void**)&cudaBackEnd::d_ifftI, sizeof(float)* cudaBackEnd::Nz* cudaBackEnd::Nx);
		cudaMalloc((void**)&cudaBackEnd::d_ifftR, sizeof(float)* cudaBackEnd::Nz* cudaBackEnd::Nx);
		cudaMalloc((void**)&cudaBackEnd::d_logComp, sizeof(float)* cudaBackEnd::Nz* cudaBackEnd::Nx);
		cudaMalloc((void**)&cudaBackEnd::d_envelop, sizeof(float)* cudaBackEnd::Nz* cudaBackEnd::Nx);


		cudaBackEnd::xflatComplex = new cufftComplex[cudaBackEnd::Nz * cudaBackEnd::Nx];
		cudaBackEnd::fftComplex = new cufftComplex[cudaBackEnd::Nz * cudaBackEnd::Nx];
		cudaBackEnd::ifftComplex = new cufftComplex[cudaBackEnd::Nz * cudaBackEnd::Nx];
		cudaMalloc((void**)&cudaBackEnd::d_fftComplex, sizeof(cufftComplex)* cudaBackEnd::Nz* cudaBackEnd::Nx);
		cudaMalloc((void**)&cudaBackEnd::d_ifftComplex, sizeof(cufftComplex)* cudaBackEnd::Nz* cudaBackEnd::Nx);
		cudaMalloc((void**)&cudaBackEnd::d_xflatComplex, sizeof(cufftComplex)* cudaBackEnd::Nz* cudaBackEnd::Nx);

		cudaStreamCreateWithFlags(&cudaBackEnd::stream, cudaStreamNonBlocking);
	}
	catch (std::exception& c)
	{
		return 9;
	}


	////////////Free cuda memory (one time use) ///////////////////////////
	cudaFree(cudaBackEnd::d_probe);
	cudaFree(cudaBackEnd::d_x_axis);
	cudaFree(cudaBackEnd::d_z_axis);
	cudaFree(cudaBackEnd::d_cen_pos);

	if (debug)
		cudaBackEnd::cudaLog << "CUDA memm init for linear prob completed " << std::endl;

	return 0;

}

float** cudaBackEnd::computeBModeImgLinDiv(bool debug)
{
	static int call_count = 0;
	zeroC(cudaBackEnd::env, cudaBackEnd::Nx);   // set rx_img array values to zero.
	zeroC(cudaBackEnd::rximg2, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
	int ok = cudaBackEnd::initSettingFile("out25.txt");

	if (debug && call_count == 0)
		cudaBackEnd::cudaLog << "CUDA B-Mode for linear prob starts setting file read" << std::endl;

	int ok1 = cudaBackEnd::readAndBeamForm(debug);

	if (debug && call_count == 0 && ok1==0)
		cudaBackEnd::cudaLog << "CUDA B-Mode for linear prob while loop completed" << std::endl;
	//-------------------------------------------------------------------------------------


	int ok2 = cudaBackEnd::filterBeamForm(debug);
	if (debug && call_count == 0 && ok2 ==0)
		cudaBackEnd::cudaLog << " filterBeamForm completed " << std::endl;
	//-------------------------------------------------------------------------------------


	int ok3 = cudaBackEnd::envelopAndCompress(debug);
	if (debug && call_count == 0 && ok3 == 0)
		cudaBackEnd::cudaLog << " envelopAndCompress completed " << std::endl;
	//-------------------------------------------------------------------------------------


	float** outArray = convertsingto2darray(cudaBackEnd::env, cudaBackEnd::Nz, cudaBackEnd::Nx);
	if (debug && call_count <= 10){
		cudaBackEnd::cudaLog << " 1 Frame generation completed " << std::endl;
	}

	//// For next iteration
	cudaMemset(cudaBackEnd::d_bfHR, 0, pixels * sizeof(float));
	call_count++;

	return outArray;
}

///////// Divided functions /////////

int cudaBackEnd::readAndBeamForm(bool debug) {

	// perform b-mode generation here using cuda
	const int TILE_SIZE = 4;
	int MASK_WIDTH = 364;
	const int MAX_LINE = 256;
	static int call_count = 0;
	//---------------------------------------------------

	static double pix2 = 0.0;
	unsigned char buf[16 * 1024];
	int row = 0;  // Keep track of how many rows have been added
	char line[MAX_LINE]; // Max possible line length?
	int iteration = 0;
	int errcount = 0;
	unsigned int addr, data;
	unsigned char recvbuf[2048 * 64 * 2];
	const int MAXROWS = 2040;
	LONG rxlen = MAXROWS * 64 * 2;
	//-----------------------------------------------------
	//auto start_bmod = std::chrono::high_resolution_clock::now();
	try
	{
		// unsigned int start = clock();
		while (fgets(line, MAX_LINE, cudaBackEnd::fp)) {
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
				cudaBackEnd::ept_in->Abort();
				cudaBackEnd::ept_in->Reset();
				write_rows(cudaBackEnd::ept, buf, row);  // Send commands
				wait(1);
				if (read_chunk(cudaBackEnd::ept_in, recvbuf, rxlen)) {
					short* rxdata = (short*)(recvbuf);
					for (int i = 0; i < rxlen / 2; i++) {
						if (rxdata[i] >= 512) rxdata[i] -= 1024;
					}
					// Trying to read only first N-1 rows and discard 1st sample
					for (int i = 0; i < 64; i++) {
						for (int j = 0; j < MAXROWS - 1; j++) {
							//rximg[iteration][i][j] = rxdata[j*64+i+2];
							cudaBackEnd::rximg2[i * MAXROWS + j] = rxdata[j * 64 + i + 2];
						}
					}
					//saveToFile(iteration, rxlen, recvbuf);
				}
				else {
					errcount++;
				}
				//cudaMemcpy(cudaBackEnd::d_data, cudaBackEnd::rximg2, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels, cudaMemcpyHostToDevice);
				//beamformingLR3 << <(cudaBackEnd::pixels / 256) * cudaBackEnd::channels, 256 >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_tx_delay, cudaBackEnd::d_rx_delay, cudaBackEnd::d_data, cudaBackEnd::d_rx_apod, cudaBackEnd::samples, cudaBackEnd::pixels, iteration, cudaBackEnd::num_frames, cudaBackEnd::channels);
				//cudaGetLastError();
				//cudaDeviceSynchronize();

				cudaMemcpyAsync(cudaBackEnd::d_data, cudaBackEnd::rximg2, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels, 
					cudaMemcpyHostToDevice, cudaBackEnd::stream);

				//beamformingLR3 << <cudaBackEnd::NBK1, cudaBackEnd::BKZ1, 0, cudaBackEnd::stream >> > 
				//	(cudaBackEnd::d_bfHR, cudaBackEnd::d_tx_delay, cudaBackEnd::d_rx_delay, cudaBackEnd::d_data, cudaBackEnd::d_rx_apod,
				//	cudaBackEnd::samples, cudaBackEnd::pixels, iteration, cudaBackEnd::num_frames, cudaBackEnd::channels);

				beamformingLR3 << <(cudaBackEnd::pixels / 256) * cudaBackEnd::channels, 256, 0, cudaBackEnd::stream >> > (cudaBackEnd::d_bfHR,
					cudaBackEnd::d_tx_delay, cudaBackEnd::d_rx_delay, cudaBackEnd::d_data, cudaBackEnd::d_rx_apod, 
					cudaBackEnd::samples, cudaBackEnd::pixels, iteration, cudaBackEnd::num_frames, cudaBackEnd::channels);

				cudaGetLastError();
				cudaStreamSynchronize(cudaBackEnd::stream);

				iteration++; // Increment iteration after saving to image
				row = 0;   // Reset buffer for next iteration
			}
			else {
				printf("Don't know how to handle [%s] yet.\n", line);
			}
		}

	}
	catch (std::exception& e) {
		return 11;
	}

	return 0;
}

int cudaBackEnd::filterBeamForm(bool debug) {
	try
	{
		//// check for nan values,
		// isnan_test_array << <cudaBackEnd::BKZ3, NBK3, 0, cudaBackEnd::stream >> > (cudaBackEnd::d_bfHR, cudaBackEnd::pixels);
		isnan_test_array << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads, 0, cudaBackEnd::stream >> > (cudaBackEnd::d_bfHR, cudaBackEnd::pixels);
		cudaGetLastError();
		//cudaDeviceSynchronize();
		cudaStreamSynchronize(cudaBackEnd::stream);

		//////////// Bandpass filtering using shared memory /////////////////////
		// BPfilter1SharedMem << <(cudaBackEnd::pixels + TILE_SIZE - 1) / TILE_SIZE, TILE_SIZE, 0, cudaBackEnd::stream >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_filt_coeff, cudaBackEnd::pixels, cudaBackEnd::d_bfHRBP);
		BPfilter1SharedMem << <cudaBackEnd::NBK2, cudaBackEnd::BKZ2, 0, cudaBackEnd::stream >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_filt_coeff, cudaBackEnd::pixels, cudaBackEnd::d_bfHRBP);
		cudaGetLastError();
		//cudaDeviceSynchronize();
		cudaStreamSynchronize(cudaBackEnd::stream);

		//////////////// reshape of the beamformed data ///////////////
		// reshape_columnwise << <cudaBackEnd::BKZ3, NBK3, 0, cudaBackEnd::stream >> > (cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_bfHRBP);
		reshape_columnwise << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads, 0, cudaBackEnd::stream >> > (cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_bfHRBP);
		cudaGetLastError();
		//cudaDeviceSynchronize();
		cudaStreamSynchronize(cudaBackEnd::stream);
	}
	catch (std::exception& e)
	{
		return 12;
	}

	return 0;

}

int cudaBackEnd::envelopAndCompress(bool debug) {

	// Adding envelop detection and log compression
	//auto start_env = std::chrono::high_resolution_clock::now();
	real2complex << <cudaBackEnd::NBK3, cudaBackEnd::BKZ3, 0, cudaBackEnd::stream >> > (cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_xflatComplex);
	cudaGetLastError();
	cudaStreamSynchronize(cudaBackEnd::stream);
	cufftExecC2C(cudaBackEnd::plan, cudaBackEnd::d_xflatComplex, cudaBackEnd::d_fftComplex, CUFFT_FORWARD);
	cudaGetLastError();
	cudaStreamSynchronize(cudaBackEnd::stream);
	cufftExecC2C(cudaBackEnd::plan, cudaBackEnd::d_fftComplex, cudaBackEnd::d_ifftComplex, CUFFT_INVERSE);
	cudaGetLastError();
	cudaStreamSynchronize(cudaBackEnd::stream);
	// convert t real and imaginary parts
	splitComplex << <cudaBackEnd::NBK3, cudaBackEnd::BKZ3, 0, cudaBackEnd::stream >> > (cudaBackEnd::d_ifftComplex, cudaBackEnd::d_ifftR, cudaBackEnd::d_ifftI);
	cudaGetLastError();
	cudaStreamSynchronize(cudaBackEnd::stream);
	scalarMult << <cudaBackEnd::NBK3, cudaBackEnd::BKZ3, 0, cudaBackEnd::stream >> > (cudaBackEnd::d_ifftI, cudaBackEnd::d_ifftI, (float)(1.0 / (float)cudaBackEnd::Nz));
	cudaGetLastError();
	cudaStreamSynchronize(cudaBackEnd::stream);
	magnitide << <cudaBackEnd::NBK3, cudaBackEnd::BKZ3, 0, cudaBackEnd::stream >> > (cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_ifftI, cudaBackEnd::d_envelop);
	cudaGetLastError();
	cudaStreamSynchronize(cudaBackEnd::stream);
	//auto stop_env = std::chrono::high_resolution_clock::now();
	// Performing the log transformation to the image to make it enhanced
	// d_envelop is from previous function
	logCompresion << <cudaBackEnd::NBK3, cudaBackEnd::BKZ3, 0, cudaBackEnd::stream >> > (cudaBackEnd::d_envelop, cudaBackEnd::d_logComp, cudaBackEnd::log_c);
	cudaStreamSynchronize(cudaBackEnd::stream);

	//auto stop_com = std::chrono::high_resolution_clock::now();

	//auto duration_bmod = std::chrono::duration_cast<std::chrono::microseconds>(start_env - start_bmod);
	//auto duration_env = std::chrono::duration_cast<std::chrono::microseconds>(stop_env - start_env);
	//auto duration_log = std::chrono::duration_cast<std::chrono::microseconds>(stop_com - stop_env);
	//cudaBackEnd::cudaLog << " duration_bmod time taken:  " << duration_bmod.count() << std::endl;
	//cudaBackEnd::cudaLog << " duration_env time taken:  " << duration_env.count() << std::endl;
	//cudaBackEnd::cudaLog << " duration_log time taken:" << duration_log.count() << std::endl;

	//cudaMemcpy(cudaBackEnd::env, cudaBackEnd::d_logComp, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
	cudaMemcpyAsync(cudaBackEnd::env, cudaBackEnd::d_logComp, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost, cudaBackEnd::stream);
	//cudaMemcpy(cudaBackEnd::env, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
	//cudaMemcpy(env2, cudaBackEnd::d_logComp, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
	//cudaMemcpy(env3, cudaBackEnd::d_envelop, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);

	return 0;

}

int cudaBackEnd::warmUp() {
	// warp up the GPU upon initiating the prob
	
	// init with const values and perform the exact same operation
	onesC(cudaBackEnd::rximg2, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels);

	cudaMemcpyAsync(cudaBackEnd::d_data, cudaBackEnd::rximg2, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels,
		cudaMemcpyHostToDevice, cudaBackEnd::stream);
	beamformingLR3 << <(cudaBackEnd::pixels / 256) * cudaBackEnd::channels, 256, 0, cudaBackEnd::stream >> > (cudaBackEnd::d_bfHR,
		cudaBackEnd::d_tx_delay, cudaBackEnd::d_rx_delay, cudaBackEnd::d_data, cudaBackEnd::d_rx_apod,
		cudaBackEnd::samples, cudaBackEnd::pixels, iteration, cudaBackEnd::num_frames, cudaBackEnd::channels);
	
	// Basic operation completed
	cudaGetLastError();
	cudaStreamSynchronize(cudaBackEnd::stream);
	cudaMemset(cudaBackEnd::d_bfHR, 0, pixels * sizeof(float));

}

// function to init the block size
int cudaBackEnd::calculateThreads() {
	// Fiuntion declaring the number of blocks and threads for each operation
	// diff size threads and blocks are used to three diff opperations
	// 1: h/w reading and initialization
	// 2: Filtering of the B-mode image
	// envelop detection and compression of B-mode image
	
	// pixels:262144, channels:64, num_threads:1024, TILE_SIZE:4


	cudaBackEnd::NBK1 = (cudaBackEnd::pixels / cudaBackEnd::Nx) * cudaBackEnd::channels;// 65536
	cudaBackEnd::BKZ1 = cudaBackEnd::Nx;												// cols size 256

	cudaBackEnd::NBK2 = (cudaBackEnd::pixels + TILE_SIZE - 1) / TILE_SIZE;				// 65536.36
	cudaBackEnd::BKZ2 = TILE_SIZE;

	cudaBackEnd::NBK3 = cudaBackEnd::Nz;
	cudaBackEnd::BKZ3 = cudaBackEnd::Nx;

	// cudaBackEnd::NBK = cudaBackEnd::Nx;
	// cudaBackEnd::BKZ = dim3(cudaBackEnd::Nz);


}


/////////////  old function ///////////////
///////////////////////////////////////////

float** cudaBackEnd::computeBModeImg() {

	//cudaMalloc((void**)&cudaBackEnd::d_bfHR, cudaBackEnd::pixels * sizeof(float));
	//cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));
	//cudaMalloc((void**)&cudaBackEnd::dev_beamformed_data1, cudaBackEnd::pixels * sizeof(float));
	//cudaMalloc((void**)&cudaBackEnd::d_bfHRBP, sizeof(float)* cudaBackEnd::pixels);

	//////////---<H/W INIT>---////////

	//CCyUSBDevice* USBDevice;	// H/W initilization1
	//CCyControlEndPoint* ept;	// H/W initilization2
	//CCyBulkEndPoint* ept_in;	// Endpoint for reading back data
	//USBDevice = new CCyUSBDevice(NULL);
	//ept = USBDevice->ControlEndPt; // Obtain the control endpoint pointer
	//ept_in = USBDevice->BulkInEndPt;

	if (!ept) {
		printf("Could not get Control endpoint.\n");
		//return 1;
	}
	// Send a vendor request (bRequest = 0x05) to the device
	ept->Target = TGT_DEVICE;
	ept->ReqType = REQ_VENDOR;
	ept->Direction = DIR_TO_DEVICE;
	ept->ReqCode = 0x05;
	ept->Value = 1;
	ept->Index = 0;
	ept->TimeOut = 100;				// set timeout to 100ms for quick response

	if (!ept_in) {
		//printf("No IN endpoint??\n");
		return nullptr;
	}
	ept_in->MaxPktSize = 16384;
	ept_in->TimeOut = 100;			// set timeout to 100ms for readin


	//////////-<set reading params>-/////////

	const int MAX_LINE = 256;
	const int N_RX = 64;
	unsigned char buf[16 * 1024];

	errno_t err;
	char line[MAX_LINE]; // Max possible line length?
	FILE* fp;
	if ((err = fopen_s(&fp, "out25_curvi.txt", "r")) != 0) {
		//printf("Could not open config file for reading.\n");
		return nullptr;
	}

	int iteration = 0;
	int errcount = 0;
	int row = 0;					// Keep track of how many rows have been added
	unsigned int addr, data;
	unsigned char recvbuf[2048 * N_RX * 2];
	const int MAXROWS = 2040;
	LONG rxlen = MAXROWS * N_RX * 2;
	cudaBackEnd::env = new float[cudaBackEnd::pixels];


	//unsigned int start = clock();
	while (fgets(line, cudaBackEnd::MAX_LINE, fp)) {
		line[strcspn(line, "\n")] = 0; // Trim trailing newline
		if ((strlen(line) == 0) || (line[0] == ' ') || (line[0] == '#')) {
		}
		else if (line[0] == 'O') {
			sscanf_s(line, "O %04X %08X ", &addr, &data);
			row = insert_row(buf, row, addr, data);
		}
		else if (line[0] == 'T') {
			sscanf_s(line, "T %04X %08X ", &addr, &data);
			row = insert_row(buf, row, 0x6, 0x40000000 | addr);
			row = insert_row(buf, row, 0x7, data);
			row = insert_row(buf, row, 0x6, 0xC0000000 | addr);
		}
		else if (line[0] == 'A') {
			sscanf_s(line, "A %04X %08X ", &addr, &data);
			row = insert_row(buf, row, 0x6, 0x00000000 | addr);
			row = insert_row(buf, row, 0x7, data);
			row = insert_row(buf, row, 0x6, 0x80000000 | addr);
		}
		else if (line[0] == 'C') {  // CAPTURE STARTS
			row = insert_row(buf, row, 0x4, 0x01);
			row = insert_row(buf, row, 0x4, 0x10);
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
				for (int i = 0; i < N_RX; i++) {
					for (int j = 0; j < MAXROWS - 1; j++) {
						//rximg[iteration][i][j] = rxdata[j*64+i+2];
						if (iteration < 29) {      // start from 0 index, so 30-1 
							cudaBackEnd::rximg[i * MAXROWS + j] = rxdata[j * N_RX + i + 2];
						}
						else if (iteration > 91) {
							cudaBackEnd::rximg[(i + 64) * MAXROWS + j] = rxdata[j * N_RX + i + 2];
						}
						else {
							cudaBackEnd::rximg[(i + iteration - 28) * MAXROWS + j] = rxdata[j * N_RX + i + 2];
						}
						//rximg[i * MAXROWS + j] = rxdata[j * N_RX + i + 2];
					}
				}
				//saveToFile(iteration, rxlen, recvbuf);
			}
			else {
				errcount++;
			}

			cudaMemcpy(cudaBackEnd::d_data, cudaBackEnd::rximg, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels, cudaMemcpyHostToDevice);
			beamformingLR3 << <(cudaBackEnd::pixels / 256) * cudaBackEnd::channels, 256 >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_tx_delay, cudaBackEnd::d_rx_delay, cudaBackEnd::d_data, cudaBackEnd::d_rx_apod, cudaBackEnd::samples, cudaBackEnd::pixels, iteration, cudaBackEnd::num_frames, cudaBackEnd::channels);
			cudaGetLastError();
			cudaDeviceSynchronize();

			iteration++;	// Increment iteration after saving to image
			row = 0;		// Reset buffer for next iteration
		}
		else {
			printf("Don't know how to handle [%s] yet.\n", line);
		}
	}

	//////////// Bandpass filtering using shared memory /////////////////////
	BPfilter1SharedMem << <(cudaBackEnd::pixels + cudaBackEnd::TILE_SIZE - 1) / cudaBackEnd::TILE_SIZE, cudaBackEnd::TILE_SIZE >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_filt_coeff, cudaBackEnd::pixels, cudaBackEnd::d_bfHRBP);
	cudaGetLastError();
	cudaDeviceSynchronize();

	//////////////// reshape of the beamformed data ///////////////
	reshape_columnwise << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_bfHRBP);
	cudaGetLastError();
	cudaDeviceSynchronize();
	cudaMemcpy(cudaBackEnd::env, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);

	//char fileout[200];
	//sprintf(fileout, "sample_output/b_curve_mode.csv"); //all the 16 inputs are arranged in a single file
	//csv_write_mat(cudaBackEnd::env, fileout, cudaBackEnd::Nz, cudaBackEnd::Nx);

	///////-<free up for next iteration>-/////////
	zeroC(cudaBackEnd::rximg, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
	cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));
	cudaMemset(cudaBackEnd::dev_beamformed_data1, 0, cudaBackEnd::pixels * sizeof(float));

	float** outArray = convertsingto2darray(env, Nz, Nx);
	return outArray;

}
float** cudaBackEnd::computeBModeImgLinDev()
{
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

	CCyUSBDevice* USBDevice;	// H/W initilization1
	CCyControlEndPoint* ept;	// H/W initilization2
	CCyBulkEndPoint* ept_in;	// Endpoint for reading back data
	USBDevice = new CCyUSBDevice(NULL);
	ept = USBDevice->ControlEndPt;	// Obtain the control endpoint pointer
	if (!ept) {
		printf("Could not get Control endpoint.\n");
		//return 1;
	}
	ept->Target = TGT_DEVICE;		// Send a vendor request (bRequest = 0x05) to the device
	ept->ReqType = REQ_VENDOR;
	ept->Direction = DIR_TO_DEVICE;
	ept->ReqCode = 0x05;
	ept->Value = 1;
	ept->Index = 0;
	ept->TimeOut = 100;  // set timeout to 100ms for quick response

	ept_in = USBDevice->BulkInEndPt;
	if (!ept_in) {
		//printf("No IN endpoint??\n");
		exit(1);
	}
	ept_in->MaxPktSize = 16384;
	ept_in->TimeOut = 100;  // set timeout to 100ms for reading

	static double pix2 = 0.0;
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
	//char fileout[200];
	//sprintf(fileout, "sample_output\\b_mode_%d.csv", 1); //all the 16 inputs are arranged in a single file
	//csv_write_mat(env, fileout, Nz, Nx);
	float** outArray = convertsingto2darray(env, Nz, Nx);

	return outArray;
}
float** cudaBackEnd::computeBModeImgLinDev2(bool debug)
{
	// perform b-mode generation here using cuda
	const int TILE_SIZE = 4;
	int MASK_WIDTH = 364;
	const int MAX_LINE = 256;
	static int call_count = 0;


	////// Computer (NIVIDIA) parametrs
	//int num_threads = 1024;
	///// Apodization parameters
	//float rx_f_number = 2.0;
	///////// Ultrasound scanner parametrs
	////float depth = 49.28;      // Depth of imaging in mm
	//int samples = 2040;         // # of samples in depth direction
	//int N_elements = 64;        // # of transducer elements
	//float sampling_frequency = 32.0e6;   // sampling frequency
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

	cudaBackEnd::env = new float[cudaBackEnd::pixels];
	//float* env2 = new float[cudaBackEnd::pixels];
	//float* env3 = new float[cudaBackEnd::pixels];
	// Global variable to store the full image.  Cannot be declared local as memory alloc may fail due to large size.
	cudaBackEnd::rximg2 = new float[cudaBackEnd::N_elements * cudaBackEnd::samples];
	zeroC(cudaBackEnd::rximg2, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
	//--------------------------------------------------

	int ok = cudaBackEnd::initSettingFile("out25.txt");
	if (debug && call_count == 0)
		cudaBackEnd::cudaLog << "CUDA B-Mode for linear prob starts setting file read" << std::endl;
	//---------------------------------------------------

	static double pix2 = 0.0;
	unsigned char buf[16 * 1024];
	int row = 0;  // Keep track of how many rows have been added
	char line[MAX_LINE]; // Max possible line length?
	int iteration = 0;
	int errcount = 0;
	unsigned int addr, data;
	unsigned char recvbuf[2048 * 64 * 2];
	const int MAXROWS = 2040;
	LONG rxlen = MAXROWS * 64 * 2;
	//-----------------------------------------------------
	//auto start_bmod = std::chrono::high_resolution_clock::now();
	try
	{
		// unsigned int start = clock();
		while (fgets(line, MAX_LINE, cudaBackEnd::fp)) {
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
				cudaBackEnd::ept_in->Abort();
				cudaBackEnd::ept_in->Reset();
				write_rows(cudaBackEnd::ept, buf, row);  // Send commands
				wait(1);
				if (read_chunk(cudaBackEnd::ept_in, recvbuf, rxlen)) {
					short* rxdata = (short*)(recvbuf);
					for (int i = 0; i < rxlen / 2; i++) {
						if (rxdata[i] >= 512) rxdata[i] -= 1024;
					}
					// Trying to read only first N-1 rows and discard 1st sample
					for (int i = 0; i < 64; i++) {
						for (int j = 0; j < MAXROWS - 1; j++) {
							//rximg[iteration][i][j] = rxdata[j*64+i+2];
							cudaBackEnd::rximg2[i * MAXROWS + j] = rxdata[j * 64 + i + 2];
						}
					}
					//saveToFile(iteration, rxlen, recvbuf);
				}
				else {
					errcount++;
				}
				cudaMemcpy(cudaBackEnd::d_data, cudaBackEnd::rximg2, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels, cudaMemcpyHostToDevice);
				beamformingLR3 << <(cudaBackEnd::pixels / 256) * cudaBackEnd::channels, 256 >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_tx_delay, cudaBackEnd::d_rx_delay, cudaBackEnd::d_data, cudaBackEnd::d_rx_apod, cudaBackEnd::samples, cudaBackEnd::pixels, iteration, cudaBackEnd::num_frames, cudaBackEnd::channels);
				cudaGetLastError();
				cudaDeviceSynchronize();
				iteration++; // Increment iteration after saving to image
				row = 0;   // Reset buffer for next iteration
			}
			else {
				printf("Don't know how to handle [%s] yet.\n", line);
			}
		}

		if (debug && call_count == 0)
			cudaBackEnd::cudaLog << "CUDA B-Mode for linear prob while loop completed" << std::endl;
	}
	catch (std::exception& e) {
		return nullptr;
	}


	try
	{
		//// check for nan values,
		isnan_test_array << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_bfHR, cudaBackEnd::pixels);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////// Bandpass filtering using shared memory /////////////////////
		BPfilter1SharedMem << <(cudaBackEnd::pixels + TILE_SIZE - 1) / TILE_SIZE, TILE_SIZE >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_filt_coeff, cudaBackEnd::pixels, cudaBackEnd::d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();
		if (debug && call_count == 0)
			cudaBackEnd::cudaLog << " BPfilter1SharedMem completed " << std::endl;

		//////////////// reshape of the beamformed data ///////////////
		reshape_columnwise << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();

		// Adding envelop detection and log compression
		//auto start_env = std::chrono::high_resolution_clock::now();
		real2complex << <cudaBackEnd::NBK, cudaBackEnd::BKZ >> > (cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_xflatComplex);
		cudaGetLastError();
		cudaDeviceSynchronize();
		cufftExecC2C(cudaBackEnd::plan, cudaBackEnd::d_xflatComplex, cudaBackEnd::d_fftComplex, CUFFT_FORWARD);
		cudaGetLastError();
		cudaDeviceSynchronize();
		cufftExecC2C(cudaBackEnd::plan, cudaBackEnd::d_fftComplex, cudaBackEnd::d_ifftComplex, CUFFT_INVERSE);
		cudaGetLastError();
		cudaDeviceSynchronize();
		// convert t real and imaginary parts
		splitComplex << <cudaBackEnd::NBK, cudaBackEnd::BKZ >> > (cudaBackEnd::d_ifftComplex, cudaBackEnd::d_ifftR, cudaBackEnd::d_ifftI);
		cudaGetLastError();
		cudaDeviceSynchronize();
		scalarMult << <cudaBackEnd::NBK, cudaBackEnd::BKZ >> > (cudaBackEnd::d_ifftI, cudaBackEnd::d_ifftI, (float)(1.0 / (float)cudaBackEnd::Nz));
		cudaGetLastError();
		cudaDeviceSynchronize();
		magnitide << <cudaBackEnd::NBK, cudaBackEnd::BKZ >> > (cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_ifftI, cudaBackEnd::d_envelop);
		cudaGetLastError();
		cudaDeviceSynchronize();
		//auto stop_env = std::chrono::high_resolution_clock::now();
		// Performing the log transformation to the image to make it enhanced
		// d_envelop is from previous function
		logCompresion << <cudaBackEnd::NBK, cudaBackEnd::BKZ >> > (cudaBackEnd::d_envelop, cudaBackEnd::d_logComp, cudaBackEnd::log_c);
		//auto stop_com = std::chrono::high_resolution_clock::now();

		//auto duration_bmod = std::chrono::duration_cast<std::chrono::microseconds>(start_env - start_bmod);
		//auto duration_env = std::chrono::duration_cast<std::chrono::microseconds>(stop_env - start_env);
		//auto duration_log = std::chrono::duration_cast<std::chrono::microseconds>(stop_com - stop_env);
		//cudaBackEnd::cudaLog << " duration_bmod time taken:  " << duration_bmod.count() << std::endl;
		//cudaBackEnd::cudaLog << " duration_env time taken:  " << duration_env.count() << std::endl;
		//cudaBackEnd::cudaLog << " duration_log time taken:" << duration_log.count() << std::endl;

		//cudaMemcpy(cudaBackEnd::env, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
		cudaMemcpy(cudaBackEnd::env, cudaBackEnd::d_logComp, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
		//cudaMemcpy(env2, cudaBackEnd::d_logComp, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
		//cudaMemcpy(env3, cudaBackEnd::d_envelop, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);

		if (debug && call_count == 0)
			cudaBackEnd::cudaLog << " Reshape_columnwise completed " << std::endl;
		//cudaBackEnd::cudaLog << " Nz*Nx" << cudaBackEnd::Nz * cudaBackEnd::Nx << std::endl;

		if (debug && call_count == 0)
		{
			char fileout[200];
			sprintf(fileout, "sample_output\\b_mode_%d.csv", 1); //all the 16 inputs are arranged in a single file
			csv_write_mat(env, fileout, Nz, Nx);
			//sprintf(fileout, "sample_output\\log_com%d.csv", 1); //all the 16 inputs are arranged in a single file
			//csv_write_mat(env2, fileout, Nz, Nx);
			//sprintf(fileout, "sample_output\\mag_%d.csv", 1); //all the 16 inputs are arranged in a single file
			//csv_write_mat(env3, fileout, Nz, Nx);
		}

	}
	catch (std::exception& e)
	{
		return nullptr;
	}


	//double** outArray = convertsingto2darray(cudaBackEnd::env, cudaBackEnd::Nz, cudaBackEnd::Nx);
	float** outArray = convertsingto2darray(cudaBackEnd::env, cudaBackEnd::Nz, cudaBackEnd::Nx);
	if (debug && call_count <= 10)
	{
		cudaBackEnd::cudaLog << " 1 Frame generation completed " << std::endl;
	}




	//// For next iteration
	cudaMemset(cudaBackEnd::d_bfHR, 0, pixels * sizeof(float));
	call_count++;

	return outArray;
}

/////// function without debuging /////////
///////////////////////////////////////////

//int cudaBackEnd::initGPUprobeC(double* probPrms, bool debug) {
//
//	const int MASK_WIDTH = 364;
//	std::ofstream mFile2;
//	mFile2.open("sample_output/testclass.txt");
//	mFile2 << "OK" << std::endl;
//
//	cudaBackEnd::PI = (float)probPrms[3]; mFile2 << PI << std::endl;
//	//cudaBackEnd::MASK_WIDTH		= (int)probPrms[4]; mFile2 << MASK_WIDTH << std::endl;
//	//cudaBackEnd::TILE_SIZE		= (int)probPrms[5]; mFile2 << TILE_SIZE << std::endl;
//	cudaBackEnd::num_threads = (int)probPrms[6]; mFile2 << num_threads << std::endl;
//	cudaBackEnd::rx_f_number = (float)probPrms[7]; mFile2 << rx_f_number << std::endl;
//	cudaBackEnd::samples = (int)probPrms[8]; mFile2 << samples << std::endl;
//	cudaBackEnd::N_elements = (int)probPrms[9]; mFile2 << N_elements << std::endl;
//	cudaBackEnd::sampling_frequency = (float)probPrms[10]; mFile2 << sampling_frequency << std::endl;
//	cudaBackEnd::c = (float)probPrms[11]; mFile2 << c << std::endl;
//	cudaBackEnd::N_active = (int)probPrms[12]; mFile2 << N_active << std::endl;
//	cudaBackEnd::channels = (int)probPrms[13]; mFile2 << channels << std::endl;
//	cudaBackEnd::Nx = (int)probPrms[14]; mFile2 << Nx << std::endl;
//	cudaBackEnd::Nz = (int)probPrms[15]; mFile2 << Nz << std::endl;
//	cudaBackEnd::frames = (int)probPrms[16]; mFile2 << frames << std::endl;
//	cudaBackEnd::num_frames = (int)probPrms[17]; mFile2 << num_frames << std::endl;
//	cudaBackEnd::skip_frames = (int)probPrms[18]; mFile2 << skip_frames << std::endl;
//	cudaBackEnd::dBvalue = (int)probPrms[19]; mFile2 << dBvalue << std::endl;
//	cudaBackEnd::pitch = (float)probPrms[20]; mFile2 << pitch << std::endl;
//	cudaBackEnd::aper_len = (float)probPrms[21]; mFile2 << aper_len << std::endl;
//	cudaBackEnd::zd = (float)probPrms[22]; mFile2 << zd << std::endl;
//	cudaBackEnd::sample_spacing = (float)probPrms[23]; mFile2 << sample_spacing << std::endl;
//	cudaBackEnd::del_convert = (float)probPrms[24]; mFile2 << del_convert << std::endl;
//	cudaBackEnd::rc = (float)probPrms[25]; mFile2 << rc << std::endl;
//	cudaBackEnd::scan_angle = (float)probPrms[26]; mFile2 << scan_angle  << std::endl;
//	cudaBackEnd::pixels = (int)probPrms[27]; mFile2 << pixels << std::endl;
//	cudaBackEnd::pix_cha = (int)probPrms[28]; mFile2 << pix_cha << std::endl;
//	
//
//	
//	cudaBackEnd::env = new float[cudaBackEnd::pixels];
//
//	char filename1[200];
//	sprintf(filename1, "b_10M.csv");
//	cudaBackEnd::read_csv_array(cudaBackEnd::filt_coeff, filename1);    // csv file read
//
//	//float* d_filt_coeff = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_filt_coeff, sizeof(float) * MASK_WIDTH);
//	cudaMemcpy(cudaBackEnd::d_filt_coeff, filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);
//
//	////////  Intialization &(or) Memory allocation  //////////////////
//	//float* d_data = 0;   // variable to store raw rf data
//	cudaMalloc((void**)&cudaBackEnd::d_data, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels);
//
//	//float* d_bfHR = 0;  // variable to store beamformed high-resolution beamformed image 
//	cudaMalloc((void**)&cudaBackEnd::d_bfHR, cudaBackEnd::pixels * sizeof(float));
//	//zeros << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);  
//	cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));
//
//	//float* dev_beamformed_data1 = 0;   // variable to store reshaped beamformed data
//	cudaMalloc((void**)&cudaBackEnd::dev_beamformed_data1, cudaBackEnd::pixels * sizeof(float));
//
//	//float* d_bfHRBP = 0;  // variable to store beamformed high-resolution bandpass filtered data
//	cudaMalloc((void**)&cudaBackEnd::d_bfHRBP, sizeof(float) * cudaBackEnd::pixels);
//
//	/////////////////// theta positions for all elements ////////////////////
//	//float* d_theta = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_theta, cudaBackEnd::N_elements * sizeof(float));
//	range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta, (-cudaBackEnd::scan_angle / 2), cudaBackEnd::N_elements, (cudaBackEnd::scan_angle / (cudaBackEnd::N_elements - 1)));
//
//
//	///////////// theta for grid /////////////////  theta = -scan_angle / 2 : scan_angle / (elements - 1) : scan_angle / 2;
//	//float* d_theta1 = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_theta1, cudaBackEnd::Nx * sizeof(float));
//	range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta1, (-cudaBackEnd::scan_angle / 2), cudaBackEnd::Nx, (cudaBackEnd::scan_angle / (cudaBackEnd::Nx - 1)));
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	////////////// z value////////////////////
//	float dz = cudaBackEnd::sample_spacing * cudaBackEnd::samples / cudaBackEnd::Nz;  // depth / (Nz - 1) / 1000;   // spacing in axial (z) direction in mm;
//	//float* d_z_axis = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_z_axis, cudaBackEnd::Nz * sizeof(float));
//	range << <cudaBackEnd::Nz / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_z_axis, 0, cudaBackEnd::Nz, dz);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	//////////////////////////////// x value////////////////////////////////
//	float dx = aper_len / (Nx - 1);
//	//float* d_x_axis = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_x_axis, cudaBackEnd::Nx * sizeof(float));
//	range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, (-cudaBackEnd::aper_len / 2000), cudaBackEnd::Nx, dx / 1000);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	//////////////// Probe geometry, this info can be taken from transducer file ////////////////////
//	//float* d_probe = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_probe, cudaBackEnd::N_elements * sizeof(float));
//	//cudaMemcpy(d_probe, probe_ge_x, N_elements * sizeof(double), cudaMemcpyHostToDevice);
//	range << <1, cudaBackEnd::N_elements >> > (cudaBackEnd::d_probe, (-cudaBackEnd::aper_len / 2000), cudaBackEnd::N_elements, cudaBackEnd::pitch);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	/////////////////rx aerture calculation using Fnumber///////////////////////////////
//	// rx_aper=rfsca.z/rf_number
//	//float* d_rx_aperture = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_rx_aperture, cudaBackEnd::Nz * sizeof(float));
//	element_division << <cudaBackEnd::Nz / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_z_axis, cudaBackEnd::rx_f_number, cudaBackEnd::Nz, cudaBackEnd::d_rx_aperture);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	////////////////////////rx aerture distance////////
//	//float* d_rx_ap_distance = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_rx_ap_distance, cudaBackEnd::channels * cudaBackEnd::Nx * sizeof(float));  //20.087 us
//	aperture_distance << <cudaBackEnd::Nx * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, cudaBackEnd::d_probe, cudaBackEnd::Nx, cudaBackEnd::channels, cudaBackEnd::d_rx_ap_distance);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	///////////////////apodization/////////////////
//	//float* d_rx_apod = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_rx_apod, sizeof(float) * cudaBackEnd::Nz * cudaBackEnd::channels * cudaBackEnd::Nx);
//	apodization << <cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_rx_ap_distance, cudaBackEnd::d_rx_aperture, cudaBackEnd::Nz, cudaBackEnd::Nx, cudaBackEnd::channels, cudaBackEnd::pixels, cudaBackEnd::d_rx_apod);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	//// check for nan values,
//	isnan_test_array << <cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_rx_apod, cudaBackEnd::pixels * cudaBackEnd::channels);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	cudaFree(cudaBackEnd::d_rx_aperture);
//	cudaFree(cudaBackEnd::d_rx_ap_distance);
//
//	/////////////receive delay calculation /////////////////////////////////////////////
//	//float* d_rx_delay = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_rx_delay, cudaBackEnd::pix_cha * sizeof(float));
//	receive_delay << < cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta, cudaBackEnd::d_theta1, cudaBackEnd::rc, cudaBackEnd::d_z_axis, cudaBackEnd::channels, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::d_rx_delay);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	/////////////////// theta positions for all elements ////////////////////
//	//float* d_theta_tx = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_theta_tx, cudaBackEnd::num_frames * sizeof(float));
//	theta1 << < 1, cudaBackEnd::num_frames >> > (cudaBackEnd::d_theta_tx, cudaBackEnd::d_theta, cudaBackEnd::frames, cudaBackEnd::N_active, cudaBackEnd::skip_frames);
//
//	/////////////////// Transmit delay calculation ////////////////////
//	//float* d_tx_delay = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_tx_delay, cudaBackEnd::pixels * cudaBackEnd::num_frames * sizeof(float));
//	//transmitter delay for 16 frames,  
//	transmit_delay << < cudaBackEnd::pixels * cudaBackEnd::num_frames / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta1, cudaBackEnd::d_z_axis, cudaBackEnd::rc, cudaBackEnd::d_theta_tx, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::num_frames, cudaBackEnd::zd, cudaBackEnd::d_tx_delay);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	cudaFree(cudaBackEnd::d_theta1);
//	cudaFree(cudaBackEnd::d_probe);
//	cudaFree(cudaBackEnd::d_x_axis);
//	cudaFree(cudaBackEnd::d_z_axis);
//	cudaFree(cudaBackEnd::d_theta_tx);
//
//	zeroC(cudaBackEnd::rximg, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
//
//	mFile2 << "Memmory init completed" << std::endl;
//	mFile2.close();
//
//	return 0;
//}

//double** cudaBackEnd::computeBModeImgDev(bool debug) {
//
//	const int MAX_LINE = 256;
//	const int N_RX = 64;
//	unsigned char buf[16 * 1024];
//	std::ofstream mFile;
//	mFile.open("sample_output/testcomputeimg.txt");
//	mFile << "OK" << std::endl;
//
//	//-----------------------
//	int ok = cudaBackEnd::initSettingFile("out25_curvi.txt");
//	//-----------------------
//
//	//mFile << "h/w init done" << std::endl;
//
//	char line[MAX_LINE]; // Max possible line length?
//	int iteration = 0;
//	int errcount = 0;
//	int row = 0;					// Keep track of how many rows have been added
//	unsigned int addr, data;
//	unsigned char recvbuf[2048 * N_RX * 2];
//	const int MAXROWS = 2040;
//	LONG rxlen = MAXROWS * N_RX * 2;
//	//cudaBackEnd::env = new float[cudaBackEnd::pixels];
//	zeroC(cudaBackEnd::rximg, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
//
//	//unsigned int start = clock();
//	while (fgets(line, cudaBackEnd::MAX_LINE, cudaBackEnd::fp)) 
//	{
//		//mFile << line << std::endl;
//		line[strcspn(line, "\n")] = 0; // Trim trailing newline
//		if ((strlen(line) == 0) || (line[0] == ' ') || (line[0] == '#')) {
//			//printf("Skipping [%s]\n", line);
//		}
//		else if (line[0] == 'O') {
//			sscanf_s(line, "O %04X %08X ", &addr, &data);
//			//printf("Write %08X to Obelix %04X\n", data, addr);
//			row = insert_row(buf, row, addr, data);
//		}
//		else if (line[0] == 'T') {
//			sscanf_s(line, "T %04X %08X ", &addr, &data);
//			row = insert_row(buf, row, 0x6, 0x40000000 | addr);
//			row = insert_row(buf, row, 0x7, data);
//			row = insert_row(buf, row, 0x6, 0xC0000000 | addr);
//			//printf("Write %08X to TX %04X\n", data, addr);
//		}
//		else if (line[0] == 'A') {
//			sscanf_s(line, "A %04X %08X ", &addr, &data);
//			row = insert_row(buf, row, 0x6, 0x00000000 | addr);
//			row = insert_row(buf, row, 0x7, data);
//			row = insert_row(buf, row, 0x6, 0x80000000 | addr);
//			//printf("Write %08X to AFE %04X\n", data, addr);
//		}
//		else if (line[0] == 'C') {  // CAPTURE STARTS
//			//wait(100);
//			row = insert_row(buf, row, 0x4, 0x01);
//			//write_rows(ept, buf, row);  // Send commands
//			//wait(100);
//			row = insert_row(buf, row, 0x4, 0x10);
//			//write_rows(ept, buf, row);  // Send commands
//			//wait(100);
//			row = insert_row(buf, row, 0x4, 0x00);
//			//mFile << "insert_row" << std::endl;
//
//			cudaBackEnd::ept_in->Abort();
//			cudaBackEnd::ept_in->Reset();
//
//			//mFile << "abort reset " << std::endl;
//
//			write_rows(cudaBackEnd::ept, buf, row);  // Send commands
//			//mFile << "write_rows" << std::endl;
//			//wait(100);
//			//row = insert_row(buf, row, 0x4, 0x03);
//			//row = insert_row(buf, row, 0x4, 0x10);
//			//row = insert_row(buf, row, 0x4, 0x00);
//			//printf("CAPTURE %2d: ", iteration);
//			//write_rows(ept, buf, row);  // Send commands
//			
//			// One iteration should have 2048 samples * 64 channels * 2 bytes each
//
//			wait(1);
//			if (read_chunk(cudaBackEnd::ept_in, recvbuf, rxlen)) {
//				short* rxdata = (short*)(recvbuf);
//				for (int i = 0; i < rxlen / 2; i++) {
//					if (rxdata[i] >= 512) rxdata[i] -= 1024;
//				}
//				// Trying to read only first N-1 rows and discard 1st sample
//				for (int i = 0; i < N_RX; i++) {
//					for (int j = 0; j < MAXROWS - 1; j++) {
//						//rximg[iteration][i][j] = rxdata[j*64+i+2];
//						if (iteration < 29) {      // start from 0 index, so 30-1 
//							cudaBackEnd::rximg[i * MAXROWS + j] = rxdata[j * N_RX + i + 2];
//						}
//						else if (iteration > 91) {
//							cudaBackEnd::rximg[(i + 64) * MAXROWS + j] = rxdata[j * N_RX + i + 2];
//						}
//						else {
//							cudaBackEnd::rximg[(i + iteration - 28) * MAXROWS + j] = rxdata[j * N_RX + i + 2];
//						}
//						//rximg[i * MAXROWS + j] = rxdata[j * N_RX + i + 2];
//					}
//				}
//				//saveToFile(iteration, rxlen, recvbuf);
//			}
//			else {
//				errcount++;
//			}
//			//mFile << "read_chunk" << std::endl;
//
//			//clock_t begin = clock();   // clock intiated
//
//			cudaMemcpy(cudaBackEnd::d_data, cudaBackEnd::rximg, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels, cudaMemcpyHostToDevice);
//
//			beamformingLR3 << <(cudaBackEnd::pixels / 256) * cudaBackEnd::channels, 256 >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_tx_delay, cudaBackEnd::d_rx_delay, cudaBackEnd::d_data, cudaBackEnd::d_rx_apod, cudaBackEnd::samples, cudaBackEnd::pixels, iteration, cudaBackEnd::num_frames, cudaBackEnd::channels);
//			//mFile << "beamformingLR3" << std::endl;
//			cudaGetLastError();
//			cudaDeviceSynchronize();
//
//			//clock_t end = clock();
//			//float elapsed_secs = float(end - begin) / CLOCKS_PER_SEC;
//			//printf("Time for beamforming in ms: %f\n", elapsed_secs * 1000);
//
//			iteration++;	// Increment iteration after saving to image
//			row = 0;		// Reset buffer for next iteration
//		}
//		else {
//			mFile << "Don't know how to handle" << std::endl;
//			printf("Don't know how to handle [%s] yet.\n", line);
//		}
//	}
//
//	//mFile << "while loop completed" << std::endl;
//
//	//////////// Bandpass filtering using shared memory /////////////////////
//	BPfilter1SharedMem << <(cudaBackEnd::pixels + cudaBackEnd::TILE_SIZE - 1) / cudaBackEnd::TILE_SIZE, cudaBackEnd::TILE_SIZE >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_filt_coeff, cudaBackEnd::pixels, cudaBackEnd::d_bfHRBP);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//	//mFile << "BPF done" << std::endl;
//
//	//////////////// reshape of the beamformed data ///////////////
//	reshape_columnwise << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_bfHRBP);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//	cudaMemcpy(cudaBackEnd::env, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
//	//mFile << "reshape done" << std::endl;
//	char fileout[200];
//	sprintf(fileout, "sample_output/b_curve_mode.csv"); //all the 16 inputs are arranged in a single file
//	csv_write_mat(cudaBackEnd::env, fileout, cudaBackEnd::Nz, cudaBackEnd::Nx);
//	//mFile << "CSV written" << std::endl;
//
//	double** outArray = convertsingto2darray(cudaBackEnd::env, cudaBackEnd::Nz, cudaBackEnd::Nx);
//
//
//	// For next iteration
//	
//	//cudaMalloc((void**)&cudaBackEnd::d_data, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels);
//	//cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));
//	//cudaMemset(cudaBackEnd::dev_beamformed_data1, 0, cudaBackEnd::pixels * sizeof(float));
//	zeroC(cudaBackEnd::rximg, cudaBackEnd::samples* cudaBackEnd::N_elements);   // set rx_img array values to zero.
//	//cudaBackEnd::fp->
//
//	mFile.close();
//	return outArray;
//
//}

//int cudaBackEnd::initGPUprobeL(double* prob_params, bool debug)
//{
//	//// perform b-mode generation here using cuda
//	//const int TILE_SIZE = 4;
//	//int MASK_WIDTH = 364;
//	//const int MAX_LINE = 256;
//	////// Computer (NIVIDIA) parametrs
//	//int num_threads = 1024;
//	///// Apodization parameters
//	//float rx_f_number = 2.0;
//	///////// Ultrasound scanner parametrs
//	////float depth = 49.28;      // Depth of imaging in mm
//	//int samples = 2040;         // # of samples in depth direction
//	//int N_elements = 64;        // # of transducer elements
//	//float sampling_frequency = 32e6;   // sampling frequency
//	//float c = 1540.0;		 // speed of sound [m/s]	
//	//int N_active = 8;        // Active transmit elmeents
//	//float pitch = 0.3 / 1000;// spacing between the elements
//	//float aper_len = (N_elements - 1) * pitch * 1000;  //aperture foot print 
//	//float zd = pitch * N_active / (float)2;            // virtual src distance from transducer array 
//	//float sample_spacing = c / sampling_frequency / (float)2;
//	//float del_convert = sampling_frequency / c;  // used in delay calculation
//	//int channels = 64;							 // number of A-lines data used for beamforming
//	////// Beamforming "Grid" parameters
//	//int Nx = 256;			// 256 Lateral spacing
//	//int Nz = 1024;			//1024 Axial spacing
//	//int pixels = Nz * Nx;
//	//int pix_cha = pixels * channels;// Nz*Nx*128 This array size is used for Apodization
//	//int num_frames = 57;			// number of low resolution images
//	//int skip_frames = 1;			//
//
//	// perform b-mode generation here using cuda
//	const int TILE_SIZE = prob_params[0];
//	int MASK_WIDTH = prob_params[1];
//	const int MAX_LINE = prob_params[2];
//
//	cudaBackEnd::num_threads = prob_params[3];
//	cudaBackEnd::rx_f_number = prob_params[4];	// Apodization parameters
//	cudaBackEnd::samples = prob_params[5];	// # of samples in depth direction
//	cudaBackEnd::N_elements = prob_params[6];	// # of transducer elements
//	cudaBackEnd::sampling_frequency = prob_params[7];   // sampling frequency
//	cudaBackEnd::c = prob_params[8];	// speed of sound [m/s]	
//	cudaBackEnd::N_active = prob_params[9];   // Active transmit elmeents
//	cudaBackEnd::pitch = prob_params[10];	// spacing between the elements
//	cudaBackEnd::aper_len = prob_params[11];  // aperture foot print 
//	cudaBackEnd::zd = prob_params[12];  // virtual src distance from transducer array 
//	cudaBackEnd::sample_spacing = prob_params[13];
//	cudaBackEnd::del_convert = prob_params[14];  // used in delay calculation
//	cudaBackEnd::channels = prob_params[15];	// number of A-lines data used for beamforming
//	cudaBackEnd::Nx = prob_params[16];	// 256 Lateral spacing Beamforming "Grid" parameters
//	cudaBackEnd::Nz = prob_params[17];	// 1024 Axial spacing
//	cudaBackEnd::pixels = prob_params[18];
//	cudaBackEnd::pix_cha = prob_params[19];	// Nz*Nx*128 This array size is used for Apodization
//	cudaBackEnd::num_frames = prob_params[20];	// number of low resolution images
//	cudaBackEnd::skip_frames = prob_params[21];	//
//
//
//	if (debug)
//	{
//		cudaBackEnd::cudaLog << "num_threads : " << prob_params[3] << std::endl;
//		cudaBackEnd::cudaLog << "rx_f_number : " << prob_params[4] << std::endl;
//		cudaBackEnd::cudaLog << "samples : " << prob_params[5] << std::endl;
//		cudaBackEnd::cudaLog << "N_elements : " << prob_params[6] << std::endl;
//		cudaBackEnd::cudaLog << "sampling_frequency : " << prob_params[7] << std::endl;
//		cudaBackEnd::cudaLog << "c : " << prob_params[8] << std::endl;
//		cudaBackEnd::cudaLog << "N_active : " << prob_params[9] << std::endl;
//		cudaBackEnd::cudaLog << "pitch : " << prob_params[10] << std::endl;
//		cudaBackEnd::cudaLog << "aper_len : " << prob_params[11] << std::endl;
//		cudaBackEnd::cudaLog << "zd : " << prob_params[12] << std::endl;
//		cudaBackEnd::cudaLog << "sample_spacing : " << prob_params[13] << std::endl;
//		cudaBackEnd::cudaLog << "del_convert : " << prob_params[14] << std::endl;
//		cudaBackEnd::cudaLog << "channels : " << prob_params[15] << std::endl;
//		cudaBackEnd::cudaLog << "Nx : " << prob_params[16] << std::endl;
//		cudaBackEnd::cudaLog << "Nz : " << prob_params[17] << std::endl;
//		cudaBackEnd::cudaLog << "pixels : " << prob_params[18] << std::endl;
//		cudaBackEnd::cudaLog << "pix_cha : " << prob_params[19] << std::endl;
//		cudaBackEnd::cudaLog << "num_frames : " << prob_params[20] << std::endl;
//		cudaBackEnd::cudaLog << "skip_frames : " << prob_params[21] << std::endl;
//	}
//
//	char filename3[200];
//	sprintf(filename3, "b_10M.csv");
//	read_csv_array(cudaBackEnd::filt_coeff, filename3);    // csv file read
//	//cv::imwrite("okMat3.png", testMat0);
//
//	// float* d_filt_coeff = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_filt_coeff, sizeof(float) * MASK_WIDTH);
//	cudaMemcpy(cudaBackEnd::d_filt_coeff, cudaBackEnd::filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);
//
//	////////  Intialization &(or) Memory allocation  //////////////////
//	cudaMalloc((void**)&cudaBackEnd::d_data, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels);// variable to store raw rf data
//
//	cudaMalloc((void**)&cudaBackEnd::d_bfHR, cudaBackEnd::pixels * sizeof(float)); // variable to store beamformed high-resolution beamformed image 
//	cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));
//
//	cudaMalloc((void**)&cudaBackEnd::dev_beamformed_data1, cudaBackEnd::pixels * sizeof(float));// variable to store reshaped beamformed data
//
//	cudaMalloc((void**)&cudaBackEnd::d_bfHRBP, sizeof(float) * cudaBackEnd::pixels);// variable to store beamformed high-resolution bandpass filtered data
//
//	////////////// z value////////////////////
//	float dz = sample_spacing * samples / Nz;  // depth / (Nz - 1) / 1000;   // spacing in axial (z) direction in mm;
//	cudaMalloc((void**)&cudaBackEnd::d_z_axis, cudaBackEnd::Nz * sizeof(float));
//	range << <cudaBackEnd::Nz / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_z_axis, 0, cudaBackEnd::Nz, dz);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	//////////////////////////////// x value////////////////////////////////
//	float dx = aper_len / (cudaBackEnd::Nx - 1);
//	// float* d_x_axis = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_x_axis, cudaBackEnd::Nx * sizeof(float));    // 167.939 us
//	range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, (-cudaBackEnd::aper_len / 2000), cudaBackEnd::Nx, dx / 1000);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	//////////////// Probe geometry, this info can be taken from transducer file ////////////////////
//	//float* d_probe = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_probe, cudaBackEnd::N_elements * sizeof(float));
//	range << <1, cudaBackEnd::N_elements >> > (cudaBackEnd::d_probe, (-cudaBackEnd::aper_len / 2000), cudaBackEnd::N_elements, cudaBackEnd::pitch);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	/////////////////rx aerture calculation using Fnumber///////////////////////////////
//	cudaMalloc((void**)&cudaBackEnd::d_rx_aperture, cudaBackEnd::Nz * sizeof(float));
//	element_division << <cudaBackEnd::Nz / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_z_axis, cudaBackEnd::rx_f_number, cudaBackEnd::Nz, cudaBackEnd::d_rx_aperture);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	////////////////////////rx aerture distance////////
//	cudaMalloc((void**)&cudaBackEnd::d_rx_ap_distance, cudaBackEnd::channels * cudaBackEnd::Nx * sizeof(float));
//	aperture_distance << <cudaBackEnd::Nx * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, cudaBackEnd::d_probe, cudaBackEnd::Nx, cudaBackEnd::channels, cudaBackEnd::d_rx_ap_distance);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	///////////////////apodization/////////////////
//	// float* d_rx_apod = 0;
//	cudaMalloc((void**)&cudaBackEnd::d_rx_apod, sizeof(float) * cudaBackEnd::Nz * cudaBackEnd::channels * cudaBackEnd::Nx);
//	apodization << <cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_rx_ap_distance, cudaBackEnd::d_rx_aperture, cudaBackEnd::Nz, cudaBackEnd::Nx, cudaBackEnd::channels, cudaBackEnd::pixels, cudaBackEnd::d_rx_apod);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	cudaFree(d_rx_aperture);
//	cudaFree(d_rx_ap_distance);
//
//	/////////////////// calculate central positions transmit subaperture ////////////////////
//	cudaMalloc((void**)&cudaBackEnd::d_cen_pos, cudaBackEnd::num_frames * sizeof(float));
//	Tx_cen_pos << < 1, cudaBackEnd::num_frames >> > (cudaBackEnd::d_cen_pos, cudaBackEnd::N_elements, cudaBackEnd::N_active, cudaBackEnd::pitch, cudaBackEnd::skip_frames, cudaBackEnd::num_frames, cudaBackEnd::d_probe);
//
//	/////////////receive delay calculation /////////////////////////////////////////////
//	cudaMalloc((void**)&cudaBackEnd::d_rx_delay, cudaBackEnd::pix_cha * sizeof(float));
//	receive_delay << < cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_probe, cudaBackEnd::d_x_axis, cudaBackEnd::d_z_axis, cudaBackEnd::channels, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::d_rx_delay);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	/////////////////// Transmit delay calculation ////////////////////
//	cudaMalloc((void**)&cudaBackEnd::d_tx_delay, cudaBackEnd::pixels * cudaBackEnd::num_frames * sizeof(float));
//	transmit_delay << < cudaBackEnd::pixels * cudaBackEnd::num_frames / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, cudaBackEnd::d_z_axis, cudaBackEnd::d_cen_pos, cudaBackEnd::zd, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::num_frames, cudaBackEnd::d_tx_delay);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//
//	////////////Free cuda memory (one time use) ///////////////////////////
//	cudaFree(cudaBackEnd::d_probe);
//	cudaFree(cudaBackEnd::d_x_axis);
//	cudaFree(cudaBackEnd::d_z_axis);
//	cudaFree(cudaBackEnd::d_cen_pos);
//
//	//char filename3[200];
//	//sprintf(filename3, "b_10M.csv");
//	//read_csv_array(filt_coeff, filename3);    // csv file read
//	////cv::imwrite("okMat3.png", testMat0);
//	//// float* d_filt_coeff = 0;
//	//cudaMalloc((void**)&d_filt_coeff, sizeof(float) * MASK_WIDTH);
//	//cudaMemcpy(d_filt_coeff, filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);
//	//////////  Intialization &(or) Memory allocation  //////////////////
//	//// float* d_data = 0;   // variable to store raw rf data
//	//cudaMalloc((void**)&d_data, sizeof(float) * samples * channels);
//	//// float* d_bfHR = 0;  // variable to store beamformed high-resolution beamformed image 
//	//cudaMalloc((void**)&d_bfHR, pixels * sizeof(float));
//	////zeros << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);  
//	//cudaMemset(d_bfHR, 0, pixels * sizeof(float));
//	//// float* dev_beamformed_data1 = 0;   // variable to store reshaped beamformed data
//	//cudaMalloc((void**)&dev_beamformed_data1, pixels * sizeof(float));
//	//// float* d_bfHRBP = 0;  // variable to store beamformed high-resolution bandpass filtered data
//	//cudaMalloc((void**)&d_bfHRBP, sizeof(float) * pixels);
//	//////////////// z value////////////////////
//	//float dz = sample_spacing * samples / Nz;  // depth / (Nz - 1) / 1000;   // spacing in axial (z) direction in mm;
//	//// float* d_z_axis = 0;
//	//cudaMalloc((void**)&d_z_axis, Nz * sizeof(float));
//	//range << <Nz / num_threads + 1, num_threads >> > (d_z_axis, 0, Nz, dz);
//	//cudaGetLastError();
//	//cudaDeviceSynchronize();
//	////////////////////////////////// x value////////////////////////////////
//	//float dx = aper_len / (Nx - 1);
//	//// float* d_x_axis = 0;
//	//cudaMalloc((void**)&d_x_axis, Nx * sizeof(float));    // 167.939 us
//	//range << <Nx / num_threads + 1, num_threads >> > (d_x_axis, (-aper_len / 2000), Nx, dx / 1000);
//	//cudaGetLastError();
//	//cudaDeviceSynchronize();
//	////////////////// Probe geometry, this info can be taken from transducer file ////////////////////
//	////float* d_probe = 0;
//	//cudaMalloc((void**)&d_probe, N_elements * sizeof(float));
//	//range << <1, N_elements >> > (d_probe, (-aper_len / 2000), N_elements, pitch);
//	//cudaGetLastError();
//	//cudaDeviceSynchronize();
//	///////////////////rx aerture calculation using Fnumber///////////////////////////////
//	//// rx_aper=rfsca.z/rf_number
//	//// float* d_rx_aperture = 0;
//	//cudaMalloc((void**)&d_rx_aperture, Nz * sizeof(float));
//	//element_division << <Nz / num_threads + 1, num_threads >> > (d_z_axis, rx_f_number, Nz, d_rx_aperture);
//	//cudaGetLastError();
//	//cudaDeviceSynchronize();
//	//////////////////////////rx aerture distance////////
//	//// float* d_rx_ap_distance = 0;
//	//cudaMalloc((void**)&d_rx_ap_distance, channels * Nx * sizeof(float));
//	//aperture_distance << <Nx * channels / num_threads + 1, num_threads >> > (d_x_axis, d_probe, Nx, channels, d_rx_ap_distance);
//	//cudaGetLastError();
//	//cudaDeviceSynchronize();
//	/////////////////////apodization/////////////////
//	//// float* d_rx_apod = 0;
//	//cudaMalloc((void**)&d_rx_apod, sizeof(float) * Nz * channels * Nx);
//	//apodization << <pixels * channels / num_threads + 1, num_threads >> > (d_rx_ap_distance, d_rx_aperture, Nz, Nx, channels, pixels, d_rx_apod);
//	//cudaGetLastError();
//	//cudaDeviceSynchronize();
//	//cudaFree(d_rx_aperture);
//	//cudaFree(d_rx_ap_distance);
//	///////////////////// calculate central positions transmit subaperture ////////////////////
//	//// float* d_cen_pos = 0;
//	//cudaMalloc((void**)&d_cen_pos, num_frames * sizeof(float));
//	//Tx_cen_pos << < 1, num_frames >> > (d_cen_pos, N_elements, N_active, pitch, skip_frames, num_frames, d_probe);
//	///////////////receive delay calculation /////////////////////////////////////////////
//	//// float* d_rx_delay = 0;
//	//cudaMalloc((void**)&d_rx_delay, pix_cha * sizeof(float));
//	//receive_delay << < pixels * channels / num_threads + 1, num_threads >> > (d_probe, d_x_axis, d_z_axis, channels, Nx, Nz, del_convert, d_rx_delay);
//	//cudaGetLastError();
//	//cudaDeviceSynchronize();
//	///////////////////// Transmit delay calculation ////////////////////
//	//// float* d_tx_delay = 0;
//	//cudaMalloc((void**)&d_tx_delay, pixels * num_frames * sizeof(float));
//	////transmit delay for all frames,   
//	//transmit_delay << < pixels * num_frames / num_threads + 1, num_threads >> > (d_x_axis, d_z_axis, d_cen_pos, zd, Nx, Nz, del_convert, num_frames, d_tx_delay);
//	//cudaGetLastError();
//	//cudaDeviceSynchronize();
//	//////////////Free cuda memory (one time use) ///////////////////////////
//	//cudaFree(d_probe);
//	//cudaFree(d_x_axis);
//	//cudaFree(d_z_axis);
//	//cudaFree(d_cen_pos);
//
//	return 0;
//}

//double** cudaBackEnd::computeBModeImgLinDev2(bool debug)
//{
//	// perform b-mode generation here using cuda
//	const int TILE_SIZE = 4;
//	int MASK_WIDTH = 364;
//	const int MAX_LINE = 256;
//
//	////// Computer (NIVIDIA) parametrs
//	//int num_threads = 1024;
//	///// Apodization parameters
//	//float rx_f_number = 2.0;
//	///////// Ultrasound scanner parametrs
//	////float depth = 49.28;      // Depth of imaging in mm
//	//int samples = 2040;         // # of samples in depth direction
//	//int N_elements = 64;        // # of transducer elements
//	//float sampling_frequency = 32.0e6;   // sampling frequency
//	//float c = 1540.0;		 // speed of sound [m/s]	
//	//int N_active = 8;        // Active transmit elmeents
//	//float pitch = 0.3 / 1000;// spacing between the elements
//	//float aper_len = (N_elements - 1) * pitch * 1000;  //aperture foot print 
//	//float zd = pitch * N_active / (float)2;            // virtual src distance from transducer array 
//	//float sample_spacing = c / sampling_frequency / (float)2;
//	//float del_convert = sampling_frequency / c;  // used in delay calculation
//	//int channels = 64;							 // number of A-lines data used for beamforming
//	////// Beamforming "Grid" parameters
//	//int Nx = 256;			// 256 Lateral spacing
//	//int Nz = 1024;			//1024 Axial spacing
//	//int pixels = Nz * Nx;
//	//int pix_cha = pixels * channels;// Nz*Nx*128 This array size is used for Apodization
//	//int num_frames = 57;			// number of low resolution images
//	//int skip_frames = 1;			//
//	
//	cudaBackEnd::env = new float[cudaBackEnd::pixels];
//	// Global variable to store the full image.  Cannot be declared local as memory alloc may fail due to large size.
//	cudaBackEnd::rximg2 = new float[cudaBackEnd::N_elements * cudaBackEnd::samples];
//	zeroC(cudaBackEnd::rximg2, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
//	//--------------------------------------------------
//	
//	int ok = cudaBackEnd::initSettingFile("out25.txt");
//	
//	//---------------------------------------------------
//
//	static double pix2 = 0.0;
//	unsigned char buf[16 * 1024];
//	int row = 0;  // Keep track of how many rows have been added
//	char line[MAX_LINE]; // Max possible line length?
//	int iteration = 0;
//	int errcount = 0;
//	unsigned int addr, data;
//	unsigned char recvbuf[2048 * 64 * 2];
//	const int MAXROWS = 2040;
//	LONG rxlen = MAXROWS * 64 * 2;
//	//-----------------------------------------------------
//
//	// unsigned int start = clock();
//	while (fgets(line, MAX_LINE, cudaBackEnd::fp)) {
//		line[strcspn(line, "\n")] = 0; // Trim trailing newline
//		if ((strlen(line) == 0) || (line[0] == ' ') || (line[0] == '#')) {
//			//printf("Skipping [%s]\n", line);
//		}
//		else if (line[0] == 'O') {
//			sscanf_s(line, "O %04X %08X ", &addr, &data);
//			//printf("Write %08X to Obelix %04X\n", data, addr);
//			row = insert_row(buf, row, addr, data);
//		}
//		else if (line[0] == 'T') {
//			sscanf_s(line, "T %04X %08X ", &addr, &data);
//			row = insert_row(buf, row, 0x6, 0x40000000 | addr);
//			row = insert_row(buf, row, 0x7, data);
//			row = insert_row(buf, row, 0x6, 0xC0000000 | addr);
//			//printf("Write %08X to TX %04X\n", data, addr);
//		}
//		else if (line[0] == 'A') {
//			sscanf_s(line, "A %04X %08X ", &addr, &data);
//			row = insert_row(buf, row, 0x6, 0x00000000 | addr);
//			row = insert_row(buf, row, 0x7, data);
//			row = insert_row(buf, row, 0x6, 0x80000000 | addr);
//			//printf("Write %08X to AFE %04X\n", data, addr);
//		}
//		else if (line[0] == 'C') {  // CAPTURE
//			//wait(100);
//			row = insert_row(buf, row, 0x4, 0x01);
//			//write_rows(ept, buf, row);  // Send commands
//			//wait(100);
//			row = insert_row(buf, row, 0x4, 0x10);
//			//write_rows(ept, buf, row);  // Send commands
//			//wait(100);
//			row = insert_row(buf, row, 0x4, 0x00);
//			cudaBackEnd::ept_in->Abort();
//			cudaBackEnd::ept_in->Reset();
//			write_rows(cudaBackEnd::ept, buf, row);  // Send commands
//			wait(1);
//			if (read_chunk(cudaBackEnd::ept_in, recvbuf, rxlen)) {
//				short* rxdata = (short*)(recvbuf);
//				for (int i = 0; i < rxlen / 2; i++) {
//					if (rxdata[i] >= 512) rxdata[i] -= 1024;
//				}
//				// Trying to read only first N-1 rows and discard 1st sample
//				for (int i = 0; i < 64; i++) {
//					for (int j = 0; j < MAXROWS - 1; j++) {
//						//rximg[iteration][i][j] = rxdata[j*64+i+2];
//						cudaBackEnd::rximg2[i * MAXROWS + j] = rxdata[j * 64 + i + 2];
//					}
//				}
//				//saveToFile(iteration, rxlen, recvbuf);
//			}
//			else {
//				errcount++;
//			}
//			cudaMemcpy(cudaBackEnd::d_data, cudaBackEnd::rximg2, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels, cudaMemcpyHostToDevice);
//			beamformingLR3 << <(cudaBackEnd::pixels / 256) * cudaBackEnd::channels, 256 >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_tx_delay, cudaBackEnd::d_rx_delay, cudaBackEnd::d_data, cudaBackEnd::d_rx_apod, cudaBackEnd::samples, cudaBackEnd::pixels, iteration, cudaBackEnd::num_frames, cudaBackEnd::channels);
//			cudaGetLastError();
//			cudaDeviceSynchronize();
//			iteration++; // Increment iteration after saving to image
//			row = 0;   // Reset buffer for next iteration
//		}
//		else {
//			printf("Don't know how to handle [%s] yet.\n", line);
//		}
//	}
//
//	//// check for nan values,
//	isnan_test_array << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_bfHR, cudaBackEnd::pixels);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//	//////////// Bandpass filtering using shared memory /////////////////////
//	BPfilter1SharedMem << <(cudaBackEnd::pixels + TILE_SIZE - 1) / TILE_SIZE, TILE_SIZE >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_filt_coeff, cudaBackEnd::pixels, cudaBackEnd::d_bfHRBP);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//	//////////////// reshape of the beamformed data ///////////////
//	reshape_columnwise << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_bfHRBP);
//	cudaGetLastError();
//	cudaDeviceSynchronize();
//	cudaMemcpy(cudaBackEnd::env, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
//	//char fileout[200];
//	//sprintf(fileout, "sample_output\\b_mode_%d.csv", 1); //all the 16 inputs are arranged in a single file
//	//csv_write_mat(env, fileout, Nz, Nx);
//	double** outArray = convertsingto2darray(cudaBackEnd::env, cudaBackEnd::Nz, cudaBackEnd::Nx);
//
//	//// For next iteration
//	cudaMemset(cudaBackEnd::d_bfHR, 0, pixels * sizeof(float));
//
//	return outArray;
//}