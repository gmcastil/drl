`ifndef VERIF_MACROS_H
`define VERIF_MACROS_H

// Checking for null objects is quite common, so we provide a convenience macro
// to log this the same way the rest of the framework does.
`define FATAL_IF_NULL(obj, name) \
    if (obj == null) begin \
        logger::log(LOG_FATAL, name, "Failed null pointer check", "NULL"); \
    `ifndef NO_STACKTRACE_SUPPORT \
        $stacktrace; \
    `endif \
        $fflush(); \
        $fatal(1); \
    end

`endif  // VERIF_MACROS_H
