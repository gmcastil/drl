virtual class uart_test_base #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    // All extended base tests send the same signal, but we overload the run method
    // since all tests will run differently.
    event test_done;

    /* uart_env env; */
    uart_config uart_cfg;
    axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm;

    function new(axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm, uart_config_t dut_cfg);
        $display("[TEST] Initializing test");
        this.axi4l_bfm = axi4l_bfm;
        this.uart_cfg = new(dut_cfg);
        /* axi4l_bfm.read(32'h8000000C, data, resp); */
        /* $display("data = %0x, resp = %s", data, resp.name()); */
    endfunction: new

endclass: uart_test_base


    /* function new(axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) bfm, uart_config_t dut_cfg); */

    /*     this.cfg = new(dut_cfg); */

    /*     this.cfg.display(); */
    /*     /1* bfm.display(); *1/ */
    /*     /1* this.env = new(bfm, this.cfg); *1/ */
    /* endfunction: new */

