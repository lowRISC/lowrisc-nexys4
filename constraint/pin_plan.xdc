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
set_property PACKAGE_PIN E5 [get_ports cts]
set_property IOSTANDARD LVCMOS33 [get_ports cts]
set_property PACKAGE_PIN D3 [get_ports rts]
set_property IOSTANDARD LVCMOS33 [get_ports rts]

# SD/SPI Pins
set_property PACKAGE_PIN D2 [get_ports spi_cs]
set_property IOSTANDARD LVCMOS33 [get_ports spi_cs]
set_property PACKAGE_PIN B1 [get_ports spi_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports spi_sclk]
set_property PACKAGE_PIN C1 [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]
set_property PACKAGE_PIN C2 [get_ports spi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]
set_property PACKAGE_PIN E2 [get_ports sd_reset]
set_property IOSTANDARD LVCMOS33 [get_ports sd_reset]

# Flash/SPI Pins
set_property PACKAGE_PIN L13 [get_ports flash_ss]
set_property IOSTANDARD LVCMOS33 [get_ports flash_ss]
set_property PACKAGE_PIN K17 [get_ports flash_io[0]]
set_property IOSTANDARD LVCMOS33 [get_ports flash_io[0]]
set_property PACKAGE_PIN K18 [get_ports flash_io[1]]
set_property IOSTANDARD LVCMOS33 [get_ports flash_io[1]]
set_property PACKAGE_PIN L14 [get_ports flash_io[2]]
set_property IOSTANDARD LVCMOS33 [get_ports flash_io[2]]
set_property PACKAGE_PIN M14 [get_ports flash_io[3]]
set_property IOSTANDARD LVCMOS33 [get_ports flash_io[3]]
