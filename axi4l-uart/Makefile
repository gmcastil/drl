include ../common.mk

# Directories to exclude when creating a tags file. This prevents creating tags
# that reference Xilinx IP or project files 
CTAGS_EXCLUDE_DIRS	=
CTAGS_EXCLUDE_DIRS	+= .git doc
CTAGS_FLAGS		+= $(foreach dir,$(CTAGS_EXCLUDE_DIRS), --exclude=$(dir))

EXTERN_DIR		:= ..
IF_DIR			:= $(EXTERN_DIR)/interfaces

TB_DIR			:= ./sim
SRC_DIR			:= ./src
RTL_DIR			:= $(SRC_DIR)/rtl
PKG_DIR			:= $(SRC_DIR)/packages

DUT_FILES		:= $(SRC_DIR)/uart.f
TB_FILES		:= $(TB_DIR)/tb.f

WORK			:= work

.PHONY: sim
sim:
	if [ -d $(WORK) ]; then $(VDEL) -all $(WORK); fi
	$(VLIB) $(WORK)
	$(VCOM) -work $(WORK) -2008 $(EXTERN_DIR)/macros/fifo_sync.vhd
	$(VCOM) -work $(WORK) -2008 $(EXTERN_DIR)/skid-buffer/src/rtl/skid_buffer.vhd
	$(VCOM) -work $(WORK) -2008 $(EXTERN_DIR)/axi4l-regs/src/packages/reg_pkg.vhd
	$(VCOM) -work $(WORK) -2008 $(EXTERN_DIR)/axi4l-regs/src/rtl/axi4l_regs.vhd
	$(VCOM) -work $(WORK) -2008 $(EXTERN_DIR)/axi4l-regs/src/rtl/reg_block.vhd
	$(VCOM) -work $(WORK) -2008 -f $(DUT_FILES)
	$(VLOG) -work $(WORK) -sv $(TB_FILES)


.PHONY: ctags
ctags:
	$(CTAGS) $(CTAGS_FLAGS) .

.PHONY: clean
clean:
	rm -f tags

