module uart_wrapper #(
    parameter string        DEVICE              = "7SERIES",
    parameter bit [31:0]    BASE_OFFSET         = 32'h00000000,
    parameter bit [31:0]    BASE_OFFSET_MASK    = 32'h00000000,
    parameter int           RX_ENABLE           = 1,
    parameter int           TX_ENABLE           = 1,
    parameter int           DEBUG_UART_AXI      = 0,
    parameter int           DEBUG_UART_CTRL     = 0
) (
    input       wire    clk,
    input       wire    rst,
    axi4l_if            intf,
    output      wire    irq,
    input       wire    rxd,
    output      wire    txd
);

    uart_top #(
        .DEVICE             (DEVICE),
        .BASE_OFFSET        (BASE_OFFSET),
        .BASE_OFFSET_MASK   (BASE_OFFSET_MASK),
        .RX_ENABLE          (RX_ENABLE),
        .TX_ENABLE          (TX_ENABLE),
        .DEBUG_UART_AXI     (DEBUG_UART_AXI),
        .DEBUG_UART_CTRL    (DEBUG_UART_CTRL)
    )
    uart_top_i0 (
        .clk                (clk), 
        .rst                (rst),
        .axi4l_awaddr       (intf.cb_slave.awaddr),
        .axi4l_awvalid      (intf.cb_slave.awvalid),
        .axi4l_awready      (intf.cb_slave.awready),
        .axi4l_awprot       (intf.cb_slave.awprot),
        .axi4l_wdata        (intf.cb_slave.wdata),
        .axi4l_wstrb        (intf.cb_slave.wstrb),
        .axi4l_wvalid       (intf.cb_slave.wvalid),
        .axi4l_wready       (intf.cb_slave.wready),
        .axi4l_bresp        (intf.cb_slave.bresp),
        .axi4l_bvalid       (intf.cb_slave.bvalid),
        .axi4l_bready       (intf.cb_slave.bready),
        .axi4l_araddr       (intf.cb_slave.araddr),
        .axi4l_arvalid      (intf.cb_slave.arvalid),
        .axi4l_arready      (intf.cb_slave.arready),
        .axi4l_arprot       (intf.cb_slave.arprot),
        .axi4l_rdata        (intf.cb_slave.rdata),
        .axi4l_rresp        (intf.cb_slave.rresp),
        .axi4l_rvalid       (intf.cb_slave.rvalid),
        .axi4l_rready       (intf.cb_slave.rready),
        .irq                (irq), 
        .rxd                (rxd),
        .txd                (txd)
    );

endmodule
