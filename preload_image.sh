#!/bin/bash

if [ $# != 1 ] ; then
    echo "Wrong number of arguments."
    echo "preload_image /PATH/TO/SD/"
else
    echo "====================================="
    echo "download the boot image"
    echo "====================================="
    curl -L https://github.com/lowRISC/lowrisc-chip/releases/download/v0.3/boot.bin > $1boot.bin
    echo "====================================="
    echo "download and copy FPGA bitstream"
    echo "====================================="
    curl -L https://github.com/lowRISC/lowrisc-chip/releases/download/v0.3/nexys4ddr_fpga_standalone.bit > $1chip_top.bit
fi
