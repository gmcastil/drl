package uart_tb_pkg;

    import common_pkg::*;
    import base_pkg::*;
    import axi4l_pkg::*;

    typedef struct {
        string device;
        bit rx_enable;
        bit tx_enable;
        int unsigned axi_base_addr;
        int unsigned axi_base_mask;
        int unsigned axi_addr_width;
        int unsigned axi_data_width;
    } uart_config_t;

/* `include "uart_config.sv" */
/* `include "uart_sequencer.sv" */
/* `include "uart_scratch_seq.sv" */
`include "uart_env.sv"

endpackage: uart_tb_pkg

