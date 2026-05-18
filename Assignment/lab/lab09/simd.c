#include <time.h>
#include <stdio.h>
#include <x86intrin.h>
#include "simd.h"

long long int sum(int vals[NUM_ELEMS])
{
	clock_t start = clock();

	long long int sum = 0;
	for (unsigned int w = 0; w < OUTER_ITERATIONS; w++)
	{
		for (unsigned int i = 0; i < NUM_ELEMS; i++)
		{
			if (vals[i] >= 128)
			{
				sum += vals[i];
			}
		}
	}
	clock_t end = clock();
	printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
	return sum;
}

long long int sum_unrolled(int vals[NUM_ELEMS])
{
	clock_t start = clock();
	long long int sum = 0;

	for (unsigned int w = 0; w < OUTER_ITERATIONS; w++)
	{
		for (unsigned int i = 0; i < NUM_ELEMS / 4 * 4; i += 4)
		{
			if (vals[i] >= 128)
				sum += vals[i];
			if (vals[i + 1] >= 128)
				sum += vals[i + 1];
			if (vals[i + 2] >= 128)
				sum += vals[i + 2];
			if (vals[i + 3] >= 128)
				sum += vals[i + 3];
		}

		// This is what we call the TAIL CASE
		// For when NUM_ELEMS isn't a multiple of 4
		// NONTRIVIAL FACT: NUM_ELEMS / 4 * 4 is the largest multiple of 4 less than NUM_ELEMS
		for (unsigned int i = NUM_ELEMS / 4 * 4; i < NUM_ELEMS; i++)
		{
			if (vals[i] >= 128)
			{
				sum += vals[i];
			}
		}
	}
	clock_t end = clock();
	printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
	return sum;
}

long long int sum_simd(int vals[NUM_ELEMS])
{
	clock_t start = clock();
	__m128i _127 = _mm_set1_epi32(127); // This is a vector with 127s in it... Why might you need this?
	long long int result = 0;			// This is where you should put your final result!
	/* DO NOT DO NOT DO NOT DO NOT WRITE ANYTHING ABOVE THIS LINE. */

	for (unsigned int w = 0; w < OUTER_ITERATIONS; w++)
	{
		int cycles = NUM_ELEMS / 8;
		int left = NUM_ELEMS % 8;
		int *curr_pointer = vals;
		__m128i m128i_res = _mm_setzero_si128();
		for (unsigned int i = 0; i < cycles; i++)
		{
			__m128i curr_vec_1 = _mm_loadu_si128((__m128i *)curr_pointer);
			__m128i curr_vec_2 = _mm_loadu_si128((__m128i *)(curr_pointer + 4));
			__m128i comp_1 = _mm_cmpgt_epi32(curr_vec_1, _127);
			__m128i comp_2 = _mm_cmpgt_epi32(curr_vec_2, _127);
			curr_vec_1 = _mm_and_si128(comp_1, curr_vec_1);
			curr_vec_2 = _mm_and_si128(comp_2, curr_vec_2);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_1);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_2);
			curr_pointer += 8;
		}
		int vec_res[4];
		_mm_storeu_si128((__m128i *)vec_res, m128i_res);
		for (int i = 0; i < 4; i++)
		{
			result += vec_res[i];
		}
		if (left != 0)
		{
			for (int i = 0; i < left; i++)
			{
				if (*(curr_pointer + i) >= 128)
				{
					result += *(curr_pointer + i);
				}
			}
		}
	}
	clock_t end = clock();
	printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
	return result;
}

long long int sum_simd_unrolled(int vals[NUM_ELEMS])
{
	clock_t start = clock();
	__m128i _127 = _mm_set1_epi32(127);
	long long int result = 0;
	for (unsigned int w = 0; w < OUTER_ITERATIONS; w++)
	{
		/* COPY AND PASTE YOUR sum_simd() HERE */
		/* MODIFY IT BY UNROLLING IT */
		int cycles = NUM_ELEMS / 32;
		int left = NUM_ELEMS % 32;
		int *curr_pointer = vals;
		__m128i m128i_res = _mm_setzero_si128();
		for (unsigned int i = 0; i < cycles; i++)
		{
			__m128i curr_vec_1 = _mm_loadu_si128((__m128i *)curr_pointer);
			__m128i curr_vec_2 = _mm_loadu_si128((__m128i *)(curr_pointer + 4));
			__m128i comp_1 = _mm_cmpgt_epi32(curr_vec_1, _127);
			__m128i comp_2 = _mm_cmpgt_epi32(curr_vec_2, _127);
			curr_vec_1 = _mm_and_si128(comp_1, curr_vec_1);
			curr_vec_2 = _mm_and_si128(comp_2, curr_vec_2);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_1);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_2);
			curr_pointer += 8;

			curr_vec_1 = _mm_loadu_si128((__m128i *)curr_pointer);
			curr_vec_2 = _mm_loadu_si128((__m128i *)(curr_pointer + 4));
			comp_1 = _mm_cmpgt_epi32(curr_vec_1, _127);
			comp_2 = _mm_cmpgt_epi32(curr_vec_2, _127);
			curr_vec_1 = _mm_and_si128(comp_1, curr_vec_1);
			curr_vec_2 = _mm_and_si128(comp_2, curr_vec_2);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_1);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_2);
			curr_pointer += 8;

			curr_vec_1 = _mm_loadu_si128((__m128i *)curr_pointer);
			curr_vec_2 = _mm_loadu_si128((__m128i *)(curr_pointer + 4));
			comp_1 = _mm_cmpgt_epi32(curr_vec_1, _127);
			comp_2 = _mm_cmpgt_epi32(curr_vec_2, _127);
			curr_vec_1 = _mm_and_si128(comp_1, curr_vec_1);
			curr_vec_2 = _mm_and_si128(comp_2, curr_vec_2);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_1);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_2);
			curr_pointer += 8;

			curr_vec_1 = _mm_loadu_si128((__m128i *)curr_pointer);
			curr_vec_2 = _mm_loadu_si128((__m128i *)(curr_pointer + 4));
			comp_1 = _mm_cmpgt_epi32(curr_vec_1, _127);
			comp_2 = _mm_cmpgt_epi32(curr_vec_2, _127);
			curr_vec_1 = _mm_and_si128(comp_1, curr_vec_1);
			curr_vec_2 = _mm_and_si128(comp_2, curr_vec_2);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_1);
			m128i_res = _mm_add_epi32(m128i_res, curr_vec_2);
			curr_pointer += 8;
		}
		int vec_res[4];
		_mm_storeu_si128((__m128i *)vec_res, m128i_res);
		for (int i = 0; i < 4; i++)
		{
			result += vec_res[i];
		}
		if (left != 0)
		{
			for (int i = 0; i < left; i++)
			{
				if (*(curr_pointer + i) >= 128)
				{
					result += *(curr_pointer + i);
				}
			}
		}
		/* You'll need 1 or maybe 2 tail cases here. */
	}
	clock_t end = clock();
	printf("Time taken: %Lf s\n", (long double)(end - start) / CLOCKS_PER_SEC);
	return result;
}