# Tool versions, path to the tools, and location of Xilinx simulation libraries
# are set and exported here
include ../tools.conf
include ../common.mk

# Directories to exclude when creating a tags file. This prevents creating tags
# that reference Xilinx IP or project files 
CTAGS_EXCLUDE_DIRS	=
CTAGS_EXCLUDE_DIRS	+= .git doc
CTAGS_FLAGS		+= $(foreach dir,$(CTAGS_EXCLUDE_DIRS), --exclude=$(dir))

VCOM_FLAGS		= -2008 -lint

DRL_DIR			:= ..

RUN_DIR			:= $(shell readlink -f ./rundir)
TB_DIR			:= ./sim
SRC_DIR			:= ./src
RTL_DIR			:= $(SRC_DIR)/rtl
PKG_DIR			:= $(SRC_DIR)/packages

DUT_FILES		:= $(SRC_DIR)/uart.f

# Name of the work directory defined by the mapping made in the
# modelsim.ini file (not the location of the library)
WORK			:= work

.PHONY: sim
sim:
	mkdir -pv $(RUN_DIR)
	if [[ -d $(RUN_DIR)/$(WORK) ]]; then $(VDEL) -lib $(RUN_DIR)/$(WORK) -all; fi
	$(VLIB) $(RUN_DIR)/$(WORK)
	$(VMAP) $(WORK) $(RUN_DIR)/$(WORK)

	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/macros/fifo_sync.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/skid-buffer/src/rtl/skid_buffer.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/axi4l-regs/src/packages/reg_pkg.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/axi4l-regs/src/rtl/axi4l_regs.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/axi4l-regs/src/rtl/reg_block.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) -f $(DUT_FILES)

	$(VLOG) -work $(WORK) +incdir+$(DRL_DIR)/packages/axi4l -sv $(DRL_DIR)/packages/axi4l/axi4l_pkg.sv
	$(VLOG) -work $(WORK) -sv $(DRL_DIR)/interfaces/axi4l_if.sv
	$(VLOG) -work $(WORK) +incdir+$(TB_DIR) +incdir+$(TB_DIR)/sequences -sv $(TB_DIR)/uart_tb_pkg.sv
	$(VLOG) -work $(WORK) +incdir+$(TB_DIR)/tests -sv $(TB_DIR)/tests/uart_tests_pkg.sv
	$(VLOG) -work $(WORK) -sv $(TB_DIR)/uart_wrapper.sv
	$(VLOG) -work $(WORK) -sv $(TB_DIR)/top.sv

.PHONY: ctags
ctags:
	$(CTAGS) $(CTAGS_FLAGS) .

.PHONY: clean
clean:
	rm -f tags

.PHONY: test
test:
	@echo MODELSIM = $(MODELSIM)
	@echo XILINX_SIMLIB_DIR = $(XILINX_SIMLIB_DIR)

