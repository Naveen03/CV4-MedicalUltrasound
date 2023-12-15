//#pragma once
//
///*
//int read_csv(float* data, char* filename, int col1)
//{
//	char buffer[6240];  //6240
//	char* token;
//
//	int i = 0, j = 0;
//	FILE* file;
//	file = fopen(filename, "r");
//	if (file == NULL)
//	{
//		printf("Can't open the file");
//	}
//	else
//	{
//		while (fgets(buffer, sizeof(buffer), file) != 0)            // end-of-file indicator
//		{
//			token = strtok(buffer, ",");
//			j = 0;
//			while (token != NULL)
//			{
//				data[i * col1 + j] = atof(token);     //converts the string argument str to float
//				token = strtok(NULL, ",");
//				j++;
//			}
//
//			i++;
//		}
//		fclose(file);
//		printf("Complete reading from file %s\n", filename);
//		return(i);
//	}
//}
//
//*/
//
//void read_csv_mat(float* data, char* filename, int col1);
//
//void read_csv_array(float* data, char* filename);
//
//void read_csv_mat(long double* data, char* filename, int col1);
//
//void csv_write_mat(long double* a, char* filename, int row1, int col1);		//writes data to memory
//
//
//void csv_write_mat(double* a, char* filename, int row1, int col1);		//writes data to memory
//
//
//void csv_write_mat(float* a, char* filename, int row1, int col1);	//for writing integer data "FUNCTION OVERLOADING"
//
//
////__host__ => to execute the function in the host
////__device__ => to execute the function in the device(GPU)
////__device__ => to execute the function in the device(GPU)
////__host__ __device__ =>executes in both host and device
//
//__host__ __device__ float max_val(float* data, int size1);	//To find max value from an array
//
//
//__host__ __device__ double max_val(double* data, int size1);	//To find max value from an array
//
//
//__host__ __device__ long double max_val(long double* data, int size1);	//To find max value from an array
//
//
//__host__ __device__ int index(float* data, float value, int size1);		//to find the index of a particular value in the array
//
//
//__host__ __device__ float element_add(float* data, int size1);		//element wise addition of array values
//
//
//__host__ __device__ void matrix_subset(float* mat, int row1, int col1, int c1, int c2, int r1, int r2, float* mat_out);
//
//
//__device__ __host__ void matrix_sub(float* mat1, float d0, int row1, float* out);		//subtract a value from the elements of an array
//
//
//__device__ __host__ void element_square_h(float* mat1, int size, float* matout);
//
//
//__device__ __host__ void element_mult_h(float* mat1, float* mat2, int size, float* matout);
//
//
//__host__ __device__ float one_skip_add(float* data, int end, int ind);		//element wise addition of array values
//
//
//__device__ __host__ void matrix_mul_h(float* mat1, float val, int size, float* matout);
