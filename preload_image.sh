#!/bin/bash

if [ $# != 1 ] ; then
    echo "Wrong number of arguments."
    echo "preload_image /PATH/TO/SD/"
else
    echo "====================================="
    echo "compile and copy bbl"
    echo "====================================="
    make bbl
    mv bbl/bbl $1boot
    echo "====================================="
    echo "download and copy Linux kernel"
    echo "====================================="
    curl -L https://github.com/lowrisc/lowrisc-kc705-images/raw/master/vmlinux.tar.gz | tar -zx
    mv vmlinux $1vmlinux
    echo "====================================="
    echo "download and copy ramdisk"
    echo "====================================="
    curl -L https://github.com/lowrisc/lowrisc-kc705-images/raw/master/root.bin.tar.gz | tar -zx
    mv root.bin $1root.bin
fi
