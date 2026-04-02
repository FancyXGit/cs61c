#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "lfsr.h"

uint8_t getbit(uint16_t val, uint16_t n)
{
    return (val >> n) & 1u;
}

void lfsr_calculate(uint16_t *reg)
{
    uint8_t po_0 = getbit(*reg, 0);
    uint8_t po_2 = getbit(*reg, 2);
    uint8_t po_3 = getbit(*reg, 3);
    uint8_t po_5 = getbit(*reg, 5);
    uint8_t to_shift = po_0 ^ po_2 ^ po_3 ^ po_5;
    if (to_shift == 0)
    {
        *reg = *reg >> 1;
    }
    else
    {
        *reg = (*reg >> 1) | (1 << 15);
    }
}
