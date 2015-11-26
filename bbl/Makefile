#=======================================================================
# Makefile for Berkeley bootloader (BBL)
#-----------------------------------------------------------------------
# See LICENSE for license details.

# check RISCV environment variable
ifndef RISCV
$(error Please set environment variable RISCV. Please take a look at README)
endif

default: all

TARGET = bbl

all: $(TARGET)

junk += $(TARGET) $(TARGET).hex

.PHONY: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

DRIVER_DIR = ../driver
RISCV_PREFIX=riscv64-unknown-elf-
RISCV_GCC = $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS = -MMD -MP -Wall -Werror -D__NO_INLINE__ -DENABLE_ATOMICS -mcmodel=medany -O2 -std=gnu99 -Wno-unused -Wno-attributes -fno-delete-null-pointer-checks  -I. -I..
RISCV_LINK_OPTS = -nostartfiles -nostdlib -static -T bbl.ld -L../softfloat -lsoftfloat -lgcc
RISCV_DUMP = $(RISCV_PREFIX)objdump
RISCV_DUMP_OPTS = -D -S -l


#--------------------------------------------------------------------
# Objects
#--------------------------------------------------------------------
C_OBJS = \
	mtrap.o \
	minit.o \
	emulation.o \
	sbi_impl.o \
	init.o \
	file.o \
	frontend.o \
	elf.o \
	console.o \
	vm.o \
	string.o \
	bbl.o \

S_OBJS = \
	mentry.o \
	sbi_entry.o \
	sbi.o \
	fp_asm.o \

HEADERS += \
	$(wildcard *.h) \

DRIVER_OBJS = \
	spi.o \
	uart.o \
	memory.o \
	diskio.o \
	ff.o \

DRIVER_HEADERS += \
	$(wildcard $(DRIVER_DIR)/*.h) \

junk += \
	$(C_OBJS) $(S_OBJS) $(DRIVER_OBJS) \
	$(patsubst %.o, %.d, $(C_OBJS)) \
	$(patsubst %.o, %.d, $(S_OBJS)) \
	$(patsubst %.o, %.d, $(DRIVER_OBJS)) \

#--------------------------------------------------------------------
# Building Targets
#--------------------------------------------------------------------

../softfloat/libsoftfloat.a: $(wildcard ../softfloat/*.c) $(wildcard ../softfloat/*.h)
	cd ../softfloat && make

$(C_OBJS): %.o: %.c $(HEADERS)
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

$(S_OBJS): %.o: %.S $(HEADERS)
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

$(DRIVER_OBJS): %.o:$(DRIVER_DIR)/%.c $(DRIVER_HEADERS)
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

$(TARGET): $(C_OBJS) $(S_OBJS) $(DRIVER_OBJS) ../softfloat/libsoftfloat.a
	$(RISCV_GCC) -o $@ $(C_OBJS) $(S_OBJS) $(DRIVER_OBJS) $(RISCV_LINK_OPTS)

dump: $(TARGET).dump
$(TARGET).dump: $(TARGET)
	$(RISCV_DUMP) $(RISCV_DUMP_OPTS) $< > $@

hex: $(TARGET).hex
$(TARGET).hex: $(TARGET)
	elf2hex 16 32768 $< > $@

.PHONY: dump

#--------------------------------------------------------------------
# clean up
#--------------------------------------------------------------------

clean:
	rm -rf $(junk)
	cd ../softfloat && make clean

.PHONY: clean
