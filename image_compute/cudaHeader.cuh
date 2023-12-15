#pragma once
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>


namespace imageComputeCudaWrap {

	extern std::string cuMemInit();
	extern double** computeImg();

	extern int cuMemInitLinear();
	extern int cuMemInitCurv(double*);

	extern double** computeLinearImg();
	extern double** computeCurveImg(double*);


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

	void read_csv_mat(float* data, char* filename, int col1);

	void read_csv_mat(long double* data, char* filename, int col1);

	void read_csv_array(float* data, char* filename);

	__global__ void beamformingLR3(float* beamformed_data1, float* tx_delay, float* rx_delay, float* data, float* rx_apod, int samples, int pixels, int f, int num_frames, int channels);

	__global__ void isnan_test_array(float* data, int size);

	__global__ void BPfilter1SharedMem(float* in, float* filt_coeff, int pixels, float* y1);

	__global__ void reshape_columnwise(int col, int row, float* beamformed_data_reshaped, float* d_bfHR);

	void csv_write_mat(long double* a, const char* filename, int row1, int col1);		//writes data to memory

	void csv_write_mat(double* a, const char* filename, int row1, int col1);		//writes data to memory

	void csv_write_mat(float* a, const char* filename, int row1, int col1);	//for writing integer data "FUNCTION OVERLOADING"
}
