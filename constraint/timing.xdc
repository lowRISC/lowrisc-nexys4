create_clock -period 10.000 -name clk_p -waveform {0.000 5.000} [get_ports clk_p]
create_clock -period 10.000 -name tck -waveform {0.000 5.000} [get_pins dut/i_SimJTAG/BSCANE2_inst1/TCK]
