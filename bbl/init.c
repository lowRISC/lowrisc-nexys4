// See LICENSE for license details.

#include "bbl.h"
#include "vm.h"
#include "elf.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

elf_info current;
int have_vm = 1;

int uarch_counters_enabled;
long uarch_counters[NUM_COUNTERS];
char* uarch_counter_names[NUM_COUNTERS];

void init_tf(trapframe_t* tf, long pc, long sp, int user64)
{
  memset(tf, 0, sizeof(*tf));
  if (!user64)
    panic("can't run 32-bit ELF on 64-bit pk");
  tf->status = read_csr(sstatus);
  tf->gpr[2] = sp;
  tf->epc = pc;
}

void boot_loader()
{
  // load program named "boot"
  long phdrs[128];
  current.phdr = (uintptr_t)phdrs;
  current.phdr_size = sizeof(phdrs);
  load_elf("vmlinux", &current);

  run_loaded_program();
}
