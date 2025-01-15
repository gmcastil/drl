class uart_env #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    // AXI4-lite command and control to DUT
    virtual interface axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif;
    axi4l_driver #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) driver;
    uart_sequencer #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) sequencer;
    uart_config cfg;
    
    // Shared mailbox betwen driver and sequencer
    mailbox #(axi4l_transaction#(AXI_ADDR_WIDTH, AXI_DATA_WIDTH)) txn_queue;

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif,
                    uart_config cfg);
        if (vif == null) begin
            $fatal(0, "Cannot initialize UART environment");
        end
        this.vif = vif;
        this.cfg = cfg;
        $display("[ENV] Environment instantiated with virtual interface");
        $display("[ENV]   ADDR_WIDTH = %0d", vif.ADDR_WIDTH);
        $display("[ENV]   DATA_WIDTH = %0d", vif.DATA_WIDTH);
        $fflush;
        this.txn_queue = new();
        this.driver = new(this.vif, this.txn_queue);
        this.sequencer = new(this.txn_queue);
    endfunction: new

    task automatic run();

        axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) txn;

        // AXI4-Lite driver runs in the background
        fork
        begin
            this.driver.run();
        end
        join_none

        // Sequencer behavior for now
        txn = new(READ, 32'h8000003C);
        for (int i = 0; i < 4; i++) begin
            txn = new(WRITE8, 32'h8000003C, 32'hff, i);
            this.txn_queue.put(txn);
            txn = new(READ, 32'h8000003C);
            this.txn_queue.put(txn);
            txn = new(WRITE32, 32'h8000003C, 32'h0);
            this.txn_queue.put(txn);
        end

        for (int i = 0; i < 4; i = i + 2) begin
            txn = new(WRITE16, 32'h8000003C, 32'h1234, i);
            this.txn_queue.put(txn);
            txn = new(READ, 32'h8000003C);
            this.txn_queue.put(txn);
            txn = new(WRITE32, 32'h8000003C, 32'h0);
            this.txn_queue.put(txn);
        end
        $display("Wrote a bunch of transactions");

    endtask: run

endclass: uart_env

