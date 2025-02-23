`define log_fatal(msg) \
    logger::get_instance().log(LOG_FATAL, LOG_NONE, msg, this, `__FILE__, `__LINE__)

`define log_fatal_with_context(cntxt, msg) \
    logger::get_instance().log(LOG_FATAL, LOG_NONE, msg, cntxt, `__FILE__, `__LINE__)

`define log_error(msg) \
    logger::get_instance().log(LOG_ERROR, LOG_NONE, msg, this, `__FILE__, `__LINE__)

`define log_error_with_context(cntxt, msg) \
    logger::get_instance().log(LOG_ERROR, LOG_NONE, msg, cntxt, `__FILE__, `__LINE__)

`define log_warn(msg) \
    logger::get_instance().log(LOG_WARN, LOG_NONE, msg, this, `__FILE__, `__LINE__)

`define log_warn_with_context(cntxt, msg) \
    logger::get_instance().log(LOG_WARN, LOG_NONE, msg, cntxt, `__FILE__, `__LINE__)

`define log_info(msg, verbosity) \
    if (this.get_log_level() >= verbosity) logger::get_instance().log(LOG_INFO, verbosity, msg, this, `__FILE__, `__LINE__)

`define log_info_with_context(cntxt, msg, verbosity) \
    if (cntxt.get_log_level() >= verbosity) logger::get_instance().log(LOG_INFO, verbosity, msg, cntxt, `__FILE__, `__LINE__)

typedef object_base;

// Indicate log verbosity
typedef enum {
    LOG_NONE,
    LOG_LOW,
    LOG_MEDIUM,
    LOG_HIGH,
    LOG_DEBUG,
    LOG_TRACE
} log_level_t;

// Indicate log severity
typedef enum {
    LOG_INFO,
    LOG_WARN,
    LOG_ERROR,
    LOG_FATAL 
} log_severity_t;

class logger;

    static logger single_instance;
    static bit initialized = 0;

    static log_level_t default_log_level = LOG_MEDIUM;

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
            initialize();
        end
        return single_instance;
    endfunction: get_instance

    // This should be called early on in the testbench so that any logger plusargs can be applied
    static function void initialize();
        string verbosity;

        string msg_fmt;
        string log_msg;

        if (initialized) begin
            return;
        end

        if ($value$plusargs("LOG_VERBOSITY=%s", verbosity)) begin
            case (verbosity)
                "NONE":     default_log_level = LOG_NONE;
                "LOW":      default_log_level = LOG_LOW;
                "MEDIUM":   default_log_level = LOG_MEDIUM;
                "HIGH":     default_log_level = LOG_HIGH;
                default:    default_log_level = LOG_MEDIUM;
            endcase
        end
        msg_fmt = "%s @ %0t: %s";
        $display(msg_fmt, log_severity_map[LOG_INFO], $time, "Initializing logger");
        $fflush();

        // Prevents initialiation from running more than once
        initialized = 1;

    endfunction: initialize

    // Calls to the logging method need to include an object reference, the severity, the message,
    // and the verbosity level of the message.  The logger::log() will use the the object_base::
    // get_log_level() method to determine whether to actually log the message.  If the object
    // reference is null, then the default log level will be used.
    function void log(log_severity_t severity, log_level_t verbosity, string msg, object_base obj, string filename, int line_number);

        string msg_fmt;
        string log_msg;
        automatic string file_line_info;

        // Null objects cannot participate in logging
        if (obj == null) begin
            msg_fmt = "%s @ %0t: %s";
            $display(msg_fmt, log_severity_map[LOG_FATAL], $time, "Null object passed to logger::log()");
            $fatal(1);
        end

        // Always log warning or above and log info when the log message verbosity is at or below the
        // threshold set for the caller
        if (severity >= LOG_WARN || (verbosity <= obj.get_log_level() && verbosity != LOG_NONE)) begin
            file_line_info = "";
            if (severity == LOG_ERROR || severity == LOG_FATAL) begin
                // Note the last space in the string
                file_line_info = $sformatf("%s(%0d) ", filename, line_number);
            end
            msg_fmt = "%s %s@ %0t: %s [%s] %s";
            log_msg = $sformatf(msg_fmt, log_severity_map[severity], file_line_info, $time,
                                    obj.get_name(), obj.get_full_name(), msg);
            $display(log_msg);
        end

    endfunction: log

    // Returns the default log level used for all new objects
    function log_level_t get_default_log_level();
        return this.default_log_level;
    endfunction

endclass: logger

// --- {{{

class object_base;

    string name = name;
    log_level_t current_log_level;

    function new(string name);
        this.name  = name;
        this.current_log_level = logger::get_instance().get_default_log_level();
    endfunction

    function string get_name();
        return this.name;
    endfunction

    function string get_full_name();
        return this.name;
    endfunction

    function log_level_t get_log_level();
        return this.current_log_level;
    endfunction

    function void set_log_level(log_level_t level);
        this.current_log_level = level;
        return;
    endfunction

endclass: object_base

// }}}

class test_object extends object_base;

    string name;

    function new(string name);
        super.new(name);
    endfunction: new

    // This is where you actually experimennt with things.
    function void test_logging();

        `log_info("this is a message of medium importance", LOG_MEDIUM);
        `log_info_with_context(this, "this is a message of medium importance", LOG_MEDIUM);

        `log_info("this is a message of low importance", LOG_LOW);
        `log_info_with_context(this, "this is a message of low importance", LOG_LOW);

        `log_info("this is a message of high importance", LOG_HIGH);
        `log_info_with_context(this, "this is a message of high importance", LOG_HIGH);

        `log_error("this is an error");

    endfunction

endclass: test_object

module tb;


    initial begin

        test_object obj;

        $display("file = %s, line = %0d", `__FILE__, `__LINE__);

        obj = new("test_object");
        $display("Testing with default (medium)");
        obj.test_logging();

        $display("Testing with low");
        obj.set_log_level(LOG_LOW);
        obj.test_logging();

        $display("Testing with high");
        obj.set_log_level(LOG_HIGH);
        obj.test_logging();

        $display("Testing with none");
        obj.set_log_level(LOG_NONE);
        obj.test_logging();

        logger::get_instance().log(LOG_INFO, LOG_NONE, "Thi sis null", null, `__FILE__, `__LINE__);

    end

endmodule

