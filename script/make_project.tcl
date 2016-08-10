# Xilinx Vivado script
# Version: Vivado 2015.4
# Function:
#   Generate a vivado project for the lowRISC SoC

set mem_data_width {64}
set io_data_width {32}
set axi_id_width {8}

set origin_dir "."
set base_dir "../../.."
set osd_dir "../../../opensocdebug/hardware"
set glip_dir "../../../opensocdebug/glip/src"
set common_dir "../../common"
set greth_dir "../../../greth-library"

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
               [file normalize $origin_dir/generated-src/Top.$CONFIG.v] \
               [file normalize $osd_dir/interfaces/common/dii_channel.sv ] \
               [file normalize $base_dir/src/main/verilog/chip_top.sv] \
               [file normalize $base_dir/src/main/verilog/spi_wrapper.sv] \
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
               [file normalize $glip_dir/common/logic/interface/glip_channel.sv] \
               [file normalize $greth_dir/greth_library/commonlib/types_common.vhd] \
               [file normalize $greth_dir/greth_library/ambalib/types_amba4.vhd] \
               [file normalize $greth_dir/greth_library/techmap/mem/types_mem.vhd] \
               [file normalize $greth_dir/greth_library/techmap/mem/syncram_2p_inferred.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/eth/eth_rstgen.vhd] \
               [file normalize $greth_dir/greth_library/techmap/gencomp/gencomp.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/eth/greth_pkg.vhd] \
               [file normalize $greth_dir/greth_library/techmap/mem/syncram_2p_tech.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/eth/greth_tx.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/eth/greth_rx.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/ibuf_inferred.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/eth/grethc64.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/eth/eth_axi_mst.vhd] \
               [file normalize $greth_dir/greth_library/techmap/pll/types_pll.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/types_buf.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/iobuf_virtex6.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/iobuf_inferred.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/igdsbuf_a7.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/types_rocket.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/ibuf_tech.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/eth/grethaxi.vhd] \
               [file normalize $greth_dir/greth_library/techmap/pll/SysPLL_tech.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/misc/reset_glb.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/misc/nasti_gpio.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/iobuf_tech.vhd] \
               [file normalize $greth_dir/greth_library/work/config_common.vhd] \
               [file normalize $greth_dir/greth_library/work/config_a7.vhd] \
               [file normalize $greth_dir/greth_library/ambalib/axictrl.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/igdsbuf_tech.vhd] \
               [file normalize $greth_dir/greth_library/work/rocket_soc_nexys4.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/bufgmux_fpga.vhd] \
               [file normalize $greth_dir/greth_library/techmap/bufg/bufgmux_tech.vhd] \
               [file normalize $greth_dir/greth_library/gnsslib/types_gnss.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/tilelink/htifctrl.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/misc/nasti_uart.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/misc/nasti_pnp.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/misc/nasti_irqctrl.vhd] \
               [file normalize $greth_dir/greth_library/rocketlib/misc/nasti_dsu.vhd] \
               [file normalize $greth_dir/greth_library/gnsslib/sync/types_sync.vhd] \
               [file normalize $greth_dir/greth_library/commonlib/types_util.vhd] \
             ]

add_files -norecurse -fileset [get_filesets sources_1] $files

# Set 'sources_1' fileset file properties for VHDL files
set file "$greth_dir/greth_library/commonlib/types_common.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "commonlib" $file_obj

set file "$greth_dir/greth_library/ambalib/types_amba4.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "ambalib" $file_obj

set file "$greth_dir/greth_library/techmap/mem/types_mem.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/techmap/mem/syncram_2p_inferred.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/rocketlib/eth/eth_rstgen.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/techmap/gencomp/gencomp.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/rocketlib/eth/greth_pkg.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/techmap/mem/syncram_2p_tech.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/rocketlib/eth/greth_tx.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/rocketlib/eth/greth_rx.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/ibuf_inferred.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/rocketlib/eth/grethc64.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/rocketlib/eth/eth_axi_mst.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/techmap/pll/types_pll.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/types_buf.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/iobuf_virtex6.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/iobuf_inferred.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/igdsbuf_a7.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/rocketlib/types_rocket.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/ibuf_tech.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/rocketlib/eth/grethaxi.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/techmap/pll/SysPLL_tech.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/rocketlib/misc/reset_glb.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/rocketlib/misc/nasti_gpio.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/iobuf_tech.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/work/config_common.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "work" $file_obj

set file "$greth_dir/greth_library/work/config_a7.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "work" $file_obj

set file "$greth_dir/greth_library/ambalib/axictrl.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "ambalib" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/igdsbuf_tech.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/work/rocket_soc_nexys4.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "work" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/bufgmux_fpga.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/techmap/bufg/bufgmux_tech.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "techmap" $file_obj

set file "$greth_dir/greth_library/gnsslib/types_gnss.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "gnsslib" $file_obj

set file "$greth_dir/greth_library/rocketlib/tilelink/htifctrl.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/rocketlib/misc/nasti_uart.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/rocketlib/misc/nasti_pnp.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/rocketlib/misc/nasti_irqctrl.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/rocketlib/misc/nasti_dsu.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "rocketlib" $file_obj

set file "$greth_dir/greth_library/gnsslib/sync/types_sync.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "gnsslib" $file_obj

set file "$greth_dir/greth_library/commonlib/types_util.vhd"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property "file_type" "VHDL" $file_obj
set_property "library" "commonlib" $file_obj

# add include path
set_property include_dirs [list \
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

# Clock generator
create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_0
set_property -dict [list \
                        CONFIG.PRIMITIVE {PLL} \
                        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
                        CONFIG.RESET_TYPE {ACTIVE_LOW} \
                        CONFIG.CLKOUT1_DRIVES {BUFG} \
                        CONFIG.MMCM_COMPENSATION {ZHOLD} \
                        CONFIG.RESET_PORT {resetn} \
			CONFIG.NUM_OUT_CLKS {4} \
			CONFIG.CLKOUT2_USED {true} \
			CONFIG.CLKOUT3_USED {true} \
			CONFIG.CLKOUT4_USED {true} \
			CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {15.000} \
			CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {50.0} \
			CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {50.000} \
			CONFIG.CLKOUT4_REQUESTED_PHASE {90.000} \
			CONFIG.MMCM_DIVCLK_DIVIDE {1} \
			CONFIG.MMCM_CLKFBOUT_MULT_F {12} \
			CONFIG.MMCM_CLKOUT0_DIVIDE_F {6} \
			CONFIG.MMCM_CLKOUT1_DIVIDE {80} \
			CONFIG.MMCM_CLKOUT2_DIVIDE {24} \
			CONFIG.MMCM_CLKOUT3_DIVIDE {24} \
			CONFIG.MMCM_CLKOUT3_PHASE {90.000} \
			CONFIG.CLKOUT1_JITTER {102.086} \
			CONFIG.CLKOUT1_PHASE_ERROR {87.180} \
			CONFIG.CLKOUT2_JITTER {173.818} \
			CONFIG.CLKOUT2_PHASE_ERROR {87.180} \
			CONFIG.CLKOUT3_JITTER {132.683} \
			CONFIG.CLKOUT3_PHASE_ERROR {87.180} \
			CONFIG.CLKOUT4_JITTER {132.683} \
			CONFIG.CLKOUT4_PHASE_ERROR {87.180} \
			] \
    [get_ips clk_wiz_0]

generate_target {instantiation_template} [get_files $proj_dir/$project_name.srcs/sources_1/ip/clk_wiz_0_1/clk_wiz_0.xci]

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
set file "[file normalize "$origin_dir/constraint/pin_plan.xdc"]"
set file_added [add_files -norecurse -fileset $obj $file]

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
               [file normalize $base_dir/opensocdebug/glip/src/backend_tcp/logic/dpi/glip_tcp_toplevel.sv] \
              ]
add_files -norecurse -fileset $obj $files

# add include path
set_property include_dirs [list \
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

