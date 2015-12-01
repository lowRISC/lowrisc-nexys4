# on board single-end clock, 100MHz
set_property PACKAGE_PIN E3 [get_ports clk_p]
set_property IOSTANDARD LVCMOS33 [get_ports clk_p]

# Reset active high SW4.1 User button South
set_property IOSTANDARD LVCMOS33 [get_ports {rst_top}]
set_property LOC C12 [get_ports {rst_top}]

# UART Pins
set_property PACKAGE_PIN C4 [get_ports rxd]
set_property IOSTANDARD LVCMOS33 [get_ports rxd]
set_property PACKAGE_PIN D4 [get_ports txd]
set_property IOSTANDARD LVCMOS33 [get_ports txd]

# SD/SPI Pins
set_property PACKAGE_PIN D2 [get_ports spi_cs]
set_property IOSTANDARD LVCMOS33 [get_ports spi_cs]
set_property PACKAGE_PIN B1 [get_ports spi_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports spi_sclk]
set_property PACKAGE_PIN C1 [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]
set_property PACKAGE_PIN C2 [get_ports spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]
