class uart_test_base #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
) extends test_base;

    uart_config_t dut_cfg;
    axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm;

    function new(string name,
        axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm,
        uart_config_t dut_cfg,
        component_base parent = null);

        // Calling test_base constructor
        super.new(name, parent);

        this.axi4l_bfm = axi4l_bfm;
        this.dut_cfg = dut_cfg;
    endfunction: new

endclass: uart_test_base

