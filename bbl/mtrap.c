#include "frontend.h"
#include "mtrap.h"
#include "mcall.h"
#include "vm.h"
#include "driver/uart.h"
#include "driver/ff.h"
#include <errno.h>
#include <fcntl.h>

uintptr_t illegal_insn_trap(uintptr_t mcause, uintptr_t* regs)
{
  asm (".pushsection .rodata\n"
       "illegal_insn_trap_table:\n"
       "  .word truly_illegal_insn\n"
       "  .word emulate_float_load\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word emulate_float_store\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word emulate_mul_div\n"
       "  .word truly_illegal_insn\n"
       "  .word emulate_mul_div32\n"
       "  .word truly_illegal_insn\n"
       "  .word emulate_fmadd\n"
       "  .word emulate_fmsub\n"
       "  .word emulate_fnmsub\n"
       "  .word emulate_fnmadd\n"
       "  .word emulate_fp\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word emulate_system\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .word truly_illegal_insn\n"
       "  .popsection");

  uintptr_t mstatus = read_csr(mstatus);
  uintptr_t mepc = read_csr(mepc);

  insn_fetch_t fetch = get_insn(mcause, mstatus, mepc);

  if (fetch.error || (fetch.insn & 3) != 3)
    return -1;

  extern int32_t illegal_insn_trap_table[];
  int32_t* pf = (void*)illegal_insn_trap_table + (fetch.insn & 0x7c);
  emulation_func f = (emulation_func)(uintptr_t)*pf;
  return f(mcause, regs, fetch.insn, mstatus, mepc);
}

void __attribute__((noreturn)) bad_trap()
{
  panic("machine mode: unhandlable trap %d @ %p", read_csr(mcause), read_csr(mepc));
}

uintptr_t htif_interrupt(uintptr_t mcause, uintptr_t* regs)
{
  panic("htif_interrupt(): no record");
}

uintptr_t io_irq_service(uintptr_t mcause, uintptr_t* regs)
{
  // right now, it must be uart read
  if(!uart_check_read_irq())
    panic("io_irq_service() with no uart recv buf available!");

  // get the message from request queue
  sbi_device_message* m = HLS()->device_request_queue_head;
  sbi_device_message* prev = NULL;
  for (size_t i = 0, n = HLS()->device_request_queue_size; i < n; i++) {
    if (!supervisor_paddr_valid(m, sizeof(*m))
        && EXTRACT_FIELD(read_csr(mstatus), MSTATUS_PRV1) != PRV_M)
      panic("io_irq_service(): page fault");

    sbi_device_message* next = (void*)m->sbi_private_data;
    if (m->dev == 0 && m->cmd == HTIF_CMD_READ) {
      uint8_t ch = uart_read_irq();
      m->data = 0x100 | ch;

      // dequeue from request queue
      if (prev)
        prev->sbi_private_data = (uintptr_t)next;
      else
        HLS()->device_request_queue_head = next;
      HLS()->device_request_queue_size = n-1;
      m->sbi_private_data = 0;

      // enqueue to response queue
      if (HLS()->device_response_queue_tail)
        HLS()->device_response_queue_tail->sbi_private_data = (uintptr_t)m;
      else
        HLS()->device_response_queue_head = m;
      HLS()->device_response_queue_tail = m;

      // signal software interrupt
      set_csr(mip, MIP_SSIP);
      return 0;
    }

    prev = m;
    m = (void*)atomic_read(&m->sbi_private_data);
  }

  panic("io_irq_service(): no record");
}

static uintptr_t mcall_hart_id()
{
  return HLS()->hart_id;
}

static uintptr_t mcall_console_putchar(uint8_t ch)
{
  uart_send(ch);
  return 0;
}

#define printm(str, ...) ({ \
  char buf[128], *p = buf; snprintf(buf, sizeof(buf), str, __VA_ARGS__); \
  while (*p) mcall_console_putchar(*p++); })

static void handle_identify(uint64_t payload, const char *dev_name) {
  size_t what = payload % HTIF_MAX_CMD;
  uintptr_t addr = payload / HTIF_MAX_CMD;
  if(addr % HTIF_MAX_ID != 0)
    panic("address for device ID not aligned!");
  if(strlen(dev_name) > HTIF_MAX_ID)
    panic("device name too long!");
  
  char * id = (char *)addr;
  
  if (what == HTIF_CMD_IDENTIFY)
  {
    strcpy(id, dev_name);
  } else {
    strcpy(id, "");
  }
}

static void mcall_respond(sbi_device_message *m, uint64_t resp) {

  // enqueue to response queue
  m->sbi_private_data = 0;
  if (HLS()->device_response_queue_tail)
    HLS()->device_response_queue_tail->sbi_private_data = (uintptr_t)m;
  else
    HLS()->device_response_queue_head = m;
  HLS()->device_response_queue_tail = m;

  // set response
  m->data = resp;

  // signal software interrupt
  set_csr(mip, MIP_SSIP);
}

const char *ramdisk_fn = "root.bin";
static file_t *ramdisk;

typedef struct
{
  uint64_t addr;
  uint64_t offset;
  uint64_t size;
  uint64_t tag;
} disk_request_t;

static uintptr_t mcall_dev_req(sbi_device_message *m)
{
  //printk("mcall_dev_req() %lx %lx %lx\n", m->dev, m->cmd, m->data);
  if (!supervisor_paddr_valid(m, sizeof(*m))
      && EXTRACT_FIELD(read_csr(mstatus), MSTATUS_PRV1) != PRV_M)
    return -EFAULT;

  if ((m->dev > 0xFFU) | (m->cmd > 0xFFU) | (m->data > 0x0000FFFFFFFFFFFFU))
    return -EINVAL;

  switch(m->dev) {
  case 0:                       /* bcd */
    {
      switch(m->cmd) {
      case HTIF_CMD_IDENTIFY:
        {
          handle_identify(m->data, "bcd");
          mcall_respond(m, 1);
          break;
        }
      case HTIF_CMD_READ:       /* uart read */
        {
          write_csr(0x7c0, 0x01); /* enable irq0 */

          // store the message in request queue
          m->sbi_private_data = (uintptr_t)HLS()->device_request_queue_head;
          HLS()->device_request_queue_head = m;
          HLS()->device_request_queue_size++;
          break;
        }
      case HTIF_CMD_WRITE:      /* uart write */
        {
          uart_send(m->data);
          mcall_respond(m, 0x100|(uint8_t)m->data);
          break;
        }
      default:
        panic("bcd request with not supported command %d!", m->cmd);
      }
      break;
    }
  case 1:                       /* disk */
    {
      switch(m->cmd) {
      case HTIF_CMD_IDENTIFY:
        {
          FILINFO fno;          /* file info */
          if(f_stat(ramdisk_fn, &fno)) {
            handle_identify(m->data, ""); /* error, cannot find the ramdisk root.bin */
            mcall_respond(m, 1);
            break;
          }
          
          // open the file
          ramdisk = file_open(ramdisk_fn, O_RDWR);
          if(ramdisk == NULL) {
            handle_identify(m->data, ""); /* error, cannot open root.bin for read and write*/
            mcall_respond(m, 1);
            break;
          }

          // get file size
          char buf[HTIF_MAX_ID];
          snprintf(buf, sizeof(buf), "disk size=%d", fno.fsize);
          handle_identify(m->data, buf);
          mcall_respond(m, 1);
          break;
        }
      case HTIF_CMD_READ:       /* disk read */
        {
          disk_request_t *req = (disk_request_t *)m->data;
          if(file_pread(ramdisk, (void *)req->addr, req->size, req->offset) != req->size) {
            panic("disk cannot read %d bytes @%d!", req->size, req->offset);
          }
          mcall_respond(m, req->tag);
          break;
        }
      case HTIF_CMD_WRITE:       /* disk write */
        {
          disk_request_t *req = (disk_request_t *)m->data;
          if(file_pwrite(ramdisk, (const void *)req->addr, req->size, req->offset) != req->size) {
            panic("disk cannot write %d bytes @%d!", req->size, req->offset);
          }
          mcall_respond(m, req->tag);
          break;
        }
      default:
        panic("bcd request with not supported command %d!", m->cmd);
      }
      break;
    }
  default:                      /* none */
    {
      switch(m->cmd) {
      case HTIF_CMD_IDENTIFY:
        {
          handle_identify(m->data, "");
          mcall_respond(m, 1);
          break;
        }
      default:
        panic("unknown device request with non-identity command %d!", m->cmd);
      }
    }
  }

  return 0;
}

static uintptr_t mcall_dev_resp()
{
  sbi_device_message* m = HLS()->device_response_queue_head;
  if (m) {
    //printm("resp %p\n", m);
    sbi_device_message* next = (void*)atomic_read(&m->sbi_private_data);
    HLS()->device_response_queue_head = next;
    if (!next) {
      HLS()->device_response_queue_tail = 0;

      // only clear SSIP if no other events are pending
      clear_csr(mip, MIP_SSIP);
      mb();
      if (HLS()->ipi_pending)
        set_csr(mip, MIP_SSIP);
    }
    //printk("mcall_dev_resp() %lx %lx %lx\n", m->dev, m->cmd, m->data);
  }
  return (uintptr_t)m;
}

static uintptr_t mcall_send_ipi(uintptr_t recipient)
{
  if (recipient >= num_harts)
    return -1;

  if (atomic_swap(&OTHER_HLS(recipient)->ipi_pending, 1) == 0) {
    mb();
    write_csr(send_ipi, recipient);
  }

  return 0;
}

static uintptr_t mcall_clear_ipi()
{
  // only clear SSIP if no other events are pending
  if (HLS()->device_response_queue_head == NULL) {
    clear_csr(mip, MIP_SSIP);
    mb();
  }

  return atomic_swap(&HLS()->ipi_pending, 0);
}

static uintptr_t mcall_shutdown()
{
  //while (1)
  //  write_csr(mtohost, 1);
  die(0);
  return 0;
}

static uintptr_t mcall_set_timer(unsigned long long when)
{
  // bbl/pk don't use the timer, so there's no need to virtualize it
  write_csr(mtimecmp, when);
#ifndef __riscv64
  write_csr(mtimecmph, when >> 32);
#endif
  clear_csr(mip, MIP_STIP);
  set_csr(mie, MIP_MTIP);
  return 0;
}

uintptr_t mcall_trap(uintptr_t mcause, uintptr_t* regs)
{
  uintptr_t n = regs[17], arg0 = regs[10], retval;
  switch (n)
  {
    case MCALL_HART_ID:
      retval = mcall_hart_id();
      break;
    case MCALL_CONSOLE_PUTCHAR:
      retval = mcall_console_putchar(arg0);
      break;
    case MCALL_SEND_DEVICE_REQUEST:
      retval = mcall_dev_req((sbi_device_message*)arg0);
      break;
    case MCALL_RECEIVE_DEVICE_RESPONSE:
      retval = mcall_dev_resp();
      break;
    case MCALL_SEND_IPI:
      retval = mcall_send_ipi(arg0);
      break;
    case MCALL_CLEAR_IPI:
      retval = mcall_clear_ipi();
      break;
    case MCALL_SHUTDOWN:
      retval = mcall_shutdown();
      break;
    case MCALL_SET_TIMER:
      retval = mcall_set_timer(arg0);
      break;
    default:
      retval = -ENOSYS;
      break;
  }
  regs[10] = retval;
  write_csr(mepc, read_csr(mepc) + 4);
  return 0;
}

static uintptr_t machine_page_fault(uintptr_t mcause, uintptr_t* regs, uintptr_t mepc)
{
  // See if this trap occurred when emulating an instruction on behalf of
  // a lower privilege level.
  extern int32_t unprivileged_access_ranges[];
  extern int32_t unprivileged_access_ranges_end[];

  int32_t* p = unprivileged_access_ranges;
  do {
    if (mepc >= p[0] && mepc < p[1]) {
      // Yes.  Skip to the end of the unprivileged access region.
      // Mark t0 zero so the emulation routine knows this occurred.
      regs[5] = 0;
      write_csr(mepc, p[1]);
      return 0;
    }
    p += 2;
  } while (p < unprivileged_access_ranges_end);

  // No.  We're boned.
  bad_trap();
}

static uintptr_t machine_illegal_instruction(uintptr_t mcause, uintptr_t* regs, uintptr_t mepc)
{
  bad_trap();
}

uintptr_t trap_from_machine_mode(uintptr_t dummy, uintptr_t* regs)
{
  uintptr_t mcause = read_csr(mcause);
  uintptr_t mepc = read_csr(mepc);
  // restore mscratch, since we clobbered it.
  write_csr(mscratch, MACHINE_STACK_TOP() - MENTRY_FRAME_SIZE);

  switch (mcause)
  {
    case CAUSE_FAULT_LOAD:
    case CAUSE_FAULT_STORE:
      return machine_page_fault(mcause, regs, mepc);
    case CAUSE_ILLEGAL_INSTRUCTION:
      return machine_illegal_instruction(mcause, regs, mepc);
    case CAUSE_MACHINE_ECALL:
      return mcall_trap(mcause, regs);
    default:
      bad_trap();
  }
}
