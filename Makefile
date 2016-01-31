# See LICENSE for license details.

#--------------------------------------------------------------------
# global define
#--------------------------------------------------------------------

ifndef XILINX_VIVADO
$(error Please set environment variable XILINX_VIVADO for Xilinx tools)
endif

default: project

base_dir = $(abspath ../../..)
proj_dir = $(abspath .)
mem_gen = $(base_dir)/fpga/common/fpga_mem_gen
generated_dir = $(abspath ./generated-src)

glip_dir = $(base_dir)/opensocdebug/glip/src/backend_uart/logic/verilog
osd_dir = $(base_dir)/opensocdebug/hardware

project_name = lowrisc-chip-imp
BACKEND ?= lowrisc_chip.LowRISCBackend
CONFIG ?= DefaultConfig

VIVADO = vivado

include $(base_dir)/Makefrag

.PHONY: default

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

verilog_lowrisc = \
	$(generated_dir)/$(MODEL).$(CONFIG).v \
	$(generated_dir)/consts.$(CONFIG).vh \

verilog_srcs = \
	$(verilog_lowrisc) \
	$(base_dir)/src/main/verilog/chip_top.sv \
	$(base_dir)/socip/nasti/channel.sv \
	$(base_dir)/socip/nasti/lite_nasti_reader.sv \
	$(base_dir)/socip/nasti/lite_nasti_writer.sv \
	$(base_dir)/socip/nasti/nasti_buf.sv \
	$(base_dir)/socip/nasti/nasti_combiner.sv \
	$(base_dir)/socip/nasti/nasti_crossbar.sv \
	$(base_dir)/socip/nasti/nasti_demux.sv \
	$(base_dir)/socip/nasti/nasti_lite_bridge.sv \
	$(base_dir)/socip/nasti/nasti_lite_reader.sv \
	$(base_dir)/socip/nasti/nasti_lite_writer.sv \
	$(base_dir)/socip/nasti/nasti_mux.sv \
	$(base_dir)/socip/nasti/nasti_slicer.sv \
	$(base_dir)/socip/util/arbiter.sv \
	$(base_dir)/src/main/verilog/config.vh \
	$(base_dir)/src/main/verilog/debug_system.sv \
	$(glip_dir)/glip_uart_control_egress.v \
	$(glip_dir)/glip_uart_control_ingress.v \
	$(glip_dir)/glip_uart_control.v \
	$(glip_dir)/glip_uart_receive.v \
	$(glip_dir)/glip_uart_toplevel.v \
        $(glip_dir)/glip_uart_transmit.v \
	$(osd_dir)/interconnect/verilog/debug_ring.sv \
	$(osd_dir)/interconnect/verilog/ring_router_demux.sv \
	$(osd_dir)/interconnect/verilog/ring_router_mux_rr.sv \
	$(osd_dir)/interconnect/verilog/ring_router_mux.sv \
	$(osd_dir)/interconnect/verilog/ring_router.sv \
	$(osd_dir)/interfaces/verilog/dii_channel.sv \
	$(osd_dir)/modules/dem_uart/verilog/osd_dem_uart_16550.sv \
	$(osd_dir)/modules/dem_uart/verilog/osd_dem_uart_nasti.sv \
	$(osd_dir)/modules/dem_uart/verilog/osd_dem_uart.sv \
	$(osd_dir)/modules/scm/verilog/osd_scm.sv \


boot_mem = src/boot.mem

testbench_srcs = \
	$(base_dir)/src/test/verilog/chip_top_tb.sv \
	$(base_dir)/src/test/verilog/host_behav.sv \
	$(base_dir)/src/test/verilog/nasti_ram_behav.sv \

dpi_srcs = \
	$(base_dir)/src/test/cxx/common/globals.cpp \
	$(base_dir)/src/test/cxx/common/dpi_ram_behav.cpp \
	$(base_dir)/src/test/cxx/common/dpi_host_behav.cpp \

dpi_headers = \
	$(base_dir)/src/test/cxx/common/globals.h \
	$(base_dir)/src/test/cxx/common/dpi_ram_behav.h \
	$(base_dir)/src/test/cxx/common/dpi_host_behav.h \

#--------------------------------------------------------------------
# Build Verilog
#--------------------------------------------------------------------

verilog: $(verilog_lowrisc)

$(generated_dir)/$(MODEL).$(CONFIG).v: $(chisel_srcs)
	cd $(base_dir) && mkdir -p $(generated_dir) && $(SBT) "run $(CHISEL_ARGS) --configDump --noInlineMem"
	cd $(generated_dir) && \
	if [ -a $(MODEL).$(CONFIG).conf ]; then \
	  $(mem_gen) $(generated_dir)/$(MODEL).$(CONFIG).conf >> $(generated_dir)/$(MODEL).$(CONFIG).v; \
	fi

$(generated_dir)/consts.$(CONFIG).vh: $(generated_dir)/$(MODEL).$(CONFIG).v
	echo "\`ifndef CONST_VH" > $@
	echo "\`define CONST_VH" >> $@
	sed -r 's/\(([A-Za-z0-9_]+),([A-Za-z0-9_]+)\)/`define \1 \2/' $(patsubst %.v,%.prm,$<) >> $@
	echo "\`endif // CONST_VH" >> $@

.PHONY: verilog
junk += $(generated_dir)

#--------------------------------------------------------------------
# Project generation
#--------------------------------------------------------------------

project = $(project_name)/$(project_name).xpr
project: $(project)
$(project): | $(verilog_lowrisc)
	$(VIVADO) -mode batch -source script/make_project.tcl -tclargs $(project_name) $(CONFIG)
	ln -s $(proj_dir)/$(boot_mem) $(project_name)/$(project_name).runs/synth_1/boot.mem
	ln -s $(proj_dir)/$(boot_mem) $(project_name)/$(project_name).sim/sim_1/behav/boot.mem

vivado: $(project)
	$(VIVADO) $(project) &

bitstream = $(project_name)/$(project_name).runs/impl_1/chip_top.bit
bitstream: $(bitstream)
$(bitstream): $(verilog_lowrisc) $(verilog_srcs) | $(project)
	$(VIVADO) -mode batch -source ../../common/script/make_bitstream.tcl -tclargs $(project_name)

.PHONY: project vivado bitstream

#--------------------------------------------------------------------
# DPI compilation
#--------------------------------------------------------------------
dpi_lib = $(project_name)/$(project_name).sim/sim_1/behav/xsim.dir/xsc/dpi.so
dpi: $(dpi_lib)
$(dpi_lib): $(dpi_srcs) $(dpi_headers)
	-mkdir -p $(project_name)/$(project_name).sim/sim_1/behav/xsim.dir/xsc
	cd $(project_name)/$(project_name).sim/sim_1/behav; \
	g++ -Wa,-W -fPIC -m64 -O1 -std=c++11 -shared -I$(XILINX_VIVADO)/data/xsim/include -I$(base_dir)/csrc/common \
	$(dpi_srcs) $(XILINX_VIVADO)/lib/lnx64.o/librdi_simulator_kernel.so -o $(proj_dir)/$@

.PHONY: dpi

#--------------------------------------------------------------------
# FPGA simulation
#--------------------------------------------------------------------

sim-comp = $(project_name)/$(project_name).sim/sim_1/behav/compile.log
sim-comp: $(sim-comp)
$(sim-comp): $(verilog_lowrisc) $(verilog_srcs) $(testbench_srcs) | $(project)
	cd $(project_name)/$(project_name).sim/sim_1/behav; source compile.sh > /dev/null
	@echo "If error, see $(project_name)/$(project_name).sim/sim_1/behav/compile.log for more details."

sim-elab = $(project_name)/$(project_name).sim/sim_1/behav/elaborate.log
sim-elab: $(sim-elab)
$(sim-elab): $(sim-comp) $(dpi_lib)
	cd $(project_name)/$(project_name).sim/sim_1/behav; source elaborate.sh > /dev/null
	@echo "If error, see $(project_name)/$(project_name).sim/sim_1/behav/elaborate.log for more details."

simulation: $(sim-elab)
	cd $(project_name)/$(project_name).sim/sim_1/behav; xsim tb_behav -key {Behavioral:sim_1:Functional:tb} -tclbatch $(proj_dir)/script/simulate.tcl -log $(proj_dir)/simulate.log

.PHONY: sim-comp sim-elab simulation

#--------------------------------------------------------------------
# Debug helper
#--------------------------------------------------------------------

search-ramb: src/boot.bmm
src/boot.bmm: $(bitstream)
	$(VIVADO) -mode batch -source ../../common/script/search_ramb.tcl -tclargs $(project_name) > search-ramb.log
	python ../../common/script/bmm_gen.py search-ramb.log src/boot.bmm 128 65536

bit-update: $(project_name)/$(project_name).runs/impl_1/chip_top.new.bit
$(project_name)/$(project_name).runs/impl_1/chip_top.new.bit: $(boot_mem) src/boot.bmm
	data2mem -bm $(boot_mem) -bd $< -bt $(bitstream) -o b $@

.PHONY: search-ramb bit-update

#--------------------------------------------------------------------
# Load examples
#--------------------------------------------------------------------

EXAMPLES = hello boot dram sdcard

$(EXAMPLES):
	cd examples && make
	cp examples/$@.hex $(boot_mem) && make bit-update

.PHONY: $(EXAMPLES)

#--------------------------------------------------------------------
# BBL
#--------------------------------------------------------------------

bbl:
	cd bbl && make

.PHONY: bbl

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean:
	rm -rf *.log *.jou $(junk)

cleanall: clean
	rm -fr $(project_name)
	cd examples && make clean
	cd bbl && make clean

.PHONY: clean cleanall
