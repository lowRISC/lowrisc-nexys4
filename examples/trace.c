// A hello world program

#include <stdio.h>
#include "uart.h"

#define write_csr(reg, val) \

#define STM_TRACE(id, value) \
  { \
    register uintptr_t v asm("x10") = value; \
    asm volatile ("" ::: "memory");		\
    asm volatile ("csrw 0x8f0, %0" :: "r"(id));	\
  }

int main() {
  STM_TRACE(0x1234, 0xdeadbeef);
}

