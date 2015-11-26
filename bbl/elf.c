// See LICENSE for license details.

#include "bbl.h"
#include "file.h"
#include "vm.h"
#include <sys/stat.h>
#include <fcntl.h>
#include <elf.h>
#include <string.h>

#define IS_ERR_VALUE(x) ((unsigned long)(x) >= (unsigned long)-4096)

void load_elf(const char* fn, elf_info* info)
{
  file_t* file = file_open(fn, O_RDONLY);
  if (file == NULL)
    panic("fail to open the ELF!");

  Elf64_Ehdr eh64;
  ssize_t ehdr_size = file_pread(file, &eh64, sizeof(eh64), 0);
  if (ehdr_size < (ssize_t)sizeof(eh64) || !IS_ELF64(eh64))
    panic("Not ELF64! %x < %x or %x %x %x %x %x", ehdr_size, (ssize_t)sizeof(eh64),
          (eh64).e_ident[0], (eh64).e_ident[1], (eh64).e_ident[2], (eh64).e_ident[3],
          (eh64).e_ident[4]);

  info->elf64 = 1;
  uintptr_t min_vaddr = -1, max_vaddr = 0;
  Elf64_Ehdr* eh;
  Elf64_Phdr* ph;

  eh = (typeof(eh))&eh64;
  size_t phdr_size = eh->e_phnum*sizeof(*ph);
  if (phdr_size > info->phdr_size)
    panic("ELF: phdr_size %d too large!", phdr_size);
  ssize_t ret = file_pread(file, (void*)info->phdr, phdr_size, eh->e_phoff);
  if (ret < (ssize_t)phdr_size)
    panic("ELF: fail to read the whole phdr!");
  info->phnum = eh->e_phnum;
  info->phent = sizeof(*ph);
  ph = (typeof(ph))info->phdr;
  info->is_supervisor = (eh->e_entry >> (8*sizeof(eh->e_entry)-1)) != 0;
  if (info->is_supervisor)
    info->first_free_paddr = ROUNDUP(info->first_free_paddr, SUPERPAGE_SIZE);
  for (int i = 0; i < eh->e_phnum; i++)
    if (ph[i].p_type == PT_LOAD && ph[i].p_memsz && ph[i].p_vaddr < min_vaddr)
      min_vaddr = ph[i].p_vaddr;
  if (info->is_supervisor)
    min_vaddr = ROUNDDOWN(min_vaddr, SUPERPAGE_SIZE);
  else
    min_vaddr = ROUNDDOWN(min_vaddr, RISCV_PGSIZE);
  uintptr_t bias = 0;
  if (info->is_supervisor || eh->e_type == ET_DYN)
    bias = info->first_free_paddr - min_vaddr;
  info->entry = eh->e_entry;
  if (!info->is_supervisor) {
    info->entry += bias;
    min_vaddr += bias;
  }
  info->bias = bias;
  int flags = MAP_FIXED | MAP_PRIVATE;
  if (info->is_supervisor)
    flags |= MAP_POPULATE;
  for (int i = eh->e_phnum - 1; i >= 0; i--) {
    if(ph[i].p_type == PT_LOAD && ph[i].p_memsz) {
      uintptr_t prepad = ph[i].p_vaddr % RISCV_PGSIZE;
      uintptr_t vaddr = ph[i].p_vaddr + bias;
      if (vaddr + ph[i].p_memsz > max_vaddr)
        max_vaddr = vaddr + ph[i].p_memsz;
      if (info->is_supervisor) {
        if (!__valid_user_range(vaddr - prepad, vaddr + ph[i].p_memsz))
          panic("ELF: invalid user addr range!");
        ret = file_pread(file, (void*)vaddr, ph[i].p_filesz, ph[i].p_offset);
        if (ret < (ssize_t)ph[i].p_filesz)
          panic("ELF: fail to read a physical section header!");
        memset((void*)vaddr - prepad, 0, prepad);
        memset((void*)vaddr + ph[i].p_filesz, 0, ph[i].p_memsz - ph[i].p_filesz);
      } else {
        int flags2 = flags | (prepad ? MAP_POPULATE : 0);
        if (__do_mmap(vaddr - prepad, ph[i].p_filesz + prepad, -1, flags2, file, ph[i].p_offset - prepad) != vaddr - prepad)
          panic("ELF: fail to memory map a section header!");
        memset((void*)vaddr - prepad, 0, prepad);
        size_t mapped = ROUNDUP(ph[i].p_filesz + prepad, RISCV_PGSIZE) - prepad;
        if (ph[i].p_memsz > mapped)
          if (__do_mmap(vaddr + mapped, ph[i].p_memsz - mapped, -1, flags|MAP_ANONYMOUS, 0, 0) != vaddr + mapped)
            panic("ELF: fail to memory map a section!");
      }
    }
  }

  info->first_user_vaddr = min_vaddr;
  info->first_vaddr_after_user = ROUNDUP(max_vaddr - info->bias, RISCV_PGSIZE);
  info->brk_min = max_vaddr;

  file_decref(file);
  return;
}
