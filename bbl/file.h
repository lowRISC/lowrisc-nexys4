// See LICENSE for license details.

#ifndef _FILE_H
#define _FILE_H

#include <sys/stat.h>
#include <unistd.h>
#include <stdint.h>
#include "atomic.h"

// FatFS
#include "driver/ff.h"

typedef struct file
{
  FIL fd;                       /* FatFS file handler */
  uint32_t offset;              /* remember current fp position */
  unsigned refcnt;
} file_t;

void file_incref(file_t* f);
void file_decref(file_t* f);
file_t* file_open(const char* fn, int flags);
//file_t* file_openat(int dirfd, const char* fn, int flags);
ssize_t file_pwrite(file_t* f, const void* buf, size_t n, off_t off);
ssize_t file_pread(file_t* f, void* buf, size_t n, off_t off);
ssize_t file_write(file_t* f, const void* buf, size_t n);
ssize_t file_read(file_t* f, void* buf, size_t n);
ssize_t file_lseek(file_t* f, size_t ptr, int dir);
//int file_truncate(file_t* f, off_t len);
//int file_stat(const char* fn, struct stat* s);

void file_init();

#endif
