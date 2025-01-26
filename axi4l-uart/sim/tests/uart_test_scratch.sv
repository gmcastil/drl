class uart_test_base #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
) extends test_base;

    function new();
        log(LOG_DEBUG, $sformatf("ADDR_WIDTH = %d", AXI_ADDR_WIDTH));
        log(LOG_DEBUG, $sformatf("DATA_WIDTH = %d", AXI_DATA_WIDTH));
    endfunction: new

endclass: uart_test_base

