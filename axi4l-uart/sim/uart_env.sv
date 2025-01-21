class uart_env #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    uart_config cfg;
    axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm;
    axi4l_driver #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) driver;
    uart_sequencer #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) sequencer;

    // Shared mailbox betwen driver and sequencer
    mailbox #(axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) txn_queue;

    function new(axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm,
                    uart_config cfg);
        this.axi4l_bfm = axi4l_bfm;
        this.cfg = cfg;
        this.txn_queue = new();
        this.driver = new(this.axi4l_bfm, this.txn_queue);
        this.sequencer = new(this.txn_queue);
    endfunction: new

    task automatic run();
        // AXI4-Lite driver runs in the background, pulling transactions out
        // of the shared communciation channel, placed there by the sequencer.
        fork begin
            this.driver.run();
        end join_none

    endtask: run

endclass: uart_env

