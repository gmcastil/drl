`ifndef LOGGING_TYPES_SVH
`define LOGGING_TYPES_SVH

// Indicate log verbosity
typedef enum {
    LOG_NONE,
    LOG_LOW,
    LOG_MEDIUM,
    LOG_HIGH,
    LOG_DEBUG
} log_level_t;

// Indicate log severity
typedef enum {
    LOG_INFO,
    LOG_WARN,
    LOG_ERROR,
    LOG_FATAL 
} log_severity_t;

`endif

