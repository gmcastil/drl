class uart_env #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
) extends env_base;

    axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm;
    /* axi4l_driver #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) driver; */

    function new(string name, axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm, component_base parent = null);
        super.new(name, parent);
        this.axi4l_bfm = axi4l_bfm;
    endfunction: new

    task build_phase();
        log(LOG_INFO, "Build phase started");
        this.axi4l_bfm.display();
    endtask: build_phase

endclass: uart_env
