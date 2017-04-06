set_false_path -reset_path -from [get_clocks clk_io_uart_clk_wiz_0] -to [get_clocks mmcm_clkout0]
set_false_path -reset_path -from [get_clocks mmcm_clkout0] -to [get_clocks clk_io_uart_clk_wiz_0]
set_false_path -from [get_pins msoc/tx_fifo/FIFO18E1_inst_36/RDCLK]
set_false_path -from [get_pins msoc/rx_fifo/FIFO18E1_inst_36/WRCLK]
set_false_path -from [get_pins genblk1[0].RAMB16_S9_S9_inst/CLKBWRCLK]
set_false_path -from [get_pins genblk1[1].RAMB16_S9_S9_inst/CLKBWRCLK]
set_false_path -from [get_pins genblk1[2].RAMB16_S9_S9_inst/CLKBWRCLK]
set_false_path -from [get_pins genblk1[3].RAMB16_S9_S9_inst/CLKBWRCLK]

set_multicycle_path -from [get_pins {msoc/sd_blksize_reg_reg[*]/C}] -to [get_pins {msoc/sd_blksize_reg[*]/D}] 4
set_multicycle_path -from [get_pins {msoc/sd_cmd_timeout_reg_reg[*]/C}] -to [get_pins {msoc/sd_cmd_timeout_reg[*]/D}] 4

create_generated_clock -name sd_clock_divider -source [get_pins clk_gen/inst/plle2_adv_inst/CLKOUT3] -divide_by 2 [get_pins msoc/clock_divider0/SD_CLK_buf_inst/O]
