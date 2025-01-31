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


