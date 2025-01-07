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
VSIM		= vsim
VLOG		= vlog
VCOM		= vcom
VLIB		= vlib
VDEL		= vdel

# Xilinx simulation library locations. These are referenced in the
# modelsim.ini file that each simulation is expected to use and can be
# overriden by the user if desired.


