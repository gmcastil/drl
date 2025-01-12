module uart_env #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    axi4l_driver #(

    function new();

    endfunction: new

endmodule: uart_env

/* class uart_env #( */
/*     AXI_ADDR_WIDTH, */
/*     AXI_DATA_WIDTH */
/* ); */

/*     virtual interface axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif; */

/*     function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif); */
/*         this.vif = vif; */
/*     endfunction: new */

/*     task automatic run; */
/*         $display("AXI_ADDR_WIDTH = %d", AXI_ADDR_WIDTH); */
/*         $display("AXI_DATA_WIDTH = %d", AXI_DATA_WIDTH); */
/*     endtask: run */

/*     task automatic my_read(logic [AXI_ADDR_WIDTH-1:0] rd_addr); */
/*         logic [AXI_DATA_WIDTH-1:0] rd_data; */
/*         axi4l_resp_t rd_resp; */

/*         rd_addr = 32'h80000000 + rd_addr; */
/*         this.vif.read(rd_addr, rd_data, rd_resp); */
/*         $display("read addr = %h", rd_addr); */
/*         $display("read data = %h", rd_data); */
/*         $display("read resp = %s", rd_resp.name()); */
/*     endtask: my_read */

/*     task automatic my_write(logic [AXI_ADDR_WIDTH-1:0] wr_addr, logic [AXI_DATA_WIDTH-1:0] wr_data); */
/*         axi4l_resp_t wr_resp; */

/*         wr_addr = 32'h80000000 + wr_addr; */
/*         this.vif.write(wr_addr, wr_data, 4'hf, wr_resp); */
/*         $display("write addr = %h", wr_addr); */
/*         $display("write data = %h", wr_data); */
/*         $display("write resp = %s", wr_resp.name()); */
/*     endtask: my_write */

/* endclass: uart_env */

