# External caller needs to create, map, and supply the library to compile
# verification components into. Specifically, the WORK and VLOG_FLAGS values
# need to be set

VERIF_ROOT		:= $(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: verif
verif:
	@if [[ -z "$(WORK)" ]]; then \
		printf '%s\n' "Error: WORK is unset" >&2; \
		exit 1; \
	fi
	$(VLOG) -work $(WORK) \
		$(VLOG_FLAGS) \
		+incdir+$(VERIF_ROOT)/include \
		+incdir+$(VERIF_ROOT)/common \
		+incdir+$(VERIF_ROOT)/base \
		$(VERIF_ROOT)/verif_pkg.sv

