// Define log levels used by testbench components
typedef enum {
    LOG_DEBUG,      // Detailed debugging information
    LOG_INFO,       // General operational messages
    LOG_WARN,       // Alerts about potential issues
    LOG_ERROR,      // Errors requiring attention
    LOG_FATAL       // Critical issues that halt simulation
} log_level_t;

// Default log level for new testbench components (can be overriden locally)
log_level_t default_log_level = LOG_INFO;

// Static class used for all logging activities
class logger;

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


// Save this for modifying logging later: mayb eiwh __FIULE__ and __LINE =
// $fatal(1, $sformatf("Simulation terminated: [ID: %0d] %s at %m", id, message));
