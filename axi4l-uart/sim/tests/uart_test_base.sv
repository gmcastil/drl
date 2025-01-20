virtual class uart_test_base #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    // All extended base tests send the same signal, but we overload the run method
    // since all tests will run differently.
    event test_done;

    uart_env #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) env;
    uart_config cfg;

    function new(axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm, uart_config_t dut_cfg);
        $display("[TEST] Initializing test");
        this.cfg = new(dut_cfg);
        this.env = new(axi4l_bfm, this.cfg);
    endfunction: new

endclass: uart_test_base

