#pragma once
// #define PI 3.14159
// #define TILE_SIZE 4
// #define MASK_WIDTH 364

//#include <cuda_runtime.h>
//#include <cufft.h>      /// Add "cufft.lib" in the linker input to use cufft. 
//#include "cuda.h"
//#include <windows.h>
//#include "device_launch_parameters.h"

/////BMode functions/////////////
__global__ void log_conv(float* data_hilbert, float* env, cufftComplex* d_input_value, int row_org, int col);

__global__ void db_conv(float* env, float max, int size, int dBvalue);

__global__ void point_wise_product(cufftComplex* a, int* b, int row_org, int col);

__global__ void real2complex(float* f, cufftComplex* fc, int N1, int N2);

/////////////////////////////////////////////////////////////////////////
void Generate_Pointwise_Coeff(int* pointwise_coeff, int size);

/////////////////////////////////////////////////////////////

__global__ void aperture_distance(float* mat1, float* mat2, int Nx, int channels, float* mat_out);

__global__ void apodization(float* distance, float* aperture, int Nz, int Nx, int channels, int pixels, float* apod);

// receive_delay calculation
__global__ void receive_delay(float* probe_ge_x, float* x_axis1, float* z_axis1, int channels, int Nx, int Nz, float del_convert, float* rx_delay);

__global__ void theta1(float* theta_active, float* theta, int frames, int N_active, int skip_frames);

// This function calculates TX central aperture position
__global__ void Tx_cen_pos(float* cen_pos, int N_elements, int N_active, float pitch, int skip_frames, int num_frames, float* probe);

//  transmit_delay calculation
__global__ void transmit_delay(float* x_axis1, float* z_axis1, float* k1, float zd, int Nx, int Nz, float del_convert, int num_frames, float* tx_delay);

__global__ void beamformingLR3(float* beamformed_data1, float* tx_delay, float* rx_delay, float* data, float* rx_apod, int samples, int pixels, int f, int num_frames, int channels);

__global__ void add_ele(float* data, int pixels, float* out_data);

__global__ void sample1(float* tx_delay, float* rx_delay, int pixels, int channels, float c, float sampling_frequency, float* data1, float* rx_apod, float* data, int samples, int columns);

__global__ void add_columns_matrix(float* data, int columns, int pixels, float* out_data);

__global__ void reshape_columnwise(int col, int row, float* beamformed_data_reshaped, float* d_bfHR);

__global__ void parallel_try(float* tx_delay, float* rx_delay, float sampling_frequency, float c, int samples,
	int channels, int columns, float* rx_apod, int pixels, float* data, float* beamformed_data);
