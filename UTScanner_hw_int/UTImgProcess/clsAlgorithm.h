#pragma once
#include <cstdlib>
#include <cstring>
using namespace std;
public class clsAlgorithm
{
    //float*** get3darray(int xdim, int ydim, int zdim) {

    //    float*** array3D = (float***)std::malloc(xdim * sizeof(float*));
    //    for (int i = 0; i < xdim; i++) {
    //        array3D[i] = (float**)std::malloc(ydim * sizeof(array3D[i]));
    //        for (int j = 0; j < ydim; j++) {
    //            array3D[i][j] = (float*)std::malloc(zdim * sizeof(array3D[i][j]));
    //        }
    //    }
    //    return array3D;
    //}

    //float** get2darray(int xdim, int ydim) {
    //    // printf("xdim  %d ydim %d ", xdim, ydim);
    //    float** array2D = (float**)std::malloc(xdim * sizeof(float*));
    //    for (int i = 0; i < xdim; i++) {
    //        array2D[i] = (float*)std::malloc(ydim * sizeof(array2D[i]));
    //        std::memset(array2D[i], 0, ydim * sizeof(array2D[i]));
    //    }

    //    return array2D;
    //}

    //void delete2darray(float** array, int xdim, int ydim) {
    //    for (int i = 0; i < xdim; i++) {
    //        delete[] array[i];
    //    }
    //    delete[] array;

    //}

    //void delete3darray(float*** array, int xdim, int ydim, int zdim) {
    //    for (int i = 0; i < ydim; i++) {
    //        for (int j = 0; j < zdim; j++) {
    //            delete[] array[i][j];
    //        }
    //    }
    //    for (int i = 0; i < ydim; i++) {
    //        delete[] array[i];
    //    }
    //    delete[] array;
    //}

};

