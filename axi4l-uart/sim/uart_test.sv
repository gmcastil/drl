class uart_test #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);
    uart_env #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) env;

    /* virtual interface axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif; */

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif);
        /* this.vif = vif; */
        this.env = new(vif);
    endfunction: new

    task run();
        this.env.run();
    endtask: run

endclass: uart_test

