# Tool versions, path to the tools, and location of Xilinx simulation libraries
# are set and exported here
include ../tools.conf
include ../common.mk
# Verification components and targets
include ../verif/verif.mk

# Sanity checks here
ifndef XILINX_SIMLIB_DIR
$(error XILINX_SIMLIB_DIR is unset and should point to Xilinx simulation libraries)
endif

ifndef MODELSIM
$(error MODELSIM is unset and should point to location of modelsim.ini)
endif

# Directories to exclude when creating a tags file. This prevents creating tags
# that reference Xilinx IP or project files 
CTAGS_EXCLUDE_DIRS	=
CTAGS_EXCLUDE_DIRS	+= .git doc
CTAGS_FLAGS		+= $(foreach dir,$(CTAGS_EXCLUDE_DIRS), --exclude=$(dir))

# Project specific build flags
VCOM_FLAGS		= -2008 -lint

# Project specific testbench files and locations
RUN_DIR			:= $(shell readlink -f ./rundir)
TB_DIR			:= ./sim
# Name of the work directory defined by the mapping made in the
# modelsim.ini file (not the location of the library)
WORK			:= work

# DUT source files and locations
DRL_DIR			:= ..
SRC_DIR			:= ./src
RTL_DIR			:= $(SRC_DIR)/rtl
PKG_DIR			:= $(SRC_DIR)/packages

DUT_FILES		:= $(SRC_DIR)/uart.f

.PHONY: sim
sim: verif dut
	@echo "Would build project testbench components"
	# $(VLOG) -work $(WORK) +incdir+$(DRL_DIR)/packages/axi4l -sv $(DRL_DIR)/packages/axi4l/axi4l_pkg.sv
	# $(VLOG) -work $(WORK) -sv $(DRL_DIR)/interfaces/axi4l_if.sv
	# $(VLOG) -work $(WORK) -sv $(TB_DIR)/uart_wrapper.sv
	# $(VLOG) -work $(WORK) -sv $(TB_DIR)/top.sv

.PHONY: dut
dut: lib
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/macros/fifo_sync.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/skid-buffer/src/rtl/skid_buffer.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/axi4l-regs/src/packages/reg_pkg.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/axi4l-regs/src/rtl/axi4l_regs.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) $(DRL_DIR)/axi4l-regs/src/rtl/reg_block.vhd
	$(VCOM) -work $(WORK) $(VCOM_FLAGS) -f $(DUT_FILES)

# Create an empty work directory at rundir/$(WORK)
.PHONY: lib
lib:
	mkdir -pv $(RUN_DIR)
	if [[ -d $(RUN_DIR)/$(WORK) ]]; then \
		$(VDEL) -lib $(RUN_DIR)/$(WORK) -all; \
	fi
	$(VLIB) $(RUN_DIR)/$(WORK)
	$(VMAP) $(WORK) $(RUN_DIR)/$(WORK)

.PHONY: ctags
ctags:
	$(CTAGS) $(CTAGS_FLAGS) .

.PHONY: clean
clean:
	rm -f tags
	if [[ -d $(RUN_DIR)/$(WORK) ]]; then \
		$(VDEL) -lib $(RUN_DIR)/$(WORK) -all; \
		rmdir $(RUN_DIR); \
	fi

.PHONY: check
check:
	@echo MODELSIM = $(MODELSIM)
	@echo XILINX_SIMLIB_DIR = $(XILINX_SIMLIB_DIR)
	$(VDIR) -all

.PHONY: list
list:
	$(VDIR) -lib $(RUN_DIR)/$(WORK)
	$(VDIR) $(WORK)

