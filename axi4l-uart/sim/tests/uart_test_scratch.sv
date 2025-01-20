class uart_test_scratch #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
) extends uart_test_base #(
    AXI_ADDR_WIDTH,
    AXI_DATA_WIDTH
);

    function new(axi4l_bfm_base #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) axi4l_bfm, uart_config_t dut_cfg);
        super.new(axi4l_bfm, dut_cfg);
    endfunction: new

    task automatic run();
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

endclass

