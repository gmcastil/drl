// X Report mechanism for static classes to use
// Create report macros for static classes and put them in the globasl
// Refactor logger to use report machinery
// Factories use report system
// Fix all the stuff that i was trying to shoehorn into object_base
// For static callers, use the report system, creaet a registration system, and then compare against
// the stored value and if not found, just compare against the static log level=
// Get it all to build 
class logger;

    static logger single_instance;
    bit initialized = 0;

    string name;

    log_level_t default_log_level = LOG_MEDIUM;

    static const string log_severity_map [log_severity_t] = '{
        LOG_INFO        : "INFO",
        LOG_WARN        : "WARNING",
        LOG_ERROR       : "ERROR",
        LOG_FATAL       : "FATAL" 
    };

    function new();
    endfunction: new

    static function logger get_instance();
        if (single_instance == null) begin
            single_instance = new();
            // Ensures that initialization happens only once
            single_instance.initialize();
        end
        return single_instance;
    endfunction: get_instance

    function void initialize();
        string verbosity;

        string log_msg;

        if (this.initialized) begin
            return;
        end

        // The logger singleton needs a name
        this.name = "logger";

        // Set the default logging level based on plusargs
        if ($value$plusargs("LOG_VERBOSITY=%s", verbosity)) begin
            case (verbosity)
                "NONE":     this.default_log_level = LOG_NONE;
                "LOW":      this.default_log_level = LOG_LOW;
                "MEDIUM":   this.default_log_level = LOG_MEDIUM;
                "HIGH":     this.default_log_level = LOG_HIGH;
                "DEBUG":    this.default_log_level = LOG_DEBUG;
                default:    this.default_log_level = LOG_DEBUG;
            endcase
        end
        $fflush();

        // Prevents initialiation from running more than once
        this.initialized = 1;

        // Now static objects (like ourselves can actually start using the logger
        log_msg = $sformatf("Logger initialized with default log level %s",
                                this.get_default_log_level());
        `report_info(this.name, log_msg, LOG_LOW);

    endfunction: initialize

    // Calls to the logging method need to include an object reference, the severity, the message,
    // and the verbosity level of the message.  The logger::log() will use the the object_base::
    // get_log_level() method to determine whether to actually log the message.  If the object
    // reference is null, then the default log level will be used.
    function void log(log_severity_t severity, log_level_t verbosity, string msg, object_base obj, string filename, int line_number);

        string msg_fmt;
        string log_msg;
        string file_line_info;

        // Null objects cannot participate in logging
        if (obj == null) begin
			`report_fatal(this.name, "Null object passed to the logger");
        end

		// We only look at verbosity for info and debug severity and if the current log level is set to LOG_NONE
		// then we treat it like a suppression statement.
        if (severity >= LOG_WARN ||
				(verbosity <= obj.get_log_level() && obj.get_log_level() != LOG_NONE)) begin
            file_line_info = "";
            if (severity == LOG_ERROR || severity == LOG_FATAL) begin
                // Note the last space in the string
                file_line_info = $sformatf("%s(%0d) ", filename, line_number);
            end
            msg_fmt = "%s %s@ %0t: %s [%s] %s";
            log_msg = $sformatf(msg_fmt, log_severity_map[severity], file_line_info, $time,
                                    obj.get_name(), obj.get_full_name(), msg);
			// Actual log message that gets generated to the console
            $display(log_msg);
        end

    endfunction: log

    function void report(log_severity_t severity, log_level_t verbosity, string msg, string name, string filename, int line_number);

        string msg_fmt;
        string report_msg;
        string file_line_info;

		// Empty names are not expected to be a thing
        if (name == "") begin
			`report_error(this.name, "Attempt to pass empty static name to logger");
            return;
        end

		// We only look at verbosity for info and debug severity and if the current log level is set to LOG_NONE
		// then we treat it like a suppression statement.
        if (severity >= LOG_WARN ||
				(verbosity <= this.get_default_log_level() && this.get_default_log_level() != LOG_NONE)) begin
			file_line_info = "";
            if (severity == LOG_ERROR || severity == LOG_FATAL) begin
                // Note the last space in the string
                file_line_info = $sformatf("%s(%0d) ", filename, line_number);
            end
            msg_fmt = "%s %s@ %0t: %s [%s] %s";
            report_msg = $sformatf(msg_fmt, log_severity_map[severity], file_line_info, $time,
                                    name, "global", msg);
			// Actual report message that gets sent to the console
            $display(report_msg);
        end
    endfunction: report

    // Returns the default log level used for all new objects
    function log_level_t get_default_log_level();
        return this.default_log_level;
    endfunction

endclass: logger

