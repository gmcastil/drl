`timescale 1ns / 1ps

module top #(
    parameter string        DEVICE,
    parameter bit [63:0]    BASE_OFFSET,
    parameter bit [63:0]    BASE_OFFSET_MASK,
    parameter int           RX_ENABLE,
    parameter int           TX_ENABLE
);

    // Package imports -- {{{
    /* import uart_tb_pkg::*; */
    /* import uart_tests_pkg::*; */
    import common_pkg::*;
    import base_pkg::*;
    import axi4l_pkg::*;
    // }}}

    // Parameters -- {{{

    // Required for the the UART AXI4-Lite interface instance
    parameter UART_AXI_ADDR_WIDTH = 32;
    parameter UART_AXI_DATA_WIDTH = 32;

    // Indicate how long to assert the POR on each domain
    parameter RST_ASSERT_CNT = 10;
    // }}}

    // Signals, variables, events-- {{{
    bit clk = 1'b0;
    bit rst = 1'b0;
    bit rstn = 1'b1;

    // Remaining DUT signals that do not go in the interface
    bit irq;
    bit rxd;
    bit txd;

    // Indicates that all external testbench clocks and resets are completed
    event rst_done;

    string test_name;

    // Container for the DUT configuration
    /* uart_config_t dut_cfg; */
    // }}}

    // Class instances -- {{{
    /* uart_test_scratch #(UART_AXI_ADDR_WIDTH, UART_AXI_DATA_WIDTH) test_case; */
    // }}}

    // Interfaces -- {{{
    axi4l_if #(
        .ADDR_WIDTH    (UART_AXI_ADDR_WIDTH),
        .DATA_WIDTH    (UART_AXI_DATA_WIDTH)
    )
    uart_if (
        .aclk           (clk),
        .aresetn        (rstn)
    );
    // }}}

    // DUT instance -- {{{
    uart_wrapper #(
        .DEVICE             (DEVICE),
        .BASE_OFFSET        (BASE_OFFSET),
        .BASE_OFFSET_MASK   (BASE_OFFSET_MASK),
        .RX_ENABLE          (RX_ENABLE),
        .TX_ENABLE          (TX_ENABLE),
        .DEBUG_UART_AXI     (0),
        .DEBUG_UART_CTRL    (0)
    )
    uart_wrapper_i0 (
        .clk            (clk),
        .rst            (rst),
        .intf           (uart_if),
        .irq            (irq),
        .rxd            (rxd),
        .txd            (txd)
    );
    // }}}

    // Clock and resets -- {{{
    initial begin
        forever begin
            #(10/2);
            clk = ~clk;
        end
    end

    initial begin
        repeat (RST_ASSERT_CNT) @(posedge clk);
        rst = 1'b1;
        rstn = 1'b0;
        repeat (RST_ASSERT_CNT) @(posedge clk);
        rst = 1'b0;
        rstn = 1'b1;
        ->rst_done;
    end
    // }}}

    // Simulation main body -- {{{
    initial begin
        // This lets us grab the extended BFM that is embedded in the
        // interface which serves as a kind of container
        axi4l_bfm_base #(UART_AXI_ADDR_WIDTH, UART_AXI_DATA_WIDTH) axi4l_bfm;
        axi4l_bfm = uart_if.bfm;

/*
        // DUT configuration
        dut_cfg = '{
            device: DEVICE,
            rx_enable: bit'(RX_ENABLE),
            tx_enable: bit'(TX_ENABLE),
            axi_base_addr: BASE_OFFSET,
            axi_base_mask: BASE_OFFSET_MASK,
            axi_addr_width: UART_AXI_ADDR_WIDTH,
            axi_data_width: UART_AXI_DATA_WIDTH
        };

        @(rst_done);

        test_case = new(axi4l_bfm, dut_cfg);
        fork
            test_case.run();
        join_none

        @(test_case.test_done);
        */
        @(rst_done);
        $finish;
    end
    // }}}

endmodule: top

