package base_pkg;

    import common_pkg::*;

    // Forward declarations --- {{{

    // Sequence objects store references to sequencers and sequencers store queues of sequence
    // objects
    typedef class sequence_base;
    typedef class sequencer_base;
    // }}}

`include "logger.sv"
`include "object_base.sv"
`include "component_base.sv"
`include "config_db.sv"
`include "transaction_base.sv"
`include "sequencer_base.sv"
`include "sequence_base.sv"
`include "driver_base.sv"
`include "monitor_base.sv"
`include "scoreboard_base.sv"
`include "env_base.sv"
`include "test_base.sv"

endpackage: base_pkg

