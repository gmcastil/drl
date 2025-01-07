include ../common.mk

# Directories to exclude when creating a tags file. This prevents creating tags
# that reference Xilinx IP or project files 
CTAGS_EXCLUDE_DIRS	=
CTAGS_EXCLUDE_DIRS	+= .git doc
CTAGS_FLAGS		+= $(foreach dir,$(CTAGS_EXCLUDE_DIRS), --exclude=$(dir))

IF_DIR			= ../interfaces
TB_DIR			= ./sim
RTL_DIR			= ./src/rtl
PKG_DIR			= ./src/packages

WORK			= work

.PHONY: sim
sim:
	if [ -d $(WORK) ]; then $(VDEL) -all $(WORK); fi
	$(VLIB) $(WORK)
	$(VLOG) $(IF_DIR)/axi4l_if.sv

.PHONY: ctags
ctags:
	$(CTAGS) $(CTAGS_FLAGS) .

.PHONY: clean
clean:
	rm -f tags

