`timescale 1ns / 1ps

import axi4l_pkg::*;

class uart_env #(
    AXI_ADDR_WIDTH,
    AXI_DATA_WIDTH
);

    virtual interface axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif;

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif);
        this.vif = vif;
    endfunction: new

    task automatic run;
        $display("AXI_ADDR_WIDTH = %d", AXI_ADDR_WIDTH);
        $display("AXI_DATA_WIDTH = %d", AXI_DATA_WIDTH);
    endtask: run

    task automatic my_read;
        logic [AXI_ADDR_WIDTH-1:0] rd_addr;
        logic [AXI_DATA_WIDTH-1:0] rd_data;
        axi4l_resp_t rd_resp;

        rd_addr = 32'h80000000;
        this.vif.read(rd_addr, rd_data, rd_resp);
        $display("read data = %h", rd_data);
        $display("read resp = %s", rd_resp.name());
    endtask: my_read

endclass: uart_env

module top;

    // Parameters -- {{{
    //
    // Required for the the UART AXI4-Lite interface instance
    parameter UART_AXI_ADDR_WIDTH = 32;
    parameter UART_AXI_DATA_WIDTH = 32;
    // Indicate how long to assert the POR on each domain
    parameter RST_ASSERT_CNT = 10;
    // }}}

    // Signals -- {{{
    bit clk = 1'b0;
    bit rst = 1'b0;
    bit rstn = 1'b1;
    bit irq;
    bit rxd;
    bit txd;
    // }}}

    // Interfaces -- {{{
    axi4l_if #(
        .ADDR_WIDTH    (32),
        .DATA_WIDTH    (32)
    )
    uart_if (
        .aclk           (clk),
        .aresetn        (rstn)
    );
    // }}}

    // Class instances -- {{{
    uart_env #(UART_AXI_ADDR_WIDTH, UART_AXI_DATA_WIDTH) tb;
    // }}}
    
    // DUT instance -- {{{
    uart_top #(
        .DEVICE             ("7SERIES")
    )
    uart_top_i0 (
        .clk                (clk), 
        .rst                (rst),
        .axi4l_awaddr       (uart_if.awaddr),
        .axi4l_awvalid      (uart_if.awvalid),
        .axi4l_awready      (uart_if.awready),
        .axi4l_awprot       (uart_if.awprot),
        .axi4l_wdata        (uart_if.wdata),
        .axi4l_wstrb        (uart_if.wstrb),
        .axi4l_wvalid       (uart_if.wvalid),
        .axi4l_wready       (uart_if.wready),
        .axi4l_bresp        (uart_if.bresp),
        .axi4l_bvalid       (uart_if.bvalid),
        .axi4l_bready       (uart_if.bready),
        .axi4l_araddr       (uart_if.araddr),
        .axi4l_arvalid      (uart_if.arvalid),
        .axi4l_arready      (uart_if.arready),
        .axi4l_arprot       (uart_if.arprot),
        .axi4l_rdata        (uart_if.rdata),
        .axi4l_rresp        (uart_if.rresp),
        .axi4l_rvalid       (uart_if.rvalid),
        .axi4l_rready       (uart_if.rready),
        .irq                (irq), 
        .rxd                (rxd),
        .txd                (txd)
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
    end
    // }}}

    // Simulation main body -- {{{
    initial begin
        tb = new(uart_if.MASTER);
        tb.run;
        tb.my_read;
        $stop;
    end
    // }}}

endmodule: top

