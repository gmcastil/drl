include ../common.mk

# Directories to exclude when creating a tags file. This prevents creating tags
# that reference Xilinx IP or project files 
CTAGS_EXCLUDE_DIRS	=
CTAGS_EXCLUDE_DIRS	+= .git doc
CTAGS_FLAGS		+= $(foreach dir,$(CTAGS_EXCLUDE_DIRS), --exclude=$(dir))

.PHONY: ctags
ctags:
	$(CTAGS) $(CTAGS_FLAGS) .

.PHONY: clean
clean:
	rm -f tags

