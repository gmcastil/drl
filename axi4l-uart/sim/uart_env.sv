class uart_env #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    virtual interface axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif;
    axi4l_driver #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) driver;
    axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) txn;

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif);
        this.vif = vif;
        this.driver = new(this.vif);
    endfunction: new

    task automatic run();

        txn = new(READ, 32'h8000003C);
        driver.execute(txn);

        for (int i = 0; i < 4; i++) begin
            txn = new(WRITE8, 32'h8000003C, 32'hff, i);
            this.driver.execute(txn);
            txn.display;
            txn = new(READ, 32'h8000003C);
            this.driver.execute(txn);
            txn.display;
            txn = new(WRITE32, 32'h8000003C, 32'h0);
            this.driver.execute(txn);
        end

        for (int i = 0; i < 4; i = i + 2) begin
            txn = new(WRITE16, 32'h8000003C, 32'h1234, i);
            this.driver.execute(txn);
            txn.display;
            txn = new(READ, 32'h8000003C);
            this.driver.execute(txn);
            txn.display;
            txn = new(WRITE32, 32'h8000003C, 32'h0);
            this.driver.execute(txn);
        end

    endtask: run

endclass: uart_env

