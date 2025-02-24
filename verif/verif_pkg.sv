package verif_pkg;

`include "logger_macros.svh"

    // Forward declarations --- {{{

    // Sequence objects store references to sequencers and sequencers store queues of sequence
    // objects
    typedef class sequence_base;

    // The configuration database and logger need to be aware of these types of objects
    typedef class component_base;
    typedef class object_base;

    // Indicate log verbosity
    typedef enum {
        LOG_NONE,
        LOG_LOW,
        LOG_MEDIUM,
        LOG_HIGH,
        LOG_DEBUG
    } log_level_t;

    // Indicate log severity
    typedef enum {
        LOG_INFO,
        LOG_WARN,
        LOG_ERROR,
        LOG_FATAL 
    } log_severity_t;

    // }}}

`include "logger.sv"
`include "config_db.sv"

    // Base components
`include "object_base.sv"
`include "component_base.sv"
`include "objection_mgr.sv"
`include "transaction_base.sv"
`include "host_guest_channel.sv"
`include "sequence_base.sv"
`include "driver_base.sv"
`include "monitor_base.sv"
`include "scoreboard_base.sv"
`include "env_base.sv"
`include "test_config_base.sv"
`include "test_case_base.sv"
`include "test_factory.sv"
`include "test_root.sv"

endpackage: verif_pkg
