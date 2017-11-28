# Xilinx Vivado script
# Version: Vivado 2015.4
# Function:
#   Generate a vivado project for the lowRISC SoC

set mem_data_width {64}
set io_data_width {32}
set axi_id_width {8}

set origin_dir "."
set base_dir $::env(TOP)
set osd_dir $base_dir/opensocdebug/hardware
set glip_dir $base_dir/opensocdebug/glip/src
set common_dir $base_dir/fpga/common

set project_name [lindex $argv 0]
set CONFIG [lindex $argv 1]

# Set the directory path for the original project from where this script was exported
set orig_proj_dir [file normalize $origin_dir/$project_name]

# Create project
create_project $project_name $origin_dir/$project_name

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $project_name]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "xc7a100tcsg324-1" $obj
set_property "simulator_language" "Mixed" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set files [list \
               [file normalize $origin_dir/generated-src/Top.$CONFIG.sv] \
               [file normalize $osd_dir/interfaces/common/dii_channel.sv ] \
               [file normalize $base_dir/src/main/verilog/chip_top.sv] \
               [file normalize $base_dir/src/main/verilog/framing.v] \
               [file normalize $base_dir/src/main/verilog/framing_top.sv] \
               [file normalize $base_dir/src/main/verilog/spi_wrapper.sv] \
               [file normalize $base_dir/src/main/verilog/mii_to_rmii_0_open.v] \
               [file normalize $base_dir/socip/nasti/channel.sv] \
               [file normalize $base_dir/socip/nasti/lite_nasti_reader.sv ] \
               [file normalize $base_dir/socip/nasti/lite_nasti_writer.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_buf.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_combiner.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_crossbar.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_demux.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_lite_bridge.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_lite_reader.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_lite_writer.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_narrower.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_narrower_reader.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_narrower_writer.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_mux.sv ] \
               [file normalize $base_dir/socip/nasti/nasti_slicer.sv ] \
               [file normalize $base_dir/socip/util/arbiter.sv ] \
               [file normalize $base_dir/src/main/verilog/debug_system.sv] \
               [file normalize $osd_dir/interconnect/common/debug_ring_expand.sv ] \
               [file normalize $osd_dir/interconnect/common/ring_router.sv ] \
               [file normalize $osd_dir/interconnect/common/ring_router_mux.sv ] \
               [file normalize $osd_dir/interconnect/common/ring_router_mux_rr.sv ] \
               [file normalize $osd_dir/interconnect/common/ring_router_demux.sv ] \
               [file normalize $osd_dir/blocks/buffer/common/dii_buffer.sv ] \
               [file normalize $osd_dir/blocks/buffer/common/osd_fifo.sv ] \
               [file normalize $osd_dir/blocks/timestamp/common/osd_timestamp.sv ] \
               [file normalize $osd_dir/blocks/tracepacket/common/osd_trace_packetization.sv ] \
               [file normalize $osd_dir/blocks/tracesample/common/osd_tracesample.sv ] \
               [file normalize $osd_dir/blocks/regaccess/common/osd_regaccess.sv ] \
               [file normalize $osd_dir/blocks/regaccess/common/osd_regaccess_demux.sv ] \
               [file normalize $osd_dir/blocks/regaccess/common/osd_regaccess_layer.sv ] \
               [file normalize $osd_dir/modules/dem_uart/common/osd_dem_uart.sv ] \
               [file normalize $osd_dir/modules/dem_uart/common/osd_dem_uart_16550.sv ] \
               [file normalize $osd_dir/modules/dem_uart/common/osd_dem_uart_nasti.sv ] \
               [file normalize $osd_dir/modules/him/common/osd_him.sv ] \
               [file normalize $osd_dir/modules/scm/common/osd_scm.sv ] \
               [file normalize $osd_dir/modules/mam/common/osd_mam.sv ] \
               [file normalize $osd_dir/modules/stm/common/osd_stm.sv ] \
               [file normalize $osd_dir/modules/ctm/common/osd_ctm.sv ] \
               [file normalize $glip_dir/common/logic/interface/glip_channel.sv ] \
               [file normalize $glip_dir/backend_uart/logic/verilog/glip_uart_control_egress.v ] \
               [file normalize $glip_dir/backend_uart/logic/verilog/glip_uart_control_ingress.v ] \
               [file normalize $glip_dir/backend_uart/logic/verilog/glip_uart_control.v ] \
               [file normalize $glip_dir/backend_uart/logic/verilog/glip_uart_receive.v ] \
               [file normalize $glip_dir/backend_uart/logic/verilog/glip_uart_toplevel.v ] \
               [file normalize $glip_dir/backend_uart/logic/verilog/glip_uart_transmit.v ] \
               [file normalize $glip_dir/common/logic/credit/verilog/debtor.v] \
               [file normalize $glip_dir/common/logic/credit/verilog/creditor.v] \
               [file normalize $glip_dir/common/logic/scaler/verilog/glip_downscale.v] \
               [file normalize $glip_dir/common/logic/scaler/verilog/glip_upscale.v] \
               [file normalize $glip_dir/common/logic/fifo/verilog/oh_fifo_sync.v] \
               [file normalize $glip_dir/common/logic/fifo/verilog/oh_memory_ram.v] \
               [file normalize $glip_dir/common/logic/fifo/verilog/oh_memory_dp.v] \
               [file normalize $base_dir/src/main/verilog/periph_soc.sv ] \
               [file normalize $base_dir/src/main/verilog/my_fifo.v ] \
               [file normalize $base_dir/src/main/verilog/sd_cmd_serial_host.v ] \
               [file normalize $base_dir/src/main/verilog/sd_crc_16.v ] \
               [file normalize $base_dir/src/main/verilog/sd_crc_7.v ] \
               [file normalize $base_dir/src/main/verilog/sd_data_serial_host.sv ] \
               [file normalize $base_dir/src/main/verilog/ps2_keyboard.v ] \
               [file normalize $base_dir/src/main/verilog/dualmem.v ] \
               [file normalize $base_dir/src/main/verilog/ps2_defines.v ] \
               [file normalize $base_dir/src/main/verilog/ps2_translation_table.v ] \
               [file normalize $base_dir/src/main/verilog/rx_delay.v ] \
               [file normalize $base_dir/src/main/verilog/fstore2.v ] \
               [file normalize $base_dir/src/main/verilog/ascii_code.v ] \
               [file normalize $base_dir/src/main/verilog/ps2.v ] \
               [file normalize $base_dir/src/main/verilog/sd_defines.h ] \
               [file normalize $base_dir/src/main/verilog/sd_top.sv ] \
               [file normalize $base_dir/src/main/verilog/uart.v ] \
             ]
add_files -norecurse -fileset [get_filesets sources_1] $files

# add include path
set_property include_dirs [list \
                               [file normalize $base_dir/src/main/verilog] \
                               [file normalize $origin_dir/src ]\
                               [file normalize $origin_dir/generated-src] \
                              ] [get_filesets sources_1]

set_property verilog_define [list FPGA FPGA_FULL NEXYS4] [get_filesets sources_1]

# Set 'sources_1' fileset properties
set_property "top" "chip_top" [get_filesets sources_1]

#UART
create_ip -name axi_uart16550 -vendor xilinx.com -library ip -module_name axi_uart16550_0
set_property -dict [list \
                        CONFIG.UART_BOARD_INTERFACE {Custom} \
                        CONFIG.C_S_AXI_ACLK_FREQ_HZ_d {25} \
                       ] [get_ips axi_uart16550_0]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_uart16550_0/axi_uart16550_0.xci]

#BRAM Controller
create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -module_name axi_bram_ctrl_0
set_property -dict [list \
                        CONFIG.DATA_WIDTH $io_data_width \
                        CONFIG.ID_WIDTH $axi_id_width \
                        CONFIG.MEM_DEPTH {16384} \
                        CONFIG.PROTOCOL {AXI4} \
                        CONFIG.BMG_INSTANCE {EXTERNAL} \
                        CONFIG.SINGLE_PORT_BRAM {1} \
                        CONFIG.SUPPORTS_NARROW_BURST {1} \
                       ] [get_ips axi_bram_ctrl_0]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_0.xci]

#ETH RAM Controller
create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -module_name axi_bram_ctrl_1
set_property -dict [list \
                        CONFIG.DATA_WIDTH $io_data_width \
                        CONFIG.ID_WIDTH $axi_id_width \
                        CONFIG.MEM_DEPTH {2048} \
                        CONFIG.PROTOCOL {AXI4} \
                        CONFIG.BMG_INSTANCE {EXTERNAL} \
                        CONFIG.SINGLE_PORT_BRAM {1} \
                        CONFIG.SUPPORTS_NARROW_BURST {0} \
                       ] [get_ips axi_bram_ctrl_1]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_bram_ctrl_1/axi_bram_ctrl_1.xci]

#HID RAM Controller
create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -module_name axi_bram_ctrl_2
set_property -dict [list \
                        CONFIG.DATA_WIDTH $io_data_width \
                        CONFIG.MEM_DEPTH {32768} \
                        CONFIG.PROTOCOL {AXI4LITE} \
                        CONFIG.BMG_INSTANCE {EXTERNAL} \
                        CONFIG.SINGLE_PORT_BRAM {1} \
                        CONFIG.SUPPORTS_NARROW_BURST {1} \
                       ] [get_ips axi_bram_ctrl_2]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_bram_ctrl_2/axi_bram_ctrl_2.xci]

#Dummy Memory Controller (for simulation)
create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -module_name axi_bram_ctrl_3
set_property -dict [list \
                        CONFIG.DATA_WIDTH $mem_data_width \
                        CONFIG.ID_WIDTH $axi_id_width \
                        CONFIG.SINGLE_PORT_BRAM {1} \
                        CONFIG.BMG_INSTANCE {INTERNAL} \
                        CONFIG.MEM_DEPTH {65536} \
                        CONFIG.ECC_TYPE {0} \
                       ] [get_ips axi_bram_ctrl_3]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_bram_ctrl_3/axi_bram_ctrl_3.xci]

# Memory Controller
create_ip -name mig_7series -vendor xilinx.com -library ip -module_name mig_7series_0
set_property CONFIG.XML_INPUT_FILE [file normalize $origin_dir/script/mig_config.prj] [get_ips mig_7series_0]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/mig_7series_0/mig_7series_0.xci]

# AXI clock converter due to the clock difference
create_ip -name axi_clock_converter -vendor xilinx.com -library ip -version 2.1 -module_name axi_clock_converter_0
set_property -dict [list \
                        CONFIG.ADDR_WIDTH {30} \
                        CONFIG.DATA_WIDTH $mem_data_width \
                        CONFIG.ID_WIDTH $axi_id_width \
                        CONFIG.ACLK_ASYNC {0} \
                        CONFIG.ACLK_RATIO {1:2}] \
    [get_ips axi_clock_converter_0]
generate_target {instantiation_template} [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_clock_converter_0/axi_clock_converter_0.xci]

# Clock generators
create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_0
set_property -dict [list \
                        CONFIG.PRIMITIVE {PLL} \
                        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
                        CONFIG.RESET_TYPE {ACTIVE_LOW} \
                        CONFIG.CLKOUT1_DRIVES {BUFG} \
                        CONFIG.MMCM_DIVCLK_DIVIDE {1} \
                        CONFIG.MMCM_CLKFBOUT_MULT_F {10} \
                        CONFIG.MMCM_COMPENSATION {ZHOLD} \
                        CONFIG.MMCM_CLKOUT0_DIVIDE_F {5} \
                        CONFIG.RESET_PORT {resetn} \
                        CONFIG.CLKOUT1_JITTER {114.829} \
                        CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
                        CONFIG.CLKOUT2_DRIVES {BUFG} \
                        CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {60.000} \
                        CONFIG.CLKOUT2_USED {1} \
                        CONFIG.CLK_OUT2_PORT {clk_io_uart} \
                        CONFIG.CLKOUT3_DRIVES {BUFG} \
                        CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {120.000} \
                        CONFIG.CLKOUT3_USED {1} \
                        CONFIG.CLK_OUT3_PORT {clk_pixel} \
                        CONFIG.CLKOUT4_USED {1} \
                        CONFIG.CLKOUT4_DRIVES {BUFG} \
                        CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {50.000} \
                        CONFIG.CLK_OUT4_PORT {clk_rmii} \
                        CONFIG.CLKOUT5_USED {1} \
                        CONFIG.CLKOUT5_DRIVES {BUFG} \
                        CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {50.000} \
                        CONFIG.CLKOUT5_REQUESTED_PHASE {90.000} \
                        CONFIG.CLK_OUT5_PORT {clk_rmii_quad}] \
    [get_ips clk_wiz_0]
generate_target {instantiation_template} [get_files $proj_dir/$project_name.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
#SD-card clock generator
create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_1
set_property -dict [list \
                        CONFIG.PRIMITIVE {MMCM} \
                        CONFIG.USE_DYN_RECONFIG {true} \
                        CONFIG.INTERFACE_SELECTION {Enable_DRP} \
                        CONFIG.PRIM_IN_FREQ {25.000} \
                        CONFIG.CLK_OUT1_PORT {clk_sdclk} \
                        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {5.000} \
                        CONFIG.PHASE_DUTY_CONFIG {false} \
                        CONFIG.CLKIN1_JITTER_PS {400.0} \
                        CONFIG.CLKOUT1_DRIVES {BUFG} \
                        CONFIG.CLKOUT2_DRIVES {BUFG} \
                        CONFIG.CLKOUT3_DRIVES {BUFG} \
                        CONFIG.CLKOUT4_DRIVES {BUFG} \
                        CONFIG.CLKOUT5_DRIVES {BUFG} \
                        CONFIG.CLKOUT6_DRIVES {BUFG} \
                        CONFIG.CLKOUT7_DRIVES {BUFG} \
                        CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
                        CONFIG.MMCM_DIVCLK_DIVIDE {1} \
                        CONFIG.MMCM_CLKFBOUT_MULT_F {25.500} \
                        CONFIG.MMCM_CLKIN1_PERIOD {40.0} \
                        CONFIG.MMCM_COMPENSATION {ZHOLD} \
                        CONFIG.MMCM_CLKOUT0_DIVIDE_F {127.500} \
                        CONFIG.CLKOUT1_JITTER {652.674} \
                        CONFIG.CLKOUT1_PHASE_ERROR {319.966}] [get_ips clk_wiz_1]
generate_target {instantiation_template} [get_files $proj_dir/$project_name.srcs/sources_1/ip/clk_wiz_1/clk_wiz_1.xci]

# SPI interface for R/W SD card
create_ip -name axi_quad_spi -vendor xilinx.com -library ip -module_name axi_quad_spi_0
set_property -dict [list \
                        CONFIG.C_USE_STARTUP {0} \
                        CONFIG.C_SCK_RATIO {2} \
                        CONFIG.C_NUM_TRANSFER_BITS {8}] \
    [get_ips axi_quad_spi_0]
generate_target {instantiation_template} [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_quad_spi_0/axi_quad_spi_0.xci]

# Quad SPI interface for XIP SPI Flash
create_ip -name axi_quad_spi -vendor xilinx.com -library ip -module_name axi_quad_spi_1
set_property -dict [list \
                        CONFIG.C_USE_STARTUP {1} \
                        CONFIG.C_SPI_MEMORY {3} \
                        CONFIG.C_SPI_MODE {2} \
                        CONFIG.C_XIP_MODE {1} \
                        CONFIG.C_SPI_MEM_ADDR_BITS {32} \
                        CONFIG.C_S_AXI4_ID_WIDTH $axi_id_width \
                        CONFIG.C_SCK_RATIO {2} \
                        CONFIG.C_TYPE_OF_AXI4_INTERFACE {1}] \
    [get_ips axi_quad_spi_1]
generate_target {instantiation_template} [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_quad_spi_1/axi_quad_spi_1.xci]

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set files [list [file normalize "$origin_dir/constraint/pin_plan.xdc"] \
	       [file normalize "$origin_dir/constraint/timing.xdc"]]

set file_added [add_files -norecurse -fileset $obj $files]

# generate all IP source code
generate_target all [get_ips]

# force create the synth_1 path (need to make soft link in Makefile)
launch_runs -scripts_only synth_1


# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
set files [list \
               [file normalize $base_dir/src/test/verilog/host_behav.sv] \
               [file normalize $base_dir/src/test/verilog/sd_verilator_model.sv] \
               [file normalize $base_dir/src/test/verilog/nasti_ram_dummy.sv] \
               [file normalize $base_dir/src/test/verilog/chip_top_tb.sv] \
               [file normalize $proj_dir/$project_name.srcs/sources_1/ip/mig_7series_0/mig_7series_0/example_design/sim/ddr2_model.v] \
               [file normalize $base_dir/opensocdebug/glip/src/backend_tcp/logic/dpi/glip_tcp_toplevel.sv] \
              ]
add_files -norecurse -fileset $obj $files

# add include path
set_property include_dirs [list \
                               [file normalize $base_dir/src/main/verilog] \
                               [file normalize $origin_dir/src] \
                               [file normalize $origin_dir/generated-src] \
                               [file normalize $proj_dir/$project_name.srcs/sources_1/ip/mig_7series_0/mig_7series_0/example_design/sim] \
                              ] $obj
#set_property verilog_define [list FPGA FPGA_FULL NEXYS4] $obj
set_property verilog_define [list FPGA NASTI_RAM_DUMMY BOOT_MEM=\"[file normalize $origin_dir/src/boot.mem]\"] $obj

#set_property -name {xsim.elaborate.xelab.more_options} -value {-cc gcc -sv_lib dpi} -objects $obj
set_property "top" "tb" $obj

# force create the sim_1/behav path (need to make soft link in Makefile)
launch_simulation -scripts_only

# suppress some not very useful messages
# warning partial connection
set_msg_config -id "\[Synth 8-350\]" -suppress
# info do synthesis
set_msg_config -id "\[Synth 8-256\]" -suppress
set_msg_config -id "\[Synth 8-638\]" -suppress
# BRAM mapped to LUT due to optimization
set_msg_config -id "\[Synth 8-3969\]" -suppress
# BRAM with no output register
set_msg_config -id "\[Synth 8-4480\]" -suppress
# DSP without input pipelining
set_msg_config -id "\[Drc 23-20\]" -suppress
# Update IP version
set_msg_config -id "\[Netlist 29-345\]" -suppress


# do not flatten design
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
