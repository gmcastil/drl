// Define log levels used by testbench components
typedef enum {
    LOG_DEBUG,              // Detailed debugging information
    LOG_INFO,               // General operational messages
    LOG_WARNING,            // Alerts about potential issues
    LOG_ERROR,              // Errors requiring attention
    LOG_FATAL               // Critical issues that halt simulation
} log_level_t;

// Default log level for new testbench components (can be overriden locally)
log_level_t default_log_level = LOG_INFO;

