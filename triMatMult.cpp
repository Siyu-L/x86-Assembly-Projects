/*
Siyu Li
*/

#include <iostream>
#include <fstream>
#include <string>
using namespace std;


//Returns the column at col_index from arr[]
//NOTE: only works if arr[] is in the compressed form of the 2d upper triangular matrix
int* get_column(int arr[], int column[], int dim, int col_index) {

    //loop for every element in the column
    for(int i = 0; i<(col_index + 1); i++) {
        int j = 0;
        int index = col_index; //index represents the index of the desired element in arr
        
        /*j counts the number of zeros in the row
        First row has no zeros, 2nd row has 1 zero, 3rd row has 2 zeros, etc.
        The index for each element in the column is usually given by 
            index = col_index + dim(row_index)
        however, since no 0s are stored, we must subtract those positions of zero from the index, so
            index = col_index + (dim - 1) + (dim - 2) + (dim - 3) + ...
        */
        while(j < i) {
            index += dim - j-1;
            j++;
        }
        column[i] = arr[index];
    }
    return column;
}

//Returns the row at row_index from arr[]
//NOTE: only works if arr[] is in the compressed form of the 2d upper triangular matrix
int* get_row(int arr[], int row[], int dim, int row_index) {

    /*Get to the index of the correct row
    Usually given by 
        index = row_index * dim
    however, since no 0s are stored, we must subtract those positions of zero from the index, so
        index = dim + (dim - 1) + (dim - 2) + (dim - 3) + ...
    */
    int j = 0;
    int index = 0;
    while(j < row_index) {
        index += dim - j;
        j++;
    }

    //For each element in the row, assign it to the row
    for(int i = 0; i < (dim - row_index); i++) {
        row[i] = arr[index + i];

    }
    return row;

}


int main(int argc, char* argv[]) {
    
    //dim is the dimensions of the 2d array, size is the size of the actual array
    int dim;
    int size = 0;
    ifstream first_mat_file(argv[1]);
    ifstream second_mat_file(argv[2]);

    first_mat_file>>dim;
    second_mat_file>>dim;

    //size is given by dim + (dim-1) + (dim-2) + ...
    for(int i = 0; i < dim; i++) {
        size += dim - i;
    }

    int matrix1[size];
    int matrix2[size];
    int result[size] = {0};

    //Read in both matrixes from the files
    for(int i = 0; i < size; i++) {
        first_mat_file>>matrix1[i];
        second_mat_file>>matrix2[i];
    }

    for(int i = 0; i < size; i++) {
        
        int index = i;
        int row_index = 0; //NOTE: ROW_INDEX ALSO KEEPS TRACK OF HOW MANY 0s ARE IN A ROW
        //The number of elements in a row is given by dim - row_index.
        int row_len = dim;
        while(index >= row_len) {
            index -= row_len;
            row_index++;
            row_len--;
        }
        /*Index should currently keep the column WITHOUT additional zeros
            To adjust it to our current format, just need to add the number of zeros (i.e. row_index)
        */
        int col_index = index + row_index;
        
        //The number of elements in a column is given by col_index + 1. e.g. col_index 1 has 2 elements

        int col_len = col_index + 1;
        int temp_row[row_len];
        int temp_col[col_len];
        int* row = get_row(matrix1, temp_row, dim, row_index);
        int* col = get_column(matrix2, temp_col, dim, col_index);

        //iterate over the rows and columns
        int j = 0;
        while(j < row_len && j+row_index < col_len) {
            result[i] += row[j] * col[row_index+j];
            j++;
        }


    }
    for(int i = 0; i < size; i++) {
        cout<<result[i]<<" ";
    }
    cout<<endl;

}