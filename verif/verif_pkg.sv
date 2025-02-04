package verif_pkg;

    // Forward declarations --- {{{

    // Sequence objects store references to sequencers and sequencers store queues of sequence
    // objects
    typedef class sequence_base;
    typedef class sequencer_base;
    // }}}

    // Static classes, typedefs, global values, macros
`include "logger.sv"
`include "macros.svh"

    // Base components
`include "object_base.sv"
`include "component_base.sv"
`include "config_db.sv"
`include "transaction_base.sv"
`include "host_guest_channel.sv"
`include "sequencer_base.sv"
`include "sequence_base.sv"
`include "driver_base.sv"
`include "monitor_base.sv"
`include "scoreboard_base.sv"
`include "env_base.sv"
`include "test_base.sv"

endpackage: verif_pkg
