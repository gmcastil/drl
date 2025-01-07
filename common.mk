CTAGS		= ctags

CTAGS_FLAGS     =
# Recursively generate tags and don't append to anything existing
CTAGS_FLAGS     += -R --append=no

# Set up languages and extensions
CTAGS_FLAGS     += --languages=SystemVerilog,VHDL,Verilog 
CTAGS_FLAGS     += --langmap=Verilog:.v.vh
CTAGS_FLAGS     += --langmap=SystemVerilog:.sv.svh
CTAGS_FLAGS     += --langmap=VHDL:.vhd.vhdl

