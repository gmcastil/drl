class uart_scratch_seq #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) txn;
    uart_sequencer #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) sequencer;

    function new(uart_sequencer #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) sequencer);
        this.sequencer = sequencer;
    endfunction: new

    task run();
        logic [AXI_DATA_WIDTH-1:0] value = 32'hdeadbeef;
        $display("Running scratch sequence");
        txn = new(WRITE32, 32'h8000003C, value);
        this.sequencer.put(txn);
        txn.display();

        txn = new(READ, 32'h8000003C);
        this.sequencer.put(txn);
        txn.display();

    endtask: run

endclass: uart_scratch_seq

