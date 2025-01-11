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

    task automatic my_read(logic [AXI_ADDR_WIDTH-1:0] rd_addr);
        logic [AXI_DATA_WIDTH-1:0] rd_data;
        axi4l_resp_t rd_resp;

        rd_addr = 32'h80000000 + rd_addr;
        this.vif.read(rd_addr, rd_data, rd_resp);
        $display("read addr = %h", rd_addr);
        $display("read data = %h", rd_data);
        $display("read resp = %s", rd_resp.name());
    endtask: my_read

    task automatic my_write(logic [AXI_ADDR_WIDTH-1:0] wr_addr, logic [AXI_DATA_WIDTH-1:0] wr_data);
        axi4l_resp_t wr_resp;

        wr_addr = 32'h80000000 + wr_addr;
        this.vif.write(wr_addr, wr_data, 4'hf, wr_resp);
        $display("write addr = %h", wr_addr);
        $display("write data = %h", wr_data);
        $display("write resp = %s", wr_resp.name());
    endtask: my_write

endclass: uart_env

module top #(
    parameter string        DEVICE,
    parameter bit [31:0]    BASE_OFFSET,
    parameter bit [31:0]    BASE_OFFSET_MASK,
    parameter int           RX_ENABLE,
    parameter int           TX_ENABLE
);

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
        .intf           (uart_if.SLAVE),
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

    event rst_done;

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
        tb = new(uart_if.MASTER);
        tb.run;

        @(rst_done);
        tb.my_read(32'h00);
        tb.my_read(32'h04);
        tb.my_read(32'h08);
        tb.my_read(32'h0C);
        tb.my_read(32'h10);
        tb.my_read(32'h14);
        tb.my_write(32'h3C, 32'hdeadbeef);
        tb.my_read(32'h3C);
        $stop;
    end
    // }}}

endmodule: top

