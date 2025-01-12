import axi4l_pkg::*;

class uart_env #(
    parameter int AXI_ADDR_WIDTH,
    parameter int AXI_DATA_WIDTH
);

    virtual interface axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif;
    axi4l_driver #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) driver;

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif);
        this.vif = vif;
        this.driver = new(vif.MASTER);
        this.driver.display;
    endfunction: new

    function run();
        $display("AXI_ADDR_WIDTH = %d", AXI_ADDR_WIDTH);
        $display("AXI_DATA_WIDTH = %d", AXI_DATA_WIDTH);
    endfunction: run

endclass: uart_env

        /* txn = new(READ, 32'h8000003C); */
        /* driver.execute(txn); */

        /* for (int i = 0; i < 4; i++) begin */
        /*     txn = new(WRITE8, 32'h8000003C, 32'hff, i); */
        /*     driver.execute(txn); */
        /*     txn.display; */
        /*     txn = new(READ, 32'h8000003C); */
        /*     driver.execute(txn); */
        /*     txn.display; */
        /*     txn = new(WRITE32, 32'h8000003C, 32'h0); */
        /*     driver.execute(txn); */
        /* end */

        /* for (int i = 0; i < 4; i = i + 2) begin */
        /*     txn = new(WRITE16, 32'h8000003C, 32'h1234, i); */
        /*     driver.execute(txn); */
        /*     txn.display; */
        /*     txn = new(READ, 32'h8000003C); */
        /*     driver.execute(txn); */
        /*     txn.display; */
        /*     txn = new(WRITE32, 32'h8000003C, 32'h0); */
        /*     driver.execute(txn); */
        /* end */
