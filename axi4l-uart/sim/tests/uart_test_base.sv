class uart_test_base #(
    // Interface parameters not provided to the top level test bench or DUT
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH,
    // Instantiation parameters to the DUT that are provided at compile time
    parameter string        DEVICE,
    parameter bit [31:0]    BASE_OFFSET,
    parameter bit [31:0]    BASE_OFFSET_MASK,
    parameter int           RX_ENABLE,
    parameter int           TX_ENABLE
);
    // All extended base tests send the same signal, but we overload the run method
    // since all tests will run differently.
    event test_done;

    uart_env #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) env;
    uart_config cfg;

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif);
        if (vif == null) begin
            $fatal(0, "Cannot initialize UART test");
        end
        $display("[TEST] Initializing test");

        this.cfg = new();
        this.cfg.device = DEVICE;
        this.cfg.axi_base_addr = {32'h0, BASE_OFFSET};
        this.cfg.axi_base_mask = {32'h0, BASE_OFFSET_MASK};
        this.cfg.rx_enable = bit'(RX_ENABLE);
        this.cfg.tx_enable = bit'(TX_ENABLE);

        this.env = new(vif, this.cfg);
    endfunction: new

    task run();
        $write("Counting to 10...");
        for (int i = 0; i < 10; i++) begin
            $write("%d ", i);
            #100us;
            $fflush;
        end
        $display("");
        $display("[%0t] [TEST] Test completed...temporarily", $time);
        ->test_done;
    endtask: run

endclass: uart_test_base

