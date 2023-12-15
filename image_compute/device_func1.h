//#pragma once
//
//// #define PI 3.14159
//// #define TILE_SIZE 4
//// #define MASK_WIDTH 364
//
//
//__global__ void BPfilter1SharedMem(float* , float* , int , float* );
//
//__global__ void zeros(float* , int );
//
//__global__ void zeros(double* , int );
//
//__global__ void zeros(long double* , int );
//
//__global__ void isnan_test(float* , int , int );
//
//__global__ void isnan_test_array(float*, int );
//
//__global__ void down_sampling(float* down_data, float* data, int down_size, int down_val, int col);	//device function for downsampling
//
//__global__ void down_col(float* down_data, float* data, int down_col_size, int down_val, int col_size, int row);	//device function for downsampling
//
//__global__ void element_division(float* mat_in, float value, int size, float* mat_out);
//
//__global__ void element_division(long double* mat_in, float value, int size, long double* mat_out);
//
//__global__ void range(int* out_data, int min, int arr_size, int inc);	//creates an array of a range of values
//
//__global__ void range(float* out_data, float min, int arr_size, float inc);	//creates an array of a range of values
//
//__global__ void range(double* out_data, double min, int arr_size, double inc);	//creates an array of a range of values
//
//__global__ void range(long double* out_data, long double min, int arr_size, long double inc);	//creates an array of a range of values
//
//__global__ void mat2D_abs(int* data, int m, int n, int* out_data);	//to find the absolute positive value of each elements in a matrix
//
//__global__ void mat2D_abs(float* data, int m, int n, float* out_data);	//to find the absolute positive value of each elements in a matrix
//
//__global__ void mat_sub(float* mat1, float d0, int row1, float* out);	//to subtract a specific value from each element in the array
//
//__global__ void mat_subset(float* mat, int row1, int col1, int c1, int c2, int r1, int r2, float* mat_out);	//to take a matrix subset from a large matrix
//
//__global__ void mat_subset(int* mat, int row1, int col1, int c1, int c2, int r1, int r2, int* mat_out);	//to take a matrix subset from a large matrix
//
//__global__ void element_square(float* mat, int size, float* out);	//to square each contents of a array
//
//__global__ void element_mul(float* mat1, float* mat2, int size, float* out);	//element wise multiplication of 2 arrays
//
//__global__ void mat_add(float* mat1, float* mat2, int row1, int col1);
//
//__global__ void array_add(double* mat1, double* mat2, int row1);
//
//__global__ void mat_subset_1D(int* mat, int size, int first, int last, int* mat_out);	//to take a matrix subset from a large matrix
//
//__global__ void mat_subset_1D(float* mat, int size, int first, int last, float* mat_out);	//to take a matrix subset from a large matrix
//
//__global__ void matrix_mult(float* mat1, float val, int size, float* out);	//element wise multiplication of 2 arrays
//
//__global__ void matrix_mult1(float* mat1, float val, int size, float* out);	//element wise multiplication of 2 arrays
//
//__global__ void upsamp_append(float* mat_out, float* mat_in, int first_row, int samp_fact, int row1, int col1);
//
//__global__ void mat_transpose(float* mat_in, float* mat_out, int row_org, int col_org);