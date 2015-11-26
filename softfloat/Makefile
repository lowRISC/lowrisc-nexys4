#=======================================================================
# Makefile for soft float implementation
#-----------------------------------------------------------------------
# See LICENSE for license details.

# check RISCV environment variable
ifndef RISCV
$(error Please set environment variable RISCV. Please take a look at README)
endif

default: all

TARGET = libsoftfloat.a

all: $(TARGET)

junk += $(TARGET)
.PHONY: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX=riscv64-unknown-elf-
RISCV_GCC = $(RISCV_PREFIX)gcc
RISCV_RANLIB = $(RISCV_PREFIX)ranlib
RISCV_AR = $(RISCV_PREFIX)ar
RISCV_GCC_OPTS = -MMD -MP -Wall -Werror -D__NO_INLINE__ -mcmodel=medany -O2 -std=gnu99 -Wno-unused -Wno-attributes -fno-delete-null-pointer-checks  -I. -I../bbl

#--------------------------------------------------------------------
# Objects
#--------------------------------------------------------------------
OBJS += \
	f32_add.o \
	f32_div.o \
	f32_eq.o \
	f32_eq_signaling.o \
	f32_isSignalingNaN.o \
	f32_le.o \
	f32_le_quiet.o \
	f32_lt.o \
	f32_lt_quiet.o \
	f32_mulAdd.o \
	f32_mul.o \
	f32_rem.o \
	f32_roundToInt.o \
	f32_sqrt.o \
	f32_sub.o \
	f32_to_f64.o \
	f32_to_i32.o \
	f32_to_i32_r_minMag.o \
	f32_to_i64.o \
	f32_to_i64_r_minMag.o \
	f32_to_ui32.o \
	f32_to_ui32_r_minMag.o \
	f32_to_ui64.o \
	f32_to_ui64_r_minMag.o \
	f32_classify.o \
	f64_add.o \
	f64_div.o \
	f64_eq.o \
	f64_eq_signaling.o \
	f64_isSignalingNaN.o \
	f64_le.o \
	f64_le_quiet.o \
	f64_lt.o \
	f64_lt_quiet.o \
	f64_mulAdd.o \
	f64_mul.o \
	f64_rem.o \
	f64_roundToInt.o \
	f64_sqrt.o \
	f64_sub.o \
	f64_to_f32.o \
	f64_to_i32.o \
	f64_to_i32_r_minMag.o \
	f64_to_i64.o \
	f64_to_i64_r_minMag.o \
	f64_to_ui32.o \
	f64_to_ui32_r_minMag.o \
	f64_to_ui64.o \
	f64_to_ui64_r_minMag.o \
	f64_classify.o \
	i32_to_f32.o \
	i32_to_f64.o \
	i64_to_f32.o \
	i64_to_f64.o \
	s_add128.o \
	s_add192.o \
	s_addMagsF32.o \
	s_addMagsF64.o \
	s_countLeadingZeros32.o \
	s_countLeadingZeros64.o \
	s_countLeadingZeros8.o \
	s_eq128.o \
	s_estimateDiv128To64.o \
	s_estimateSqrt32.o \
	s_le128.o \
	s_lt128.o \
	s_mul128By64To192.o \
	s_mul128To256.o \
	s_mul64To128.o \
	s_mulAddF32.o \
	s_mulAddF64.o \
	s_normRoundPackToF32.o \
	s_normRoundPackToF64.o \
	s_normSubnormalF32Sig.o \
	s_normSubnormalF64Sig.o \
	s_roundPackToF32.o \
	s_roundPackToF64.o \
	s_roundPackToI32.o \
	s_roundPackToI64.o \
	s_roundPackToUI32.o \
	s_roundPackToUI64.o \
	s_shift128ExtraRightJam.o \
	s_shift128RightJam.o \
	s_shift32RightJam.o \
	s_shift64ExtraRightJam.o \
	s_shift64RightJam.o \
	s_shortShift128ExtraRightJam.o \
	s_shortShift128Left.o \
	s_shortShift128Right.o \
	s_shortShift192Left.o \
	s_shortShift32Right1Jam.o \
	s_shortShift64ExtraRightJam.o \
	s_shortShift64RightJam.o \
	s_sub128.o \
	s_sub192.o \
	s_subMagsF32.o \
	s_subMagsF64.o \
	ui32_to_f32.o \
	ui32_to_f64.o \
	ui64_to_f32.o \
	ui64_to_f64.o \
	s_commonNaNToF64UI.o \
	s_f32UIToCommonNaN.o \
	s_f64UIToCommonNaN.o \
	s_propagateNaNF32UI.o \
	s_propagateNaNF64UI.o \

HEADERS += \
	$(wildcard *.h) \
	$(wildcard ../bbl/*.h) \

junk += $(OBJS) $(patsubst %.o, %.d, $(OBJS))

#--------------------------------------------------------------------
# Building Targets
#--------------------------------------------------------------------

%.o: %.c $(HEADERS)
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

$(TARGET): $(OBJS)
	$(RISCV_AR) rcv $@ $^
	$(RISCV_RANLIB) $@ 

#--------------------------------------------------------------------
# clean up
#--------------------------------------------------------------------

clean:
	rm -rf $(junk)

.PHONY: clean
