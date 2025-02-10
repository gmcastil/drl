// Define log levels used by testbench components
typedef enum {
    LOG_FATAL,  // Critical issues that halt simulation
    LOG_ERROR,  // Errors requiring attention
    LOG_WARN,   // Alerts about potential issues
    LOG_INFO,   // General operational messages
    LOG_DEBUG   // Detailed debugging information
} log_level_t;

// Default log level for new testbench components (can be overriden locally)
log_level_t default_log_level = LOG_INFO;

// Static class used for all logging activities
class logger;

    static function void set_default_log_level(log_level_t level);
        default_log_level = level;
    endfunction: set_default_log_level

    static function log_level_t get_default_log_level();
        return default_log_level;
    endfunction: get_default_log_level

    static function void log(log_level_t level, string component_name, string msg, string id);
        string level_name;
        string msg_fmt;

        // UVM like log messages, with optional ID field
        if (id == "") begin
            msg_fmt = "%s @ %0t: (%s) %s";
        end else begin
            msg_fmt = "%s @ %0t: (%s) [%s] %s";
        end
        // Extract the log level name and format the output
        level_name = level.name();
        $display(msg_fmt,
            level_name.substr(4, level_name.len()-1),  // Strip "LOG_" prefix
            $time, component_name, id, msg);
            $fflush;

    endfunction: log

endclass: logger
