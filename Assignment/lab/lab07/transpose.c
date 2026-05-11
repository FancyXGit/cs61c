#include "transpose.h"

/* The naive transpose function as a reference. */
void transpose_naive(int n, int blocksize, int *dst, int *src)
{
    for (int x = 0; x < n; x++)
    {
        for (int y = 0; y < n; y++)
        {
            dst[y + x * n] = src[x + y * n];
        }
    }
}

/* Implement cache blocking below. You should NOT assume that n is a
 * multiple of the block size. */
void transpose_blocking(int n, int blocksize, int *dst, int *src)
{
    int small_matrix_count = n / blocksize;
    int src_small[blocksize * blocksize];
    int dst_small[blocksize * blocksize];
    for (int j = 0; j < small_matrix_count; j++)
    {
        for (int i = 0; i < small_matrix_count; i++)
        {
            int src_start = i * blocksize + j * blocksize * n;
            int dst_start = j * blocksize + i * blocksize * n;

            for (int l = 0; l < blocksize; l++)
            {
                for (int k = 0; k < blocksize; k++)
                {
                    src_small[k + l * blocksize] = src[src_start + k + l * n];
                }
            }
            transpose_naive(blocksize, 0, dst_small, src_small);
            for (int l = 0; l < blocksize; l++)
            {
                for (int k = 0; k < blocksize; k++)
                {
                    dst[dst_start + k + l * n] = dst_small[k + l * blocksize];
                }
            }
        }
    }

    int rest = n % blocksize;
    if (rest == 0)
    {
        return;
    }
    int res_length = blocksize * small_matrix_count;
    int res_width = n - res_length;
    int start_right_up = n * res_length;
    int start_left_down = res_length;
    int start_right_down = start_left_down + start_right_up;
    for (int j = 0; j < res_width; j++)
    {
        for (int i = 0; i < res_length; i++)
        {
            dst[start_left_down + j + i * n] = src[start_right_up + i + j * n];
            dst[start_right_up + j + i * n] = src[start_left_down + i + j * n];
            dst[start_right_down + j + i * n] = src[start_right_down + i + j * n];
        }
    }
}
