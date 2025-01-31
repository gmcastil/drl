# External caller needs to create, map, and supply the library to compile
# verification components into

VERIF_ROOT		:= $(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: verif
verif:
	@if [[ -z "$(WORK)" ]]; then \
		printf '%s\n' "Error: WORK is unset" >&2; \
		exit 1; \
	fi
	$(VLOG) -work $(WORK) +INCDIR+$(VERIF_ROOT)/common $(VLOG_FLAGS) $(VERIF_ROOT)/common/common_pkg.sv
	$(VLOG) -work $(WORK) +INCDIR+$(VERIF_ROOT)/base $(VLOG_FLAGS) $(VERIF_ROOT)/base/base_pkg.sv

