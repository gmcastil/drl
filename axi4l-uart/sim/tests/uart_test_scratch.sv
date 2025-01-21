class uart_test_scratch #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
) extends uart_test_base #(
    AXI_ADDR_WIDTH,
    AXI_DATA_WIDTH
);

    function new(axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm, uart_config_t dut_cfg);
        super.new(axi4l_bfm, dut_cfg);
    endfunction: new

    task automatic run();
        uart_scratch_seq #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) seq;

        this.env.initialize();
        wait(this.env.state == INITIALIZED);
        /* if (this.env == null) begin */
        /*     $fatal(0, "Error: Test environment not created"); */
        /* end else begin */
        /*     $display("[%0t] [TEST] Test started", $time); */
        /*     fork begin */
        /*         this.env.run(); */
        /*     end join_none */
        /* end */
        /* seq = new(this.env.sequencer); */
        /* seq.run(); */

        #1us;
        ->test_done;
    endtask: run

endclass

        /* $write("Counting to 10..."); */
        /* for (int i = 0; i < 10; i++) begin */
        /*     $write("%d ", i); */
        /*     #100us; */
        /*     $fflush; */
        /* end */
        /* $display(""); */

        /* // Sequencer behavior for now */
        /* txn = new(READ, 32'h8000003C); */
        /* for (int i = 0; i < 4; i++) begin */
        /*     txn = new(WRITE8, 32'h8000003C, 32'hff, i); */
        /*     this.txn_queue.put(txn); */
        /*     txn = new(READ, 32'h8000003C); */
        /*     this.txn_queue.put(txn); */
        /*     txn = new(WRITE32, 32'h8000003C, 32'h0); */
        /*     this.txn_queue.put(txn); */
        /* end */

        /* for (int i = 0; i < 4; i = i + 2) begin */
        /*     txn = new(WRITE16, 32'h8000003C, 32'h1234, i); */
        /*     this.txn_queue.put(txn); */
        /*     txn = new(READ, 32'h8000003C); */
        /*     this.txn_queue.put(txn); */
        /*     txn = new(WRITE32, 32'h8000003C, 32'h0); */
        /*     this.txn_queue.put(txn); */
        /* end */
