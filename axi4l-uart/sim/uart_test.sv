class uart_test #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);
    // Primary signaling that test is complete 
    event done;

    uart_env #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) env;
    /* virtual interface axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif; */

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif);
        if (vif == null) begin
            $fatal(0, "Cannot initialize UART test");
        end
        $display("[TEST] Initializing test");
        this.env = new(vif);
    endfunction: new

    task run();
        $display("[TEST] Running test");
        $fflush;
        this.env.run();
        // Crude way to wait for test case being finished
        wait(this.env.driver.txn_queue.num() == 0);
        ->done;
    endtask: run

endclass: uart_test

