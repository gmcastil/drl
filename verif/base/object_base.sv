class object_base;

    string name;

    log_level_t current_log_level = default_log_level;

    function new(string name);
        this.name = name;
    endfunction: new

    function string get_name();
        return this.name;
    endfunction: get_name

    function void set_log_level(log_level_t level);
        this.current_log_level = level;
    endfunction: set_log_level

    function log_level_t get_log_level();
        return this.current_log_level;
    endfunction: get_log_level

    // Define a generic logging method - the intent is that each class would define its
    // own version of this and then call the base class
    function void log(log_level_t level, string name, string msg, string id = "");
        logger::log(level, name, msg, id);
    endfunction: log

    // Logs a fatal message with optional ID and then exits the simulation at that point
    function void log_fatal(string name, string msg, string id = "");
        logger::log(LOG_FATAL, name, msg, id);
        // The $stacktrace task (can also be called as a function) was only added to the language in
        // 2023 but has been implemented by Questa since at least 2013. To try to maintain some sort of
        // compatibility, this can be turned off at runtime if needed
`ifndef NO_STACKTRACE_SUPPORT
        $stacktrace;
`endif
        $fflush();
        $fatal(1);
    endfunction: log_fatal

endclass: object_base

