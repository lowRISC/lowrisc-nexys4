# Xilinx Vivado script
# Version: Vivado 2015.4
# Function:
#   Generate a vivado project for the lowRISC SoC

set mem_data_width {64}
set io_data_width {32}
set axi_id_width {4}

set origin_dir "."
set base_dir "../../.."
set common_dir "../../common"

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
               [file normalize $base_dir/rocket-chip/vsim/generated-src/freechips.rocketchip.system.$CONFIG.v] \
               [file normalize $base_dir/src/main/verilog/chip_top.sv] \
               [file normalize $base_dir/src/main/verilog/periph_soc.sv] \
               [file normalize $base_dir/src/main/verilog/framing_top.sv] \
               [file normalize $base_dir/src/main/verilog/axis_gmii_rx.v] \
               [file normalize $base_dir/src/main/verilog/axis_gmii_tx.v] \
               [file normalize $base_dir/src/main/verilog/lfsr.v] \
               [file normalize $base_dir/src/main/verilog/rx_delay.v] \
               [file normalize $base_dir/src/main/verilog/ps2.v] \
               [file normalize $base_dir/src/main/verilog/ps2_keyboard.v] \
               [file normalize $base_dir/src/main/verilog/ps2_translation_table.v] \
               [file normalize $base_dir/src/main/verilog/my_fifo.v] \
               [file normalize $base_dir/src/main/verilog/fstore2.v] \
               [file normalize $base_dir/src/main/verilog/dualmem.v] \
               [file normalize $base_dir/src/main/verilog/uart.v] \
               [file normalize $base_dir/src/main/verilog/sd_top.sv] \
               [file normalize $base_dir/src/main/verilog/sd_crc_7.v] \
               [file normalize $base_dir/src/main/verilog/sd_crc_16.v] \
               [file normalize $base_dir/src/main/verilog/sd_cmd_serial_host.v] \
               [file normalize $base_dir/src/main/verilog/sd_data_serial_host.sv] \
               [file normalize $base_dir/src/main/verilog/nasti_channel.sv] \
               [file normalize $base_dir/vsrc/AsyncResetReg.v ] \
               [file normalize $base_dir/vsrc/plusarg_reader.v ] \
               [file normalize $base_dir/src/main/verilog/ascii_code.v] \
               [file normalize $base_dir/src/main/verilog/axis_gmii_rx.v] \
               [file normalize $base_dir/src/main/verilog/axis_gmii_tx.v] \
               [file normalize $base_dir/src/main/verilog/dualmem_32K_64.sv] \
               [file normalize $base_dir/src/main/verilog/dualmem.v] \
               [file normalize $base_dir/src/main/verilog/dualmem_widen.v] \
               [file normalize $base_dir/src/main/verilog/dualmem_widen8.v] \
               [file normalize $base_dir/src/main/verilog/eth_lfsr.v] \
               [file normalize $base_dir/src/main/verilog/fpga_srams_generate.sv] \
               [file normalize $base_dir/src/main/verilog/my_fifo.v] \
               [file normalize $base_dir/src/main/verilog/rachelset.v] \
               [file normalize $base_dir/src/main/verilog/stubs.sv] \
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

#Dummy BRAM Controller
create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -module_name axi_bram_ctrl_dummy
set_property -dict [list \
                        CONFIG.DATA_WIDTH $mem_data_width \
                        CONFIG.ID_WIDTH $axi_id_width \
                        CONFIG.MEM_DEPTH {32768} \
                        CONFIG.PROTOCOL {AXI4} \
                        CONFIG.BMG_INSTANCE {EXTERNAL} \
                        CONFIG.SINGLE_PORT_BRAM {1} \
                        CONFIG.SUPPORTS_NARROW_BURST {1} \
                       ] [get_ips axi_bram_ctrl_dummy]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_bram_ctrl_dummy/axi_bram_ctrl_dummy.xci]

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
               [file normalize $base_dir/src/test/verilog/nasti_ram_behav.sv] \
               [file normalize $base_dir/src/test/verilog/chip_top_tb.sv] \
               [file normalize $proj_dir/$project_name.srcs/sources_1/ip/mig_7series_0/mig_7series_0/example_design/sim/ddr2_model.v] \
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
set_property verilog_define [list FPGA] $obj

set_property -name {xsim.elaborate.xelab.more_options} -value {-cc gcc -sv_lib dpi} -objects $obj
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
