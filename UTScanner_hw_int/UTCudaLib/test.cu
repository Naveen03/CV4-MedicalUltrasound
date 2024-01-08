#include <cuda_runtime.h>
#include <cufft.h>      /// From "cufft.lib" 
#include "cuda.h"
#include <fstream>
#include "testheader.cuh"
#include "device_launch_parameters.h"


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

}

//  transmit_delay calculation
__global__ void transmit_delay(float* x_axis1, float* z_axis1, float* k1, float zd, int Nx, int Nz, float del_convert, int num_frames, float* tx_delay)
{

}

__global__ void beamformingLR3(float* beamformed_data1, float* tx_delay, float* rx_delay, float* data, float* rx_apod, int samples, int pixels, int f, int num_frames, int channels)
{

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

//void cudaBackEnd::read_csv_array_test(float* data, char* filename)
//	{
//		char buffer[6240];  //6240
//		char* token;
//		int i = 0;
//		FILE* file;
//
//		file = fopen(filename, "r");
//		if (file == NULL)
//		{
//			throw std::exception("File did not open");
//		}
//
//		while (fgets(buffer, sizeof(buffer), file) != 0)            // end-of-file indicator
//		{
//			token = strtok(buffer, ",");
//			//j = 0;
//			while (token != NULL)
//			{
//				data[i] = atof(token);     //converts the string argument str to float
//				token = strtok(NULL, ",");
//				//j++;
//			}
//
//			i++;
//		}
//		fclose(file);
//		// printf("Complete reading from file %s\n", filename);
//
//	}
//
//void cudaBackEnd::setMemmory(int a) {
//
//		read_csv_array_test(filt_coeff, "b_10M.csv");    // csv file read
//		cudaMalloc((void**)&d_filt_coeff, sizeof(float) * MASK_WIDTH);
//		cudaMemcpy(d_filt_coeff, filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);
//
//		mfile.open("sample_output/test.txt");
//		mfile << "Test OK" << std::endl;
//		mfile.close();
//
//	}

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

double** cudaBackEnd::convertsingto2darray(float* imgArray, int rows, int cols) {

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

int cudaBackEnd::num_threads = 1024;
int cudaBackEnd::N_active = 8;							// Active transmit elmeents
int cudaBackEnd::samples = 2040;						// # of samples in depth direction
int cudaBackEnd::N_elements = 128;						// # of transducer elements
float cudaBackEnd::rx_f_number = 2.0;
float cudaBackEnd::PI = 3.14;
float cudaBackEnd::sampling_frequency = 32e6;			// sampling frequency
float cudaBackEnd::c = 1540.0;							// speed of sound [m/s]	
float cudaBackEnd::pitch = 0.465 / 1000;				// spacing between the elements
float cudaBackEnd::aper_len = (N_elements - 1) * pitch * 1000;	//aperture foot print 
float cudaBackEnd::zd = pitch * N_active / (float)2;			// virtual src distance from transducer array 
float cudaBackEnd::sample_spacing = c / sampling_frequency / (float)2;
float cudaBackEnd::del_convert = sampling_frequency / c;		// used in delay calculation
float cudaBackEnd::rc = 60.1 / 1000;					// radius_of_curvature
float cudaBackEnd::scan_angle = (58 * PI) / 180;
int cudaBackEnd::channels = 128;						// number of A-lines data used for beamforming
int cudaBackEnd::Nx = 256;								// 256 Lateral spacing
int cudaBackEnd::Nz = 1024;								//1024 Axial spacing
int cudaBackEnd::pixels = Nz * Nx;
int cudaBackEnd::pix_cha = pixels * channels;			// Nz*Nx*128 This array size is used for Apodization
int cudaBackEnd::frames = 121;
int cudaBackEnd::num_frames = 121;						// number of low resolution images
int cudaBackEnd::skip_frames = 1;						// 
int cudaBackEnd::dBvalue = 60;

float* cudaBackEnd::filt_coeff = new float[364];
float* cudaBackEnd::env = new float[cudaBackEnd::pixels];
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
//float cudaBackEnd::rximg[128 * 2040] = { 0 };
float* cudaBackEnd::rximg = new float[cudaBackEnd::N_elements* cudaBackEnd::samples];
FILE* cudaBackEnd::fp = 0;

CCyUSBDevice* cudaBackEnd::USBDevice = new CCyUSBDevice(NULL);
CCyControlEndPoint* cudaBackEnd::ept = cudaBackEnd::USBDevice->ControlEndPt;
CCyBulkEndPoint* cudaBackEnd::ept_in = cudaBackEnd::USBDevice->BulkInEndPt;

int cudaBackEnd::initHW() 
{
	cudaBackEnd::USBDevice	= new CCyUSBDevice(NULL);
	cudaBackEnd::ept		= cudaBackEnd::USBDevice->ControlEndPt;
	cudaBackEnd::ept_in		= cudaBackEnd::USBDevice->BulkInEndPt;

	if (!cudaBackEnd::ept) {
		//printf("Could not get Control endpoint.\n");
		return 3;
	}

	if (!cudaBackEnd::ept_in) {
		//printf("No IN endpoint??\n");
		return 4;
	}

	// Send a vendor request (bRequest = 0x05) to the device
	cudaBackEnd::ept->Target	= TGT_DEVICE;
	cudaBackEnd::ept->ReqType	= REQ_VENDOR;
	cudaBackEnd::ept->Direction = DIR_TO_DEVICE;
	cudaBackEnd::ept->ReqCode	= 0x05;
	cudaBackEnd::ept->Value		= 1;
	cudaBackEnd::ept->Index		= 0;
	cudaBackEnd::ept->TimeOut	= 100;				// set timeout to 100ms for quick response

	cudaBackEnd::ept_in->MaxPktSize = 16384;
	cudaBackEnd::ept_in->TimeOut	= 100;			// set timeout to 100ms for readin

	return 0;
}

int cudaBackEnd::initSettingFile(const char* path)
{
	errno_t err;
	//FILE* fp;
	// path = "out25_curvi.txt"; for curvilieanr prob
	if ((err = fopen_s(&cudaBackEnd::fp, path, "r")) != 0) {
		//printf("Could not open config file for reading.\n");
		return 3;
	}

	return 0;
}

int cudaBackEnd::initGPUprobeC(double* prob_params) {

	const int MASK_WIDTH = 364;
	std::ofstream mFile;
	mFile.open("sample_output/testclass.txt");
	mFile << "OK" << std::endl;
	//------------------------------------

	try 
	{
		cudaBackEnd::PI = (float)prob_params[3];	//mFile2 << PI << std::endl;
		//const int MASK_WIDTH = (int)probPrms[4];// mFile2 << MASK_WIDTH << std::endl;
		//const int TILE_SIZE = (int)prob_params[5]; //mFile2 << TILE_SIZE << std::endl;
		cudaBackEnd::num_threads = (int)prob_params[6];		//mFile2 << num_threads << std::endl;
		cudaBackEnd::rx_f_number = (float)prob_params[7];	//mFile2 << rx_f_number << std::endl;
		cudaBackEnd::samples = (int)prob_params[8];		///mFile2 << samples << std::endl;
		cudaBackEnd::N_elements = (int)prob_params[9];		//mFile2 << N_elements << std::endl;
		cudaBackEnd::sampling_frequency = (float)prob_params[10]; ///mFile2 << sampling_frequency << std::endl;
		cudaBackEnd::c = (float)prob_params[11];	//mFile2 << c << std::endl;
		cudaBackEnd::N_active = (int)prob_params[12];		//mFile2 << N_active << std::endl;
		cudaBackEnd::channels = (int)prob_params[13];		//mFile2 << channels << std::endl;
		cudaBackEnd::Nx = (int)prob_params[14];		//mFile2 << Nx << std::endl;
		cudaBackEnd::Nz = (int)prob_params[15];		//mFile2 << Nz << std::endl;
		cudaBackEnd::frames = (int)prob_params[16];		//mFile2 << frames << std::endl;
		cudaBackEnd::num_frames = (int)prob_params[17];		//mFile2 << num_frames << std::endl;
		cudaBackEnd::skip_frames = (int)prob_params[18];
		cudaBackEnd::dBvalue = (int)prob_params[19];
		cudaBackEnd::pitch = (float)prob_params[20];
		cudaBackEnd::aper_len = (float)prob_params[21];
		cudaBackEnd::zd = (float)prob_params[22];
		cudaBackEnd::sample_spacing = (float)prob_params[23];
		cudaBackEnd::del_convert = (float)prob_params[24]; ;
		cudaBackEnd::rc = (float)prob_params[25];
		cudaBackEnd::scan_angle = (float)prob_params[26];
		cudaBackEnd::pixels = (int)prob_params[27];
		cudaBackEnd::pix_cha = (int)prob_params[28];

		char filename1[200];
		sprintf(filename1, "b_10M.csv");
		cudaBackEnd::read_csv_array(cudaBackEnd::filt_coeff, filename1);    // csv file read

		cudaMalloc((void**)&cudaBackEnd::d_filt_coeff, sizeof(float) * MASK_WIDTH);
		cudaMemcpy(cudaBackEnd::d_filt_coeff, filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);

		////////  Intialization &(or) Memory allocation  //////////////////
		cudaMalloc((void**)&cudaBackEnd::d_data, sizeof(float) * cudaBackEnd::samples * cudaBackEnd::channels);// variable to store raw rf data

		cudaMalloc((void**)&cudaBackEnd::d_bfHR, cudaBackEnd::pixels * sizeof(float)); // variable to store beamformed high-resolution beamformed image 
		cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));

		cudaMalloc((void**)&cudaBackEnd::dev_beamformed_data1, cudaBackEnd::pixels * sizeof(float));// variable to store reshaped beamformed data

		cudaMalloc((void**)&cudaBackEnd::d_bfHRBP, sizeof(float) * cudaBackEnd::pixels);// variable to store beamformed high-resolution bandpass filtered data

		/////////////////// theta positions for all elements ////////////////////
		cudaMalloc((void**)&cudaBackEnd::d_theta, cudaBackEnd::N_elements * sizeof(float));
		range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta, (-cudaBackEnd::scan_angle / 2), cudaBackEnd::N_elements, (cudaBackEnd::scan_angle / (cudaBackEnd::N_elements - 1)));


		///////////// theta for grid /////////////////  theta = -scan_angle / 2 : scan_angle / (elements - 1) : scan_angle / 2;
		cudaMalloc((void**)&cudaBackEnd::d_theta1, cudaBackEnd::Nx * sizeof(float));
		range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta1, (-cudaBackEnd::scan_angle / 2), cudaBackEnd::Nx, (cudaBackEnd::scan_angle / (cudaBackEnd::Nx - 1)));
		cudaGetLastError();
		cudaDeviceSynchronize();

		////////////// z value////////////////////
		float dz = cudaBackEnd::sample_spacing * cudaBackEnd::samples / cudaBackEnd::Nz;  // depth / (Nz - 1) / 1000;   // spacing in axial (z) direction in mm;
		cudaMalloc((void**)&cudaBackEnd::d_z_axis, cudaBackEnd::Nz * sizeof(float));
		range << <cudaBackEnd::Nz / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_z_axis, 0, cudaBackEnd::Nz, dz);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////////////////////////// x value////////////////////////////////
		float dx = aper_len / (Nx - 1);
		cudaMalloc((void**)&cudaBackEnd::d_x_axis, cudaBackEnd::Nx * sizeof(float));
		range << <cudaBackEnd::Nx / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, (-cudaBackEnd::aper_len / 2000), cudaBackEnd::Nx, dx / 1000);
		cudaGetLastError();
		cudaDeviceSynchronize();

		//////////////// Probe geometry, this info can be taken from transducer file ////////////////////
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
		cudaMalloc((void**)&cudaBackEnd::d_rx_ap_distance, cudaBackEnd::channels * cudaBackEnd::Nx * sizeof(float));  //20.087 us
		aperture_distance << <cudaBackEnd::Nx * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_x_axis, cudaBackEnd::d_probe, cudaBackEnd::Nx, cudaBackEnd::channels, cudaBackEnd::d_rx_ap_distance);
		cudaGetLastError();
		cudaDeviceSynchronize();

		///////////////////apodization/////////////////
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
		cudaMalloc((void**)&cudaBackEnd::d_rx_delay, cudaBackEnd::pix_cha * sizeof(float));
		receive_delay << < cudaBackEnd::pixels * cudaBackEnd::channels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta, cudaBackEnd::d_theta1, cudaBackEnd::rc, cudaBackEnd::d_z_axis, cudaBackEnd::channels, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::d_rx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();

		/////////////////// theta positions for all elements ////////////////////
		cudaMalloc((void**)&cudaBackEnd::d_theta_tx, cudaBackEnd::num_frames * sizeof(float));
		theta1 << < 1, cudaBackEnd::num_frames >> > (cudaBackEnd::d_theta_tx, cudaBackEnd::d_theta, cudaBackEnd::frames, cudaBackEnd::N_active, cudaBackEnd::skip_frames);

		/////////////////// Transmit delay calculation ////////////////////
		cudaMalloc((void**)&cudaBackEnd::d_tx_delay, cudaBackEnd::pixels * cudaBackEnd::num_frames * sizeof(float));
		//transmitter delay for 16 frames,  
		transmit_delay << < cudaBackEnd::pixels * cudaBackEnd::num_frames / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_theta1, cudaBackEnd::d_z_axis, cudaBackEnd::rc, cudaBackEnd::d_theta_tx, cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::del_convert, cudaBackEnd::num_frames, cudaBackEnd::zd, cudaBackEnd::d_tx_delay);
		cudaGetLastError();
		cudaDeviceSynchronize();

		cudaFree(cudaBackEnd::d_theta1);
		cudaFree(cudaBackEnd::d_probe);
		cudaFree(cudaBackEnd::d_x_axis);
		cudaFree(cudaBackEnd::d_z_axis);
		cudaFree(cudaBackEnd::d_theta_tx);

		zeroC(cudaBackEnd::rximg, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
	}
	catch(std::exception& e)
	{
		return 1;
	}

	return 0;

	mFile << "Memmory init completed" << std::endl;
	mFile.close();
}

double** cudaBackEnd::computeBModeImgC() {

	std::ofstream mFile;
	mFile.open("sample_output/testcomputeimg.txt");
	mFile << "OK" << std::endl;
	//------------------------

	errno_t err;
	char line[MAX_LINE]; // Max possible line length?
	FILE* fp;
	if ((err = fopen_s(&fp, "out25_curvi.txt", "r")) != 0) {
		//printf("Could not open config file for reading.\n");
		return nullptr;
	}
	mFile << "Read config files" << std::endl;
	//----------------------------

	CCyUSBDevice* USBDevice;	// H/W initilization1
	CCyControlEndPoint* ept;	// H/W initilization2
	CCyBulkEndPoint* ept_in;	// Endpoint for reading back data
	mFile << "h/w init done1" << std::endl;

	USBDevice = new CCyUSBDevice(NULL);
	// Obtain the control endpoint pointer
	ept = USBDevice->ControlEndPt;
	if (!ept) {
		printf("Could not get Control endpoint.\n");
		//return 1;
		return nullptr;
	}

	// Send a vendor request (bRequest = 0x05) to the device
	ept->Target = TGT_DEVICE;
	ept->ReqType = REQ_VENDOR;
	ept->Direction = DIR_TO_DEVICE;
	ept->ReqCode = 0x05;
	ept->Value = 1;
	ept->Index = 0;
	ept->TimeOut = 100;				// set timeout to 100ms for quick response
	
	mFile << "h/w init done3" << std::endl;

	ept_in = USBDevice->BulkInEndPt;
	if (!ept_in) {
		//printf("No IN endpoint??\n");
		return nullptr;
	}
	ept_in->MaxPktSize = 16384;
	ept_in->TimeOut = 100;			// set timeout to 100ms for readin

	//-------------------------------------

	int iteration = 0;
	int errcount = 0;
	int row = 0;					// Keep track of how many rows have been added

	const int MAX_LINE = 256;
	const int N_RX = 64;
	unsigned char buf[16 * 1024];

	unsigned int addr, data;
	unsigned char recvbuf[2048 * N_RX * 2];
	const int MAXROWS = 2040;
	LONG rxlen = MAXROWS * N_RX * 2;

	double** outArray; // holds 2d array with B-Mode image

	try
	{
		//unsigned int start = clock();
		while (fgets(line, cudaBackEnd::MAX_LINE, fp)) {
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

				//clock_t end = clock();
				//float elapsed_secs = float(end - begin) / CLOCKS_PER_SEC;
				//printf("Time for beamforming in ms: %f\n", elapsed_secs * 1000);

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
		char fileout[200];
		sprintf(fileout, "sample_output/b_curve_mode.csv"); //all the 16 inputs are arranged in a single file
		csv_write_mat(cudaBackEnd::env, fileout, cudaBackEnd::Nz, cudaBackEnd::Nx);

		mFile << "CSV written" << std::endl;

		outArray = convertsingto2darray(env, Nz, Nx);
	}
	catch (std::exception& e)
	{
		return nullptr;
	}

	mFile << "while loop completed" << std::endl;

	
	//////////////// Free cuda memory (that will be used again) ///////////////
	//cudaFree(cudaBackEnd::d_data);
	//cudaFree(cudaBackEnd::d_bfHR);
	//cudaFree(cudaBackEnd::d_tx_delay);
	//cudaFree(cudaBackEnd::d_rx_delay);
	//cudaFree(cudaBackEnd::d_rx_apod);
	//cudaFree(cudaBackEnd::dev_beamformed_data1);

	// For next iteration
	zeroC(cudaBackEnd::rximg, cudaBackEnd::samples* cudaBackEnd::N_elements);   // set rx_img array values to zero.
	cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));
	cudaMemset(cudaBackEnd::dev_beamformed_data1, 0, cudaBackEnd::pixels * sizeof(float));
	
	mFile.close();
	return outArray;
}

int cudaBackEnd::initGPUprobeL(double* prob_params)
{
	// perform b-mode generation here using cuda
	const int TILE_SIZE = prob_params[0];
	int MASK_WIDTH		= prob_params[1];
	const int MAX_LINE	= prob_params[2];


	cudaBackEnd::num_threads	= prob_params[3];
	cudaBackEnd::rx_f_number	= prob_params[4];	// Apodization parameters
	cudaBackEnd::samples		= prob_params[5];	// # of samples in depth direction
	cudaBackEnd::N_elements		= prob_params[6];	// # of transducer elements
	cudaBackEnd::sampling_frequency = prob_params[7];   // sampling frequency
	cudaBackEnd::c				= prob_params[8];	// speed of sound [m/s]	
	cudaBackEnd::N_active		= prob_params[9];   // Active transmit elmeents
	cudaBackEnd::pitch			= prob_params[10];	// spacing between the elements
	cudaBackEnd::aper_len		= prob_params[11];  // aperture foot print 
	cudaBackEnd::zd				= prob_params[12];  // virtual src distance from transducer array 
	cudaBackEnd::sample_spacing	= prob_params[13];
	cudaBackEnd::del_convert	= prob_params[14];  // used in delay calculation
	cudaBackEnd::channels		= prob_params[15];	// number of A-lines data used for beamforming
	cudaBackEnd::Nx				= prob_params[16];	// 256 Lateral spacing Beamforming "Grid" parameters
	cudaBackEnd::Nz				= prob_params[17];	// 1024 Axial spacing
	cudaBackEnd::pixels			= prob_params[18];
	cudaBackEnd::pix_cha		= prob_params[19];	// Nz*Nx*128 This array size is used for Apodization
	cudaBackEnd::num_frames		= prob_params[20];	// number of low resolution images
	cudaBackEnd::skip_frames	= prob_params[21];	//

	// Device and Host memmoey used in initializer
	// float* filt_coeff = new float[MASK_WIDTH];


	try
	{
		//////-<initializing memmory>-///////

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

		////////////Free cuda memory (one time use) ///////////////////////////
		cudaFree(d_probe);
		cudaFree(d_x_axis);
		cudaFree(d_z_axis);
		cudaFree(d_cen_pos);

	}

	catch (std::exception& e)
	{
		return 10;
	}

	return 0;

}

double** cudaBackEnd::computeBModeImgL()
{
	errno_t err;
	FILE* fp;
	if ((err = fopen_s(&fp, "out25.txt", "r")) != 0) {
		//printf("Could not open config file for reading.\n");
		//cv::imwrite("errorMat2.png", testMat0);
		exit(1);
	}
	//------------------------------------------

	// Send a vendor request (bRequest = 0x05) to the device
	cudaBackEnd::ept->Target = TGT_DEVICE;
	cudaBackEnd::ept->ReqType = REQ_VENDOR;
	cudaBackEnd::ept->Direction = DIR_TO_DEVICE;
	cudaBackEnd::ept->ReqCode = 0x05;
	cudaBackEnd::ept->Value = 1;
	cudaBackEnd::ept->Index = 0;
	cudaBackEnd::ept->TimeOut = 100;  // set timeout to 100ms for quick response

	cudaBackEnd::ept_in = USBDevice->BulkInEndPt;
	if (!cudaBackEnd::ept_in) {
		//printf("No IN endpoint??\n");
		exit(1);
	}
	cudaBackEnd::ept_in->MaxPktSize = 16384;
	cudaBackEnd::ept_in->TimeOut = 100;  // set timeout to 100ms for reading

	//-------------------------------------------

	const int TILE_SIZE = 4;
	int MASK_WIDTH		= 364;
	const int MAX_LINE	= 256; 
	static double pix2	= 0.0;
	unsigned char buf[16 * 1024];
	
	int row = 0;  // Keep track of how many rows have been added
	char line[MAX_LINE]; // Max possible line length?

	int iteration = 0;
	int errcount = 0;
	unsigned int addr, data;
	unsigned char recvbuf[2048 * 64 * 2];
	const int MAXROWS = 2040;
	LONG rxlen = MAXROWS * 64 * 2;

	zeroC(cudaBackEnd::rximg, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
	double** outArray;

	try
	{
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
				cudaBackEnd::ept_in->Abort();
				cudaBackEnd::ept_in->Reset();
				write_rows(ept, buf, row);  // Send commands
				wait(1);
				if (read_chunk(cudaBackEnd::ept_in, recvbuf, rxlen)) {
					short* rxdata = (short*)(recvbuf);
					for (int i = 0; i < rxlen / 2; i++) {
						if (rxdata[i] >= 512) rxdata[i] -= 1024;
					}
					// Trying to read only first N-1 rows and discard 1st sample
					for (int i = 0; i < 64; i++) {
						for (int j = 0; j < MAXROWS - 1; j++) {
							cudaBackEnd::rximg[i * MAXROWS + j] = rxdata[j * 64 + i + 2];
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
				iteration++; // Increment iteration after saving to image
				row = 0;   // Reset buffer for next iteration
			}
			else {
				printf("Don't know how to handle [%s] yet.\n", line);
			}
		}

		//// check for nan values,
		isnan_test_array << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::d_bfHR, cudaBackEnd::pixels);
		cudaGetLastError();
		cudaDeviceSynchronize();
		//////////// Bandpass filtering using shared memory /////////////////////
		BPfilter1SharedMem << <(cudaBackEnd::pixels + TILE_SIZE - 1) / TILE_SIZE, TILE_SIZE >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_filt_coeff, cudaBackEnd::pixels, cudaBackEnd::d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();
		//////////////// reshape of the beamformed data ///////////////
		reshape_columnwise << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_bfHRBP);
		cudaGetLastError();
		cudaDeviceSynchronize();
		cudaMemcpy(cudaBackEnd::env, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
		//char fileout[200];
		//sprintf(fileout, "b_mode_%d.csv", 1); //all the 16 inputs are arranged in a single file
		//csv_write_mat(env, fileout, Nz, Nx);
		// outMat = converttoMat(env, Nz, Nx);
		outArray = convertsingto2darray(cudaBackEnd::env, cudaBackEnd::Nz, cudaBackEnd::Nx);
	}
	catch (std::exception& e)
	{
		return nullptr;
	}

	// For next iteration
	zeroC(cudaBackEnd::rximg, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.
	cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));
	cudaMemset(cudaBackEnd::dev_beamformed_data1, 0, cudaBackEnd::pixels * sizeof(float));

	//////////////// Free cuda memory (that will be used again) ///////////////
	//cudaFree(d_data);
	//cudaFree(d_bfHR);
	//cudaFree(d_tx_delay);
	//cudaFree(d_rx_delay);
	//cudaFree(d_rx_apod);
	//cudaFree(dev_beamformed_data1);
	//cudaFree(d_bfHRBP);
	//cudaFree(d_filt_coeff);

	return outArray;
}

double** cudaBackEnd::computeBModeImg(int a) {

	std::ofstream mFile;
	mFile.open("sample_output/testcomputeimg.txt");
	mFile << "OK" << std::endl;

	//////////---<H/W INIT>---////////

	CCyUSBDevice* USBDevice;	// H/W initilization1
	CCyControlEndPoint* ept;	// H/W initilization2
	CCyBulkEndPoint* ept_in;	// Endpoint for reading back data
	USBDevice = new CCyUSBDevice(NULL);
	ept = USBDevice->ControlEndPt; // Obtain the control endpoint pointer
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
	ept_in = USBDevice->BulkInEndPt;
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

	mFile << "while loop completed" << std::endl;

	//////////// Bandpass filtering using shared memory /////////////////////
	BPfilter1SharedMem << <(cudaBackEnd::pixels + cudaBackEnd::TILE_SIZE - 1) / cudaBackEnd::TILE_SIZE, cudaBackEnd::TILE_SIZE >> > (cudaBackEnd::d_bfHR, cudaBackEnd::d_filt_coeff, cudaBackEnd::pixels, cudaBackEnd::d_bfHRBP);
	cudaGetLastError();
	cudaDeviceSynchronize();
	//////////////// reshape of the beamformed data ///////////////
	reshape_columnwise << <cudaBackEnd::pixels / cudaBackEnd::num_threads + 1, cudaBackEnd::num_threads >> > (cudaBackEnd::Nx, cudaBackEnd::Nz, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::d_bfHRBP);
	cudaGetLastError();
	cudaDeviceSynchronize();
	cudaMemcpy(cudaBackEnd::env, cudaBackEnd::dev_beamformed_data1, cudaBackEnd::Nz * cudaBackEnd::Nx * sizeof(float), cudaMemcpyDeviceToHost);
	char fileout[200];
	sprintf(fileout, "sample_output/b_curve_mode.csv"); //all the 16 inputs are arranged in a single file
	csv_write_mat(cudaBackEnd::env, fileout, cudaBackEnd::Nz, cudaBackEnd::Nx);

	mFile << "CSV written" << std::endl;

	double** outArray = convertsingto2darray(env, Nz, Nx);
	//////////////// Free cuda memory (that will be used again) ///////////////
	//cudaFree(cudaBackEnd::d_data);
	//cudaFree(cudaBackEnd::d_bfHR);
	//cudaFree(cudaBackEnd::d_tx_delay);
	//cudaFree(cudaBackEnd::d_rx_delay);
	//cudaFree(cudaBackEnd::d_rx_apod);
	//cudaFree(cudaBackEnd::dev_beamformed_data1);

	///////-<free up for next iteration>-/////////
	zeroC(cudaBackEnd::rximg, cudaBackEnd::samples * cudaBackEnd::N_elements);   // set rx_img array values to zero.

	cudaMemset(cudaBackEnd::d_bfHR, 0, cudaBackEnd::pixels * sizeof(float));
	cudaMemset(cudaBackEnd::dev_beamformed_data1, 0, cudaBackEnd::pixels * sizeof(float));

	mFile.close();
	return outArray;
}
