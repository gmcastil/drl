# Tool versions, path to the tools, and location of Xilinx simulation libraries
# are set and exported here
include ../tools.conf
include ../common.mk

RUN_DIR			:= $(shell readlink -f ./rundir)
TB_DIR			:= ./
SIM_DIR			:= ./sim
WORK			:= work

.PHONY: env
env:
	mkdir -pv $(RUN_DIR)
	if [[ -d $(RUN_DIR)/$(WORK) ]]; then $(VDEL) -lib $(RUN_DIR)/$(WORK) -all; fi
	$(VLIB) $(RUN_DIR)/$(WORK)
	$(VMAP) $(WORK) $(RUN_DIR)/$(WORK)

	$(VLOG) -work $(WORK) -sv $(TB_DIR)/common/common_pkg.sv
	$(VLOG) -work $(WORK) -sv $(TB_DIR)/base/base_pkg.sv
	$(VLOG) -work $(WORK) -sv $(TB_DIR)/tests/tests_pkg.sv
	$(VLOG) -work $(WORK) -sv $(SIM_DIR)/top.sv

