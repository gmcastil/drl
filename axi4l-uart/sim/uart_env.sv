class uart_env #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    // AXI4-lite command and control to DUT
    uart_config cfg;
    axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm;

    // Shared mailbox betwen driver and sequencer
    /* mailbox #(axi4l_transaction#(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) txn_queue; */

    function new(axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm,
                    uart_config cfg);
        this.axi4l_bfm = axi4l_bfm;
        this.cfg = cfg;
        /* this.txn_queue = new(); */
        /* this.driver = new(this.vif, this.txn_queue); */
        /* this.sequencer = new(this.txn_queue); */
    endfunction: new

    /* task automatic run(); */

    /*     axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) txn; */

    /*     // AXI4-Lite driver runs in the background */
    /*     fork */
    /*     begin */
    /*         this.driver.run(); */
    /*     end */
    /*     join_none */

    /*     // Sequencer behavior for now */
    /*     txn = new(READ, 32'h8000003C); */
    /*     for (int i = 0; i < 4; i++) begin */
    /*         txn = new(WRITE8, 32'h8000003C, 32'hff, i); */
    /*         this.txn_queue.put(txn); */
    /*         txn = new(READ, 32'h8000003C); */
    /*         this.txn_queue.put(txn); */
    /*         txn = new(WRITE32, 32'h8000003C, 32'h0); */
    /*         this.txn_queue.put(txn); */
    /*     end */

    /*     for (int i = 0; i < 4; i = i + 2) begin */
    /*         txn = new(WRITE16, 32'h8000003C, 32'h1234, i); */
    /*         this.txn_queue.put(txn); */
    /*         txn = new(READ, 32'h8000003C); */
    /*         this.txn_queue.put(txn); */
    /*         txn = new(WRITE32, 32'h8000003C, 32'h0); */
    /*         this.txn_queue.put(txn); */
    /*     end */
    /*     $display("Wrote a bunch of transactions"); */

    /* endtask: run */

endclass: uart_env

