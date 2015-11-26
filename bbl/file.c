// See LICENSE for license details.

#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include "file.h"
#include "bbl.h"
#include "vm.h"

#define MAX_FILES 32
file_t files[MAX_FILES];
spinlock_t file_lock = SPINLOCK_INIT;
spinlock_t refcnt_lock = SPINLOCK_INIT;

void file_incref(file_t* f)
{
  long flags = spinlock_lock_irqsave(&refcnt_lock);
  long prev = f->refcnt;
  f->refcnt = prev + 1;
  spinlock_unlock_irqrestore(&refcnt_lock,flags);
  kassert(prev > 0);
}

void file_decref(file_t* f)
{
  long flags = spinlock_lock_irqsave(&refcnt_lock);
  long prev = f->refcnt;
  f->refcnt = prev - 1;
  if (prev == 2)
  {
    f->refcnt = 0;
    f->offset = 0;
    f_close(&f->fd);
  }
  spinlock_unlock_irqrestore(&refcnt_lock,flags);
}

static file_t* file_get_free()
{
  for (file_t* f = files; f < files + MAX_FILES; f++)
    if (atomic_cas(&f->refcnt, 0, 2) == 0)
      return f;
  panic("fail to get a free file");
  return NULL;
}

void file_init()
{
  int i;
  for(i=0; i<MAX_FILES; i++) {
    files[i].offset = 0;
    files[i].refcnt = 0;
  }
}

file_t* file_openat(int dirfd, const char* fn, int flags)
{
  file_t* f = file_get_free();
  if (f == NULL)
    return f;

  uint8_t mode = 0;
  if((flags & O_ACCMODE) == O_RDONLY) mode = FA_READ;
  if((flags & O_ACCMODE) == O_WRONLY) mode = FA_WRITE;
  if((flags & O_ACCMODE) == O_RDWR)   mode = FA_READ | FA_WRITE;

  FRESULT rt = f_open(&f->fd, fn, mode); /* check mode */
  if (rt) {
    panic("fail to open file %s", fn);
    file_decref(f);
    return NULL;
  } else {
    return f;
  }
}

file_t* file_open(const char* fn, int flags)
{
  return file_openat(AT_FDCWD, fn, flags);
}

ssize_t file_read(file_t* f, void* buf, size_t size)
{
  populate_mapping(buf, size, PROT_WRITE);
  long flags = spinlock_lock_irqsave(&file_lock);
  f_lseek(&f->fd, f->offset);
  uint32_t rsize;
  f_read(&f->fd, buf, size, &rsize);
  f->offset += rsize;
  spinlock_unlock_irqrestore(&file_lock,flags);
  return rsize;
}

ssize_t file_pread(file_t* f, void* buf, size_t size, off_t offset)
{
  populate_mapping(buf, size, PROT_WRITE);
  long flags = spinlock_lock_irqsave(&file_lock);
  FRESULT rt = f_lseek(&f->fd, offset);
  if(rt) panic("f_lseek() failed! %d", rt);
  uint32_t rsize = 0;
  f_read(&f->fd, buf, size, &rsize);
  if(rt) panic("f_read() failed! %d", rt);
  spinlock_unlock_irqrestore(&file_lock,flags);
  return rsize;
}

ssize_t file_write(file_t* f, const void* buf, size_t size)
{
  populate_mapping(buf, size, PROT_READ);
  long flags = spinlock_lock_irqsave(&file_lock);
  f_lseek(&f->fd, f->offset);
  uint32_t wsize = 0;
  f_write(&f->fd, buf, size, &wsize);
  f->offset += wsize;
  spinlock_unlock_irqrestore(&file_lock,flags);
  return wsize;
}

ssize_t file_pwrite(file_t* f, const void* buf, size_t size, off_t offset)
{
  populate_mapping(buf, size, PROT_READ);
  long flags = spinlock_lock_irqsave(&file_lock);
  f_lseek(&f->fd, offset);
  uint32_t wsize = 0;
  f_write(&f->fd, buf, size, &wsize);
  spinlock_unlock_irqrestore(&file_lock,flags);
  return wsize;
}

//int file_stat(const char* fn, struct stat* s)
//{
//  populate_mapping(s, sizeof(*s), PROT_WRITE);
//  FRESULT rt = f_stat(fn, s);   /* check struct of stat */
//  if(rt) return -1;
//  else return 0;
//}

int file_truncate(file_t* f, off_t len)
{
  panic("file_truncate() not supported!");
  return -1;
}

ssize_t file_lseek(file_t* f, size_t ptr, int dir)
{
  FRESULT rt;
  if(dir == SEEK_SET) {
    rt = f_lseek(&f->fd, ptr);
    if(rt) return -1;
    else return ptr;
  } else if(dir == SEEK_CUR) {
    rt = f_lseek(&f->fd, f->offset + ptr);
    if(rt) return -1;
    else return f->offset + ptr;
  } else {
    panic("lseek SEEK_END not supported!");
    return -1;
  }
}
