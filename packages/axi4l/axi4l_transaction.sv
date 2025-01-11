class axi4l_transaction #(
    parameter int   AXI_ADDR_WIDTH,
    parameter int   AXI_DATA_WIDTH
);

    axi4l_txn_t kind;
    logic [AXI_DATA_WIDTH-1:0] data;
    logic [AXI_ADDR_WIDTH-1:0] addr;
    int position;
    axi4l_resp_t resp;

    function automatic new(axi4l_txn_t kind, logic [AXI_ADDR_WIDTH-1:0] addr,
                            logic [AXI_DATA_WIDTH-1:0] data, int position);
        this.kind = kind;
        this.addr = addr;
        if (this.kind != READ) begin
            this.position = position;
            this.data = data;
        end
    endfunction: new

    function automatic void display;
        if (this.kind != READ) begin
            $display("Type: %5s Addr: 0x%08x Data: 0x%08x Resp: %s Position: %0d",
                        kind.name(), this.addr, this.data, this.resp.name(), this.position);
        end else begin
            $display("Type: %5s Addr: 0x%08x Data: 0x%08x Resp: %s",
                        kind.name(), this.addr, this.data, this.resp.name());
        end
    endfunction: display

endclass: axi4l_transaction

