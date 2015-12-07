#include "bbl.h"
#include "vm.h"

volatile int elf_loaded;

static void enter_entry_point()
{
    write_csr(mepc, current.entry);
    asm volatile("eret");
    __builtin_unreachable();
}

void run_loaded_program()
{
  if (!current.is_supervisor)
    panic("bbl can't run user binaries");

  supervisor_vm_init();
  mb();
  elf_loaded = 1;
  enter_entry_point();
}

void boot_other_hart()
{
  while (!elf_loaded)
    ;
  mb();
  enter_entry_point();
}
