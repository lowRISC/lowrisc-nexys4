
// testing the reset process
// simulation only

#include <stdint.h>
#include "memory.h"

#define SYS_soft_reset 617
#define SYS_set_iobase 0x12200
#define SYS_set_membase 0x2100
extern long syscall(long num, long arg0, long arg1, long arg2);

int main() {

  // map DDR3 to IO
  syscall(SYS_set_membase, 0x0, 0x3fffffff, 0x0); /* BRAM, 0x00000000 - 0x3fffffff */
  syscall(SYS_set_membase+5, 0, 0, 0);            /* update memory space */

  syscall(SYS_set_iobase, 0x80000000, 0x7fffffff, 0);   /* IO devices, 0x80000000 - 0xffffffff */
  syscall(SYS_set_iobase+1, 0x40000000, 0x3fffffff, 0); /* DDR3, 0x40000000 - 0x7fffffff */
  syscall(SYS_set_iobase+5, 0, 0, 0);                   /* update io space */

  uint64_t offset = 0;
  for(; offset < 0x1000/8; offset++)
    *(get_ddr_base() + offset) = 0x0000001300000013;

  // map DDR3 to 0x0
  syscall(SYS_set_iobase, 0x80000000, 0x7fffffff, 0); /* IO devices, 0x80000000 - 0xffffffff */
  syscall(SYS_set_iobase+1, 0, 0, 0);                 /* clear previous mapping */
  syscall(SYS_set_iobase+5, 0, 0, 0);                 /* update io space */

  syscall(SYS_set_membase, 0x0, 0x3fffffff, 0x40000000);
  syscall(SYS_soft_reset, 0, 0, 0);                      /* soft reset */

  return 0;
}
