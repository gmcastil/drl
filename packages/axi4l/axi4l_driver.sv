class axi4l_driver #(
    parameter int   AXI_ADDR_WIDTH,
    parameter int   AXI_DATA_WIDTH
);

    virtual interface axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif;

    function new(virtual axi4l_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) vif);
        this.vif = vif;
    endfunction: new

    task automatic execute(axi4l_transaction #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) txn);

        logic [7:0] byte_enable;
        logic [AXI_DATA_WIDTH-1:0] aligned_data;

        case (txn.kind)
            READ:       begin this.vif.read(txn.addr, txn.data, txn.resp); end
            WRITE8:     begin write8(txn.addr, txn.data[7:0], txn.position, txn.resp); end
            WRITE16:    begin write16(txn.addr, txn.data[15:0], txn.position, txn.resp); end
            WRITE32:    begin write32(txn.addr, txn.data[31:0], txn.position, txn.resp); end
            WRITE64:    begin write64(txn.addr, txn.data[63:0], txn.resp); end
            default:    begin $fatal("Unsupported operation type: %d", txn.kind); end
        endcase

    endtask: execute

    task automatic write8(logic [AXI_ADDR_WIDTH-1:0] addr, logic [7:0] data, int position, axi4l_resp_t resp);
        logic [AXI_DATA_WIDTH-1:0] aligned_data;
        logic [(AXI_DATA_WIDTH/8)-1:0] byte_enable;

        assert(position < (AXI_DATA_WIDTH/8))
            else $fatal(0, "Position out of range");

        aligned_data = data << (position * 8);
        byte_enable = 1'b1 << position;

        this.vif.write(addr, aligned_data, byte_enable, resp);
    endtask: write8

    task automatic write16(logic [AXI_ADDR_WIDTH-1:0] addr, logic [15:0] data, int position, axi4l_resp_t resp);
        logic [AXI_DATA_WIDTH-1:0] aligned_data;
        logic [(AXI_DATA_WIDTH/8)-1:0] byte_enable;

        assert(position < (AXI_DATA_WIDTH/8) && position % 2 == 0)
            else $fatal(0, "Position out of range or position unaligned");

        aligned_data = data << (position * 8);
        byte_enable = 2'b11 << position;
        this.vif.write(addr, aligned_data, byte_enable, resp);
    endtask: write16

    task automatic write32(logic [AXI_ADDR_WIDTH-1:0] addr, logic [31:0] data, int position, axi4l_resp_t resp);
        logic [AXI_DATA_WIDTH-1:0] aligned_data;
        logic [(AXI_DATA_WIDTH/8)-1:0] byte_enable;

        assert(position < (AXI_DATA_WIDTH/8) && position % 4 == 0)
            else $fatal(0, "Position out of range or position unaligned");

        aligned_data = data << (position * 8);
        byte_enable = 4'b1111 << position;
        this.vif.write(addr, aligned_data, byte_enable, resp);
    endtask: write32

    task automatic write64(logic [AXI_ADDR_WIDTH-1:0] addr, logic [63:0] data, axi4l_resp_t resp);
        logic [(AXI_DATA_WIDTH/8)-1:0] byte_enable;

        assert(AXI_DATA_WIDTH == 64)
            else $fatal(0, "Data bus width unsupported");

        byte_enable = 8'hFF;
        this.vif.write(addr, data, byte_enable, resp);
    endtask: write64

    function automatic void display;
        $display("AXI_ADDR_WIDTH = %d", AXI_ADDR_WIDTH);
        $display("AXI_DATA_WIDTH = %d", AXI_DATA_WIDTH);
    endfunction: display

endclass: axi4l_driver
