class axi4l_driver #(
    parameter int   AXI_ADDR_WIDTH,
    parameter int   AXI_DATA_WIDTH
);

    virtual interface axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif;

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif);
        this.vif = vif;
        return;
    endfunction: new

    task automatic execute(axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) txn);

        if (txn.kind == READ) begin
            this.vif.read(txn.addr, txn.data, txn.resp);
        end else if (txn.kind == WRITE) begin
            //
        end else begin
            $fatal("Unsupported operation type: %d", txn.kind);
        end

    endtask: execute

    function automatic void display;
        $display("AXI_ADDR_WIDTH = %d", AXI_ADDR_WIDTH);
        $display("AXI_DATA_WIDTH = %d", AXI_DATA_WIDTH);
        return;
    endfunction: display

endclass: axi4l_driver
