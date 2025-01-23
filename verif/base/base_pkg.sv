package base_pkg;

    import common_pkg::*;

`include "component_base.sv"
class sequence_base extends component_base;
endclass: sequence_base
`include "transaction_base.sv"
`include "sequencer_base.sv"
`include "driver_base.sv"
`include "env_base.sv"
`include "monitor_base.sv"
`include "scoreboard_base.sv"
`include "config_db.sv"

endpackage: base_pkg

