class uart_test_base #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);
    // All extended base tests send the same signal, but we overload the run method
    // since all tests will run differently.
    event test_done;

    uart_env #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) env;

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif);
        if (vif == null) begin
            $fatal(0, "Cannot initialize UART test");
        end
        $display("[TEST] Initializing test");
        this.env = new(vif);
    endfunction: new

    virtual task run();
        $fatal(0, "[%0t] [TEST] Base UART test cannot be run directly.", $time);
    endtask: run

    task wait_for_completion();
        @(test_done);
        $display("[%0t] [TEST] Test completed", $time);
    endtask: wait_for_completion

endclass: uart_test_base

