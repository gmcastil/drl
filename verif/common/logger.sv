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

    static string name = "logger";

    static function void init();
        // TODO These should be numbers, not strings
        string runtime_level_str;
        log_level_t runtime_log_level;

        // Get the runtime log level from outside the test case
        if ($value$plusargs("LOG_LEVEL=%s", runtime_level_str)) begin
            case (runtime_level_str)
                "FATAL": begin runtime_log_level = LOG_FATAL;  end
                "ERROR": begin runtime_log_level = LOG_ERROR;  end
                "WARN":  begin runtime_log_level = LOG_WARN;   end
                "INFO":  begin runtime_log_level = LOG_INFO;   end
                "DEBUG": begin runtime_log_level = LOG_DEBUG;  end
                default: begin
                    // Exit out if an invalid log level was provided - sims might take a long time
                    log(LOG_FATAL, name, $sformatf("Unknown logging level provided: %s", runtime_level_str), "");
                end
            endcase
        end

        // Set the logging level for all components
        logger::set_default_log_level(runtime_log_level);

    endfunction: init

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
