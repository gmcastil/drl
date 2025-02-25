`ifndef VERIF_GLOBALS_SVH
`define VERIF_GLOBALS_SVH

// Convenience macro for returning the default log level, usually during object instantiation
`define get_default_log_level() \
    logger::get_instance().get_default_log_level()

// Note that the log_fatal and report_fatal functions exit the simulation with a stacktrace if
// possible.
`define log_fatal(msg) \
    logger::get_instance().log(LOG_FATAL, LOG_NONE, msg, this, `__FILE__, `__LINE__); \
`ifndef NO_STACKTRACE_SUPPORT \
    $stacktrace; \
`endif \
    $fflush(); \
    $fatal(1)

`define log_fatal_with_context(msg, cntxt) \
    logger::get_instance().log(LOG_FATAL, LOG_NONE, msg, cntxt, `__FILE__, `__LINE__); \
`ifndef NO_STACKTRACE_SUPPORT \
    $stacktrace; \
`endif \
    $fflush(); \
    $fatal(1)

`define report_fatal(name, msg) \
    logger::get_instance().report(LOG_FATAL, LOG_NONE, msg, name, `__FILE__, `__LINE__); \
`ifndef NO_STACKTRACE_SUPPORT \
    $stacktrace; \
`endif \
    $fflush(); \
    $fatal(1);

// Convenience macros for logging from instance-based functions of objects derived from object_base.
// These are intended to be used by all clients of the logger singleton, both inside and outside
// the verification framework.
`define log_error(msg) \
    logger::get_instance().log(LOG_ERROR, LOG_NONE, msg, this, `__FILE__, `__LINE__)

`define log_error_with_context(cntxt, msg) \
    logger::get_instance().log(LOG_ERROR, LOG_NONE, msg, cntxt, `__FILE__, `__LINE__)

`define log_warn(msg) \
    logger::get_instance().log(LOG_WARN, LOG_NONE, msg, this, `__FILE__, `__LINE__)

`define log_warn_with_context(cntxt, msg) \
    logger::get_instance().log(LOG_WARN, LOG_NONE, msg, cntxt, `__FILE__, `__LINE__)

`define log_info(msg, verbosity) \
    if (verbosity <= this.get_log_level()) logger::get_instance().log(LOG_INFO, verbosity, msg, this, `__FILE__, `__LINE__)

`define log_info_with_context(cntxt, msg, verbosity) \
    if (verbosity <= cntxt.get_log_level()) logger::get_instance().log(LOG_INFO, verbosity, msg, cntxt, `__FILE__, `__LINE__)

`define log_debug(msg) \
    if (LOG_DEBUG <= this.get_log_level()) logger::get_instance().log(LOG_INFO, LOG_DEBUG, msg, this, `__FILE__, `__LINE__)

`define log_debug_with_context(cntxt, msg) \
    if (LOG_DEBUG <= this.get_log_level()) logger::get_instance().log(LOG_INFO, LOG_DEBUG, msg, cntxt, `__FILE__, `__LINE__)

//  Convenience macros for logging from static functions - for now, no verbosity tracking per static
//  callers is performed.
`define report_error(name, msg) \
    if (verbosity <= logger::get_instance().get_default_log_level()) \
        logger::get_instance().report(LOG_WARN, LOG_NONE, msg, name, `__FILE__, `__LINE__)

`define report_warn(name, msg) \
    if (verbosity <= logger::get_instance().get_default_log_level()) \
        logger::get_instance().report(LOG_WARN, LOG_NONE, msg, name, `__FILE__, `__LINE__)

`define report_info(name, msg, verbosity) \
    if (verbosity <= logger::get_instance().get_default_log_level()) \
        logger::get_instance().report(LOG_INFO, verbosity, msg, name, `__FILE__, `__LINE__)

`define report_debug(name, msg) \
    if (LOG_DEBUG <= logger::get_instance().get_default_log_level()) \
        logger::get_instance().report(LOG_INFO, LOG_DEBUG, msg, name, `__FILE__, `__LINE__)

`endif  // VERIF_LOGGING_SVH

