`ifndef LOGGING_TYPES_SVH
`define LOGGING_TYPES_SVH

// Indicate log verbosity level (only applies to info and debug)
typedef enum int {
    LOG_NONE   = 0,    // No info messages
    LOG_LOW    = 100,  // Minimal, high-level messages
    LOG_MEDIUM = 200,  // Default verbosity, key testbench activity
    LOG_HIGH   = 300,  // More detail, transaction-level logs
    LOG_FULL   = 400,  // Deep debugging info
    LOG_DEBUG  = 500   // Most verbose, fine-grained internal debug
} log_level_t;

// Indicate log severity. Warnings and above will always print, with
// fatal logs also serving as a point of exit for the simulation,
// with line numbers and filenames that actually triggered the exit
// condition.
typedef enum {
    LOG_INFO,
    LOG_WARN,
    LOG_ERROR,
    LOG_FATAL 
} log_severity_t;

`endif

