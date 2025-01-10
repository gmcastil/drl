SHELL			:= /bin/bash

# Variables used for generating ctags and scope values
CTAGS		= ctags

CTAGS_FLAGS     =
# Recursively generate tags and don't append to anything existing
CTAGS_FLAGS     += -R --append=no

# Set up languages and extensions
CTAGS_FLAGS     += --languages=SystemVerilog,VHDL,Verilog 
CTAGS_FLAGS     += --langmap=Verilog:.v.vh
CTAGS_FLAGS     += --langmap=SystemVerilog:.sv.svh
CTAGS_FLAGS     += --langmap=VHDL:.vhd.vhdl

# Questa Sim tools - these need to be in the PATH and it would be wise to
# control the environment such that these tool versions match those that the
# Xilinx simulation libraries were compiled for.
VSIM		:= vsim
VLOG		:= vlog
VCOM		:= vcom
VLIB		:= vlib
VDEL		:= vdel

# Specify the path to the modelsim.ini file - this forces us to use the local
# version which references the Xilinx simulation library path
MODELSIM		:= $(shell readlink -f sim/modelsim.ini)
export MODELSIM

