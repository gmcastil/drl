`ifndef LOGGER_MACROS_SVH
`define LOGGER_MACROS_SVH

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

`endif

