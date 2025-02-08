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
    function void log(log_level_t level, string msg, string id = "");
        string log_name;

        if (level < this.current_log_level) begin
            return;
        end

        // If derived classes implement hierarchies, log with that, otherwise use the base name
        if ($cast(log_name, this.get_full_hierarchical_name())) begin
            logger::log(level, log_name, msg, id);
        end else begin
            logger::log(level, this.get_name(), msg, id);
        end
    endfunction: log

    function void log_info(string msg, string id = "");
        this.log(LOG_INFO, msg, id);
    endfunction: log_info

    function void log_warn(string msg, string id = "");
        this.log(LOG_WARN, msg, id);
    endfunction: log_warn

    function void log_error(string msg, string id = "");
        this.log(LOG_ERROR, msg, id);
    endfunction: log_error

    // Logs a fatal message with optional ID and then exits the simulation at that point
    function void log_fatal(string msg, string id = "");
        this.log(LOG_FATAL, msg, id);
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

