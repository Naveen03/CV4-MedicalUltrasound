
// // It reconstructs LR images separately and then add them to get HR image.
// Delay values and apodization are reshaped into [1 1024, 1 1024, ... pixels] ...
#include <stdlib.h>
#include <stdio.h>
#include <iomanip>
#include <ctime>
#include <math.h>
#include <string.h>
//#define PI 3.14159
//#define TILE_SIZE 4
//#define MASK_WIDTH 364

// includes, project
#include <cuda_runtime.h>
#include <cufft.h>      /// Add "cufft.lib" in the linker input to use cufft. 
#include "cuda.h"
#include <windows.h>
#include "device_launch_parameters.h"
#include "device_func1.h"
#include "host_func1.h"
#include "beamforming_func1.h"

// include OpenCV Header
#include <opencv2/opencv.hpp>
#include <opencv2/highgui.hpp>
#include "mat_operations.h"


/////BMode functions/////////////
__global__ void log_conv(float* data_hilbert, float* env, cufftComplex* d_input_value, int row_org, int col)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	int j = threadIdx.y + blockIdx.y * blockDim.y;
	int index = j * col + i;

	if (i < col && j < row_org)
	{
		// divide by 'size' is to ensure that the FFT equation holds good.
		//real_d_input_value = (d_input_value[i].x / (float)size);   // Extract real value
		float real = d_input_value[index].x / ((float)row_org * (float)col);
		float img = d_input_value[index].y / ((float)row_org * (float)col);
		data_hilbert[index] = fabs(sqrt((real * real) + (img * img))); // Absolute value

		env[index] = 20 * log10(data_hilbert[index]);     // log compression

	}
}

__global__ void db_conv(float* env, float max, int size, int dBvalue)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	if (i < size)
	{

		env[i] = env[i] - max;     //env_dB = env_dB - max(max(env_dB));                                    // Normalization
		env[i] = (float)127.0 * (env[i] + (float)dBvalue) / (float)dBvalue;              // dB conversion
	}
}

__global__ void point_wise_product(cufftComplex* a, int* b, int row_org, int col)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	int j = blockDim.y * blockIdx.y + threadIdx.y;

	if ((i < col) && (j < row_org))
	{
		a[j * col + i].x = a[j * col + i].x * b[j];
		a[j * col + i].y = a[j * col + i].y * b[j];
	}
}

__global__ void real2complex(float* f, cufftComplex* fc, int N1, int N2)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	int j = threadIdx.y + blockIdx.y * blockDim.y;
	int index = j * N2 + i;

	if (i < N2 && j < N1)
	{
		fc[index].x = f[index];
		fc[index].y = 0.0f;

	}

}

/////////////////////////////////////////////////////////////////////////
void Generate_Pointwise_Coeff(int* pointwise_coeff, int size)
{
	if ((size % 2) == 0)
	{
		pointwise_coeff[0] = 1;
		pointwise_coeff[size / 2] = 1;

		for (unsigned int i = 1; i < size / 2; i++)
		{
			pointwise_coeff[i] = 2;
		}
		for (unsigned int i = (size / 2) + 1; i < size; i++)
		{
			pointwise_coeff[i] = 0;
		}
	}
	else
	{
		pointwise_coeff[0] = 1;
		//pointwise_coeff[size / 2] = 1;

		for (unsigned int i = 1; i <= size / 2; i++)
		{
			pointwise_coeff[i] = 2;
		}
		for (unsigned int i = (size / 2) + 1; i < size; i++)
		{
			pointwise_coeff[i] = 0;
		}
	}

}
/////////////////////////////////////////////////////////////

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

//__global__ void apodization(float* distance, float* aperture, int Nz, int Nx, int channels, int pixels, float* apod)
//{
//	int x = blockDim.x * blockIdx.x + threadIdx.x;
//	int i = x / Nz;
//	int j = x % Nz;
//
//	if (x < Nz * Nx)
//	{
//		for (int k = 0; k < channels; k++)
//		{
//			bool temp = distance[i * channels + k] <= (aperture[j] / 2);
//			apod[x * channels + k] = temp * (0.5 + 0.5 * cos(2 * PI * distance[i * channels + k] / aperture[j]));
//		}
//		bool temp = distance[i * channels + k] <= (aperture[j] / 2.0);
//		apod[x] = temp * (double)(0.5 + 0.5 * cos(2 * PI * distance[i * channels + k] / aperture[j]));
//	}
//}

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

__global__ void theta1(float* theta_active, float* theta, int frames, int N_active, int skip_frames)
{

	int x = threadIdx.x;
	int f = 0;
	for (int i = 1; i <= frames; i += skip_frames)
	{
		theta_active[f] = theta[i - 1];
		f++;
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

void read_csv_array(float* data, char* filename)
{
	char buffer[6240];  //6240
	char* token;

	int i = 0;// , j = 0;
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

void csv_write_mat(long double* a, char* filename, int row1, int col1)		//writes data to memory
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

void csv_write_mat(double* a, char* filename, int row1, int col1)		//writes data to memory
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

void csv_write_mat(float* a, char* filename, int row1, int col1)	//for writing integer data "FUNCTION OVERLOADING"
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

//__host__ => to execute the function in the host
//__device__ => to execute the function in the device(GPU)
//__device__ => to execute the function in the device(GPU)
//__host__ __device__ =>executes in both host and device

__host__ __device__ float max_val(float* data, int size1)	//To find max value from an array
{
	float max = 0;
	float temp;
	for (int i = 0; i < size1; i++)
	{
		if (data[i] > max)
		{
			temp = data[i];
			max = temp;
		}
	}
	return max;
}

__host__ __device__ double max_val(double* data, int size1)	//To find max value from an array
{
	double max = data[0];
	double temp;
	for (int i = 0; i < size1; i++)
	{
		if (data[i] > max)
		{
			temp = data[i];
			max = temp;
		}
	}
	return max;
}

__host__ __device__ long double max_val(long double* data, int size1)	//To find max value from an array
{
	long double max = data[0];
	long double temp;
	for (int i = 0; i < size1; i++)
	{
		if (data[i] > max)
		{
			temp = data[i];
			max = temp;
		}
	}
	return max;
}

__host__ __device__ int index(float* data, float value, int size1)		//to find the index of a particular value in the array
{
	int ind = 0;
	for (int i = 0; i < size1; i++)
	{
		if (data[i] == value)
		{
			ind = i;
			break;
		}
	}
	return ind;
}

__host__ __device__ float element_add(float* data, int size1)		//element wise addition of array values
{
	float value = 0;
	for (int i = 0; i < size1; i++)
	{
		value = value + data[i];
	}
	return value;
}

__host__ __device__ void matrix_subset(float* mat, int row1, int col1, int c1, int c2, int r1, int r2, float* mat_out)
{
	for (int idy = 0; idy < (r2 - r1) + 1; idy++)			//matrix sub set generation from a large matrix (ref:"device_func.h")
	{
		for (int idx = 0; idx < ((c2 - c1) + 1); idx++)
		{
			int thread_id = idy * ((c2 - c1) + 1) + idx;
			int thread_id1 = (idy + r1) * col1 + (idx + c1);
			mat_out[thread_id] = mat[thread_id1];
		}
	}
}

__device__ __host__ void matrix_sub(float* mat1, float d0, int row1, float* out)		//subtract a value from the elements of an array
{
	for (int idx = 0; idx < row1; idx++)
	{
		out[idx] = mat1[idx] - d0;
	}
}

__device__ __host__ void element_square_h(float* mat1, int size, float* matout)
{
	for (int idx = 0; idx < size; idx++)
	{
		matout[idx] = mat1[idx] * mat1[idx];
	}
}

__device__ __host__ void element_mult_h(float* mat1, float* mat2, int size, float* matout)
{
	for (int idx = 0; idx < size; idx++)
	{
		matout[idx] = mat1[idx] * mat2[idx];
	}
}

__host__ __device__ float one_skip_add(float* data, int end, int ind)		//element wise addition of array values
{
	float value = 0;
	for (int i = ind; i < end; i++)
	{
		value = value + data[i];
	}
	return value;
}

__device__ __host__ void matrix_mul_h(float* mat1, float val, int size, float* matout)
{
	for (int idx = 0; idx < size; idx++)
	{
		matout[idx] = mat1[idx] * val;
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

__global__ void zeros(float* ap_dis, int row1)
{
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	//int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < row1)
	{
		ap_dis[x] = 0;
	}

}

__global__ void zeros(double* ap_dis, int row1)
{
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	//int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < row1)
	{
		ap_dis[x] = 0;
	}

}

__global__ void zeros(long double* ap_dis, int row1)
{
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	//int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < row1)
	{
		ap_dis[x] = 0;
	}

}

__global__ void isnan_test(float* data, int col1, int row1)
{


	int idx = threadIdx.x + blockDim.x * blockIdx.x;

	while (idx < col1) {
		for (int i = 0; i < row1; i++)
		{
			if (isnan(data[(i * col1) + idx]) == 1)
				data[(i * col1) + idx] = 0;
		}

		idx += gridDim.x + blockDim.x;
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

__global__ void down_sampling(float* down_data, float* data, int down_size, int down_val, int col)	//device function for downsampling
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;							//down_size=no.of rows after downsampling
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idy < down_size && idx < col)
	{
		down_data[idy * col + idx] = data[down_val * idy * col + idx];	//down_val=down sampling factor
	}
}

__global__ void down_col(float* down_data, float* data, int down_col_size, int down_val, int col_size, int row)	//device function for downsampling
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;							//down_size=no.of rows after downsampling
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idy < row && idx < down_col_size)
	{
		down_data[idy * down_col_size + idx] = data[idy * col_size + idx * down_val];	//down_val=down sampling factor
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

__global__ void mat2D_abs(int* data, int m, int n, int* out_data)	//to find the absolute positive value of each elements in a matrix

{
	int col1 = blockDim.x * blockIdx.x + threadIdx.x;			//m and n are number of rows and colums respectively
	int row1 = blockDim.y * blockIdx.y + threadIdx.y;

	if (row1 < m && col1 < n)
	{
		int thread_id = row1 * n + col1;
		if (data[thread_id] < 0)
		{
			out_data[thread_id] = -1 * data[thread_id];		//negative values are converted to positive values
		}
		else
		{
			out_data[thread_id] = data[thread_id];
		}
	}
}

__global__ void mat2D_abs(float* data, int m, int n, float* out_data)	//to find the absolute positive value of each elements in a matrix

{
	int col1 = blockDim.x * blockIdx.x + threadIdx.x;			//m and n are number of rows and colums respectively
	int row1 = blockDim.y * blockIdx.y + threadIdx.y;

	if (row1 < m && col1 < n)
	{
		int thread_id = row1 * n + col1;
		if (data[thread_id] < 0)
		{
			out_data[thread_id] = -1 * data[thread_id];		//negative values are converted to positive values
		}
		else
		{
			out_data[thread_id] = data[thread_id];
		}
	}
}

__global__ void mat_sub(float* mat1, float d0, int row1, float* out)	//to subtract a specific value from each element in the array
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;

	if (idx < row1)
	{
		out[idx] = mat1[idx] - d0;		//d0=value to be subtracted
	}
}

__global__ void mat_subset(float* mat, int row1, int col1, int c1, int c2, int r1, int r2, float* mat_out)	//to take a matrix subset from a large matrix
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;	//row1 and col1 are size of large matrix
	int idy = blockIdx.y * blockDim.y + threadIdx.y;	//(r1,c1) (r2,c2)=min and max cordinates of the sub matrix
	if (idx < ((c2 - c1) + 1) && idy < ((r2 - r1) + 1))
	{
		int thread_id = idy * ((c2 - c1) + 1) + idx;
		int thread_id1 = (idy + r1) * col1 + (idx + c1);
		mat_out[thread_id] = mat[thread_id1];
	}
}

__global__ void mat_subset(int* mat, int row1, int col1, int c1, int c2, int r1, int r2, int* mat_out)	//to take a matrix subset from a large matrix
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;	//row1 and col1 are size of large matrix
	int idy = blockIdx.y * blockDim.y + threadIdx.y;	//(r1,c1) (r2,c2)=min and max cordinates of the sub matrix
	if (idx < ((c2 - c1) + 1) && idy < ((r2 - r1) + 1))
	{
		int thread_id = idy * ((c2 - c1) + 1) + idx;
		int thread_id1 = (idy + r1) * col1 + (idx + c1);
		mat_out[thread_id] = mat[thread_id1];
	}
}

__global__ void element_square(float* mat, int size, float* out)	//to square each contents of a array
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < size)
	{
		out[idx] = mat[idx] * mat[idx];
	}
}

__global__ void element_mul(float* mat1, float* mat2, int size, float* out)	//element wise multiplication of 2 arrays
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < size)
	{
		out[idx] = mat1[idx] * mat2[idx];
	}
}

__global__ void mat_add(float* mat1, float* mat2, int row1, int col1)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;
	if (idx < col1 && idy < row1)
	{
		mat2[idy * col1 + idx] = mat1[idy * col1 + idx] + mat2[idy * col1 + idx];
	}
}

__global__ void array_add(double* mat1, double* mat2, int row1)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;

	if (idx < row1)
	{
		mat2[idx] = mat1[idx] + mat2[idx];
	}
}

__global__ void mat_subset_1D(int* mat, int size, int first, int last, int* mat_out)	//to take a matrix subset from a large matrix
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;	//row1 and col1 are size of large matrix
	//int idy = blockIdx.y * blockDim.y + threadIdx.y;	//(r1,c1) (r2,c2)=min and max cordinates of the sub matrix
	if (idx < ((last - first) + 1))
	{
		int thread_id = idx;
		int thread_id1 = idx + first;
		mat_out[thread_id] = mat[thread_id1];
	}
}

__global__ void mat_subset_1D(float* mat, int size, int first, int last, float* mat_out)	//to take a matrix subset from a large matrix
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;	//row1 and col1 are size of large matrix
	//int idy = blockIdx.y * blockDim.y + threadIdx.y;	//(r1,c1) (r2,c2)=min and max cordinates of the sub matrix
	if (idx < ((last - first) + 1))
	{
		int thread_id = idx;
		int thread_id1 = (idx + first);
		mat_out[thread_id] = mat[thread_id1];
	}
}

__global__ void matrix_mult(float* mat1, float val, int size, float* out)	//element wise multiplication of 2 arrays
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < size)
	{
		out[idx] = mat1[idx] * val;
	}
}

__global__ void matrix_mult1(float* mat1, float val, int size, float* out)	//element wise multiplication of 2 arrays
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx < size)
	{
		out[idx] = mat1[idx] * val;
	}
}

__global__ void upsamp_append(float* mat_out, float* mat_in, int first_row, int samp_fact, int row1, int col1)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idy < row1 && idx < col1)
	{
		mat_out[(samp_fact * idy + first_row) * col1 + idx] = mat_in[idy * col1 + idx];
	}
}

__global__ void mat_transpose(float* mat_in, float* mat_out, int row_org, int col_org)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idx < col_org && idy < row_org)
	{
		mat_out[idx * row_org + idy] = mat_in[idy * col_org + idx];
	}
}

float** reshapeto2d(float* inArray, int rows, int cols) {
	// Conevert the single array of size rows*col into 2 dimensional array of size rows and col
	// Declare new Array
	float** array2D = (float**)malloc(sizeof(float) * cols);
	for (int i= 0; i < cols; i++) {
		array2D[i] = (float*)malloc(rows);
	}

	// Fill the values
	for (int i = 0; i < cols; i++) {
		for (int j = 0; j < rows; j++) {
			array2D[i][j] = inArray[i * rows + j];
		}
	}

	return array2D;
}


// Extern void bModeGenerationinCUDA(float* t, float* v, int tno)
cv::Mat bModeGen()
{  
	// perform b-mode generation here using cuda
	
	const int TILE_SIZE = 4;
	int MASK_WIDTH = 364;
	//// Computer (NIVIDIA) parametrs
	int num_threads = 1024;

	/// Apodization parameters
	float rx_f_number = 2.0;

	/////// Ultrasound scanner parametrs
	//float depth = 49.28;      // Depth of imaging in mm
	int samples = 2008;                    // # of samples in depth direction
	int N_elements = 64;         // # of transducer elements
	float sampling_frequency = 32e6;   // sampling frequency
	float c = 1540.0;      // speed of sound [m/s]	
	int N_active = 8;                         // Active transmit elmeents
	float pitch = 0.3 / 1000;           // spacing between the elements
	float aper_len = (N_elements - 1) * pitch * 1000;			 //aperture foot print 
	float zd = pitch * N_active / (float)2;            // virtual src distance from transducer array 
	float sample_spacing = c / sampling_frequency / (float)2;
	float del_convert = sampling_frequency / c;  // used in delay calculation

	int channels = 64;	              // number of A-lines data used for beamforming

	//// Beamforming "Grid" parameters
	int Nx = 256;      // 256 Lateral spacing
	int Nz = 1024;            //1024 Axial spacing
	int pixels = Nz * Nx;
	int pix_cha = pixels * channels;     // Nz*Nx*128 This array size is used for Apodization
	int num_frames = 57;   // number of low resolution images
	int skip_frames = 1;  // 

	// Post processing parameters.
	//int dBvalue = 60;

	float* filt_coeff = new float[MASK_WIDTH];
	char filename1[200];
	sprintf(filename1, "C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/b_10M.csv"); 
	read_csv_array(filt_coeff, filename1);    // csv file read

	float* d_filt_coeff = 0;
	cudaMalloc((void**)&d_filt_coeff, sizeof(float) * MASK_WIDTH);
	cudaMemcpy(d_filt_coeff, filt_coeff, sizeof(float) * MASK_WIDTH, cudaMemcpyHostToDevice);


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
	cudaMalloc((void**)&d_x_axis, Nx * sizeof(float));    // 167.939 us
	range << <Nx / num_threads + 1, num_threads >> > (d_x_axis, (-aper_len / 2000), Nx, dx / 1000);
	cudaGetLastError();
	cudaDeviceSynchronize();

	//////////////// Probe geometry, this info can be taken from transducer file ////////////////////
	float* d_probe = 0;
	cudaMalloc((void**)&d_probe, N_elements * sizeof(float));
	range << <1, N_elements >> > (d_probe, (-aper_len / 2000), N_elements, pitch);
	cudaGetLastError();
	cudaDeviceSynchronize();

	/////////////////rx aperture calculation using Fnumber///////////////////////////////
	// rx_aper=rfsca.z/rf_number
	float* d_rx_aperture = 0;
	cudaMalloc((void**)&d_rx_aperture, Nz * sizeof(float));
	element_division << <Nz / num_threads + 1, num_threads >> > (d_z_axis, rx_f_number, Nz, d_rx_aperture);
	cudaGetLastError();
	cudaDeviceSynchronize();

	////////////////////////rx aerture distance////////
	float* d_rx_ap_distance = 0;
	cudaMalloc((void**)&d_rx_ap_distance, channels * Nx * sizeof(float));
	aperture_distance << <Nx * channels / num_threads + 1, num_threads >> > (d_x_axis, d_probe, Nx, channels, d_rx_ap_distance);
	cudaGetLastError();
	cudaDeviceSynchronize();

	///////////////////apodization/////////////////
	float* d_rx_apod = 0;
	cudaMalloc((void**)&d_rx_apod, sizeof(float) * Nz * channels * Nx);
	apodization << <pixels * channels / num_threads + 1, num_threads >> > (d_rx_ap_distance, d_rx_aperture, Nz, Nx, channels, pixels, d_rx_apod);
	cudaGetLastError();
	cudaDeviceSynchronize();

	cudaFree(d_rx_aperture);
	cudaFree(d_rx_ap_distance);

	/////////////////// calculate central positions transmit subaperture ////////////////////
	float* d_cen_pos = 0;
	cudaMalloc((void**)&d_cen_pos, num_frames * sizeof(float));
	Tx_cen_pos << < 1, num_frames >> > (d_cen_pos, N_elements, N_active, pitch, skip_frames, num_frames, d_probe);

	/////////////receive delay calculation /////////////////////////////////////////////
	float* d_rx_delay = 0;
	cudaMalloc((void**)&d_rx_delay, pix_cha * sizeof(float));
	receive_delay << < pixels * channels / num_threads + 1, num_threads >> > (d_probe, d_x_axis, d_z_axis, channels, Nx, Nz, del_convert, d_rx_delay);
	cudaGetLastError();
	cudaDeviceSynchronize();

	////////////Initialize d_bfHR to store final high-resolution beamformed image /////////////////////////////
	float* d_bfHR = 0;
	cudaMalloc((void**)&d_bfHR, pixels * sizeof(float));
	//zeros << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);  
	cudaMemset(d_bfHR, 0, pixels * sizeof(float));

	/////////////////// Transmit delay calculation ////////////////////
	float* d_tx_delay = 0;
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

	float* data = new float[samples * channels];

	float* d_data = 0;
	cudaMalloc((void**)&d_data, sizeof(float) * samples * channels);


	for (int f = 0; f < num_frames; f++)
	{
		char filename[200];
		sprintf(filename, "C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/inputs/raw_rf_dbsat_Ptsca_arr_%d.csv", f); //all the LR inputs are arranged in a single file

		read_csv_mat(data, filename, 1);    // csv file read

		clock_t begin = clock();   // clock intiated

		cudaMemcpy(d_data, data, sizeof(float) * samples * channels, cudaMemcpyHostToDevice);

		beamformingLR3 << <(pixels / 256) * channels, 256 >> > (d_bfHR, d_tx_delay, d_rx_delay, d_data, d_rx_apod, samples, pixels, f, num_frames, channels);
		cudaGetLastError();
		cudaDeviceSynchronize();

		clock_t end = clock();
		float elapsed_secs = float(end - begin) / CLOCKS_PER_SEC;
		printf("Time for beamforming in ms: %f\n", elapsed_secs * 1000);

	}

	//// check for nan values,
	isnan_test_array << <pixels / num_threads + 1, num_threads >> > (d_bfHR, pixels);
	cudaGetLastError();
	cudaDeviceSynchronize();

	float* d_bfHRBP = 0;  // variable to store beamformed high-resolution bandpass filtered data
	cudaMalloc((void**)&d_bfHRBP, sizeof(float) * pixels);

	//////////// Bandpass filtering using shared memory /////////////////////
	BPfilter1SharedMem << <(pixels + TILE_SIZE - 1) / TILE_SIZE, TILE_SIZE >> > (d_bfHR, d_filt_coeff, pixels, d_bfHRBP);
	cudaGetLastError();
	cudaDeviceSynchronize();

	//////////////// reshape of the beamformed data ///////////////
	float* dev_beamformed_data1 = 0;
	cudaMalloc((void**)&dev_beamformed_data1, pixels * sizeof(float));   //234.130 us
	reshape_columnwise << <pixels / num_threads + 1, num_threads >> > (Nx, Nz, dev_beamformed_data1, d_bfHRBP);  //48.864 us
	cudaGetLastError();
	cudaDeviceSynchronize();

	float* env = new float[pixels];
	cudaMemcpy(env, dev_beamformed_data1, Nz * Nx * sizeof(float), cudaMemcpyDeviceToHost);
	char* fileout = "C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/outputs/b_mode.csv";
	csv_write_mat(env, fileout, Nz, Nx);

	//float** bmode2d = reshapeto2d(env, Nz, Nx); // gives error
	cv::Mat bmodMat = cv::Mat::zeros(Nz, Nx, CV_32FC1);
	// cv::Mat bmodMat = converttoMat(env, Nz, Nx);

	//////////////// Free cuda memory (that will be used again) ///////////////
	cudaFree(d_data);
	cudaFree(d_bfHR);
	cudaFree(d_tx_delay);
	cudaFree(d_rx_delay);
	cudaFree(d_rx_apod);
	cudaFree(dev_beamformed_data1);
	cudaFree(d_bfHRBP);

	return bmodMat;
}

//extern void imageGenProcessinCUDA() {
//
//	// B-Mode image generation code fully in CUDA
//	double minP, maxP;
//	cv::Mat bmodMat = bModeGen();
//	cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/outputs/bmodMat.png", bmodMat);
//	std::cout << "size of bmodMat : " << bmodMat.rows << " , " << bmodMat.cols << std::endl;
//
//	cv::Mat envolepMat = hilbertTrans4(bmodMat, 1.0);
//	cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/outputs/envolepMat.png", envolepMat);
//	cv::minMaxIdx(envolepMat, &minP, &maxP);
//	std::cout << "range of bmodeMat before log compression: " << minP << " ->" << maxP << std::endl;
//	std::cout << "size of envolepMat : " << envolepMat.rows << " , " << envolepMat.cols << std::endl;
//
//	// perform image processing 
//	cv::Mat deSpeckledimg;
//	DeSpeckle deNoiseImg(envolepMat);
//	deNoiseImg.applySRAD(envolepMat, deSpeckledimg, 1, 10, 0.25, false, false);
//	cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/outputs/dspeckledimg.png", deSpeckledimg);
//	cv::minMaxIdx(deSpeckledimg, &minP, &maxP);
//	std::cout << "range of deSpeckledimg : " << minP << " ->" << maxP << std::endl;
//
//	// // log compression
//	//cv::Mat logcMat = logTransform(envolepMat);
//	//cv::imwrite("./outputs/logcMat.png", logcMat);
//	//cv::minMaxIdx(logcMat, &minP, &maxP);
//	//std::cout << "range of bmodeMat after log compression1: " << minP << " ->" << maxP << std::endl;
//
//	cv::Mat rangedMat = dynamicRangeAdjust(deSpeckledimg, 100.0);
//	cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/outputs/rangedMat.png", rangedMat);
//	cv::minMaxIdx(rangedMat, &minP, &maxP);
//	std::cout << "range of bmodeMat after range adjust: " << minP << " ->" << maxP << std::endl;      
//
//	cv::Mat displayMat = displayRangeAdjust(rangedMat);
//	cv::minMaxIdx(displayMat, &minP, &maxP);
//	std::cout << "range of bmodeMat after disply range adjust: " << minP << " ->" << maxP << std::endl;
//	cv::imwrite("C:/Users/navee/Documents/projects/USI_processing/BmodeinCUDA/copy/CudaRuntime/outputs/b_mode_w_speckle_Red.png", displayMat);
//	//cv::imshow("B-mode image", displayMat);
//	//cv::waitKey();
//}
