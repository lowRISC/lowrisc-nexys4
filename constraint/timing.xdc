create_clock -period 10.000 -name clk_p -waveform {0.000 5.000} [get_ports clk_p]
set_false_path -reset_path -from [get_clocks clk_io_uart_clk_wiz_0] -to [get_clocks mmcm_clkout0]
set_false_path -reset_path -from [get_clocks mmcm_clkout0] -to [get_clocks clk_io_uart_clk_wiz_0]

create_clock -period 100.000 -name BSCANE2_inst1/TCK -waveform {0.000 50.000} [get_pins BSCANE2_inst1/TCK]
