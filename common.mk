SHELL			:= /bin/bash
# Root directory for ECAD tools
TOOLS_ROOT		:= /tools

VIVADO_VERSION		:= 2024.1
SIM_VERSION		:= questa_fe
QUESTA_VERSION		:= 22.2

VIVADO_ROOT_DIR		:= $(TOOLS_ROOT)/Xilinx/Vivado/$(VIVADO_VERSION)

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

# Questa Sim tools
VSIM		:= vsim
VLOG		:= vlog
VCOM		:= vcom
VLIB		:= vlib
VDEL		:= vdel

# Xilinx simulation library locations. These are referenced in the
# modelsim.ini file that each simulation is expected to use and can be
# overriden by the user if desired.
XILINX_SIMLIB_DIR	:= /tools/lib/$(VIVADO_VERSION)/$(SIM_VERSION)/$(QUESTA_VERSION)
# Specify the path to the modelsim.ini file - this forces us to use the local
# version which references the Xilinx simulation library path
MODELSIM		:= $(shell readlink -f sim/modelsim.ini)

export XILINX_SIMLIB_DIR
export MODELSIM

