set_false_path -reset_path -from [get_clocks clk_io_uart_clk_wiz_0] -to [get_clocks mmcm_clkout0]
set_false_path -reset_path -from [get_clocks mmcm_clkout0] -to [get_clocks clk_io_uart_clk_wiz_0]
set_multicycle_path -from [get_pins msoc/tx_fifo/FIFO18E1_inst_36/RDCLK] 2
set_multicycle_path -from [get_pins msoc/rx_fifo/FIFO18E1_inst_36/WRCLK] 2
